import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:whispering_time/util/env.dart';

class Storage {
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

  Future<void> deleteAll() async {
    await _storage.deleteAll();
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
}

class Key {
  final List<int> publicKey;
  final List<int> privateKey;
  String get publicKeyString => base64Encode(publicKey);
  String get privateKeyString => base64Encode(privateKey);
  Key({required this.publicKey, required this.privateKey});
}

class KeyManager {
  final algorithm = X25519();

  Future<Key> generateAndPrintKeys() async {
    try {
      final SimpleKeyPair keyPair = await algorithm.newKeyPair();

      final SimplePublicKey publicKey = await keyPair.extractPublicKey();

      return Key(
        // 获取公钥的原始字节 (32 bytes)
        publicKey: publicKey.bytes,

        // 获取私钥的原始字节 (32 bytes)
        privateKey: await keyPair.extractPrivateKeyBytes(),
      );
    } catch (e) {
      throw '生成密钥失败: $e';
    }
  }
}
