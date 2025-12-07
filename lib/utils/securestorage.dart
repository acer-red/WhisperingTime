import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _keyName = 'wt_encryption_key';

  /// 获取密钥：如果存在则读取，如果不存在则生成并保存
  Future<Uint8List> getKey() async {
    String? base64Key = await _storage.read(key: _keyName);

    if (base64Key != null) {
      return base64Decode(base64Key);
    }

    final newKeyBytes = _generateRandomBytes(32);

    String newKeyBase64 = base64Encode(newKeyBytes);

    await _storage.write(key: _keyName, value: newKeyBase64);

    return newKeyBytes;
  }

  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return Uint8List.fromList(values);
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
}
