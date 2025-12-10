import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:whispering_time/util/env.dart';

class Storage {
  static const int _nonceLength = 12;
  static const int _macLength = 16;
  final FlutterSecureStorage _storage = FlutterSecureStorage(
      mOptions: MacOsOptions(accountName: App.fullAppIdentity));

  static const String cookieKey = 'cookie';
  static const String encryptionKey = 'encryption_key';

  /// 获取密钥：如果存在则读取，如果不存在则生成并保存
  Future<Uint8List> getKey({List<int>? newKey}) async {
    if (newKey != null) {
      final newKeyBytes = Uint8List.fromList(newKey);
      if (newKeyBytes.length != 32) {
        throw Exception("Invalid key length");
      }

      await _storage.write(
          key: encryptionKey, value: base64Encode(newKeyBytes));
      return newKeyBytes;
    }

    String? keyString = await _storage.read(key: encryptionKey);

    // 密钥不存在
    if (keyString == null) {
      throw Exception("Key not found");
    }

    // 如果不是32字节，则报错
    final keyBytes = base64Decode(keyString);
    if (keyBytes.length != 32) {
      throw Exception("Invalid key length");
    }
    return keyBytes;
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<Uint8List> encryptData(Uint8List data) async {
    if (data.isEmpty) {
      return Uint8List(0);
    }
    final keyBytes = await getKey();
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encryptBytes(data, iv: iv);
    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }

  Future<Uint8List> decryptData(Uint8List data) async {
    if (data.isEmpty) {
      return Uint8List(0);
    }
    final keyBytes = await getKey();
    final key = encrypt.Key(keyBytes);

    if (data.length < 16) {
      throw Exception("Invalid data length");
    }

    final iv = encrypt.IV(data.sublist(0, 16));
    final encryptedBytes = encrypt.Encrypted(data.sublist(16));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return Uint8List.fromList(encrypter.decryptBytes(encryptedBytes, iv: iv));
  }

  Future<void> write(String key, String value) async {
    // ios: 后台运行时也能访问
    final options =
        IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    await _storage.write(key: key, value: value, iOptions: options);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> writeCookie(String value) {
    return write(cookieKey, value);
  }

  Future<String?> readCookie() {
    return _storage.read(key: cookieKey);
  }

  Future<void> deleteCookie() {
    return delete(cookieKey);
  }

  Uint8List _randomBytes(int length) {
    final rand = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = rand.nextInt(256);
    }
    return bytes;
  }

  Future<Uint8List> encryptWithDataKey(Uint8List key, List<int> data) async {
    if (data.isEmpty) return Uint8List(0);
    final algorithm = AesGcm.with256bits();
    final nonce = _randomBytes(_nonceLength);
    final box = await algorithm.encrypt(
      data,
      secretKey: SecretKey(key),
      nonce: nonce,
    );
    final result =
        Uint8List(_nonceLength + box.cipherText.length + box.mac.bytes.length);
    result.setRange(0, _nonceLength, nonce);
    result.setRange(
        _nonceLength, _nonceLength + box.cipherText.length, box.cipherText);
    result.setRange(
        _nonceLength + box.cipherText.length, result.length, box.mac.bytes);
    return result;
  }

  Future<Uint8List> decryptWithDataKey(Uint8List key, List<int> data) async {
    if (data.isEmpty) return Uint8List(0);
    if (data.length < _nonceLength + _macLength) {
      throw Exception('Invalid ciphertext');
    }
    final nonce = Uint8List.fromList(data.sublist(0, _nonceLength));
    final macStart = data.length - _macLength;
    final cipherText = Uint8List.fromList(data.sublist(_nonceLength, macStart));
    final mac = Mac(data.sublist(macStart));
    final algorithm = AesGcm.with256bits();
    final box = SecretBox(cipherText, nonce: nonce, mac: mac);
    final plain = await algorithm.decrypt(box, secretKey: SecretKey(key));
    return Uint8List.fromList(plain);
  }

  Future<Uint8List> wrapDataKey(Uint8List dataKey) async {
    final userKey = await getKey();
    return encryptWithDataKey(userKey, dataKey);
  }

  Future<Uint8List> unwrapDataKey(Uint8List encryptedKey) async {
    final userKey = await getKey();
    return decryptWithDataKey(userKey, encryptedKey);
  }

  Future<EnvelopePayload> envelopeEncrypt(List<int> data) async {
    final dataKey = Uint8List.fromList(await KeyManager.generateAES());
    final cipherText = await encryptWithDataKey(dataKey, data);
    final encryptedKey = await wrapDataKey(dataKey);
    return EnvelopePayload(
      cipherText: cipherText,
      encryptedKey: encryptedKey,
      dataKey: dataKey,
    );
  }

  Future<Uint8List> envelopeDecrypt(
      {required Uint8List cipherText, required Uint8List encryptedKey}) async {
    final dataKey = await unwrapDataKey(encryptedKey);
    return decryptWithDataKey(dataKey, cipherText);
  }
}

class EnvelopePayload {
  final Uint8List cipherText;
  final Uint8List encryptedKey;
  final Uint8List dataKey;

  EnvelopePayload({
    required this.cipherText,
    required this.encryptedKey,
    required this.dataKey,
  });
}

class KeyPair {
  final List<int> publicKey;
  final List<int> privateKey;
  String get publicKeyString => base64Encode(publicKey);
  String get privateKeyString => base64Encode(privateKey);
  KeyPair({required this.publicKey, required this.privateKey});
}

class KeyManager {
  static Future<KeyPair> generateX25519() async {
    try {
      final SimpleKeyPair keyPair = await X25519().newKeyPair();

      final SimplePublicKey publicKey = await keyPair.extractPublicKey();

      return KeyPair(
        // 获取公钥的原始字节 (32 bytes)
        publicKey: publicKey.bytes,

        // 获取私钥的原始字节 (32 bytes)
        privateKey: await keyPair.extractPrivateKeyBytes(),
      );
    } catch (e) {
      throw '生成密钥失败: $e';
    }
  }

  static Future<List<int>> generateAES() async {
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();
    final keyBytes = await secretKey.extractBytes();
    return keyBytes;
  }
}
