import 'dart:convert';
import 'dart:typed_data';

import 'package:whispering_time/service/scale/scale_service.dart';

class ScaleServiceMock implements ScaleService {
  /// In-memory "blind storage" for encrypted template metadata.
  final Map<String, ScaleTemplateEncryptedRecord> _store = {};
  int _seq = 0;

  ScaleServiceMock();

  @override
  Future<List<ScaleTemplateEncryptedRecord>> listScaleTemplates() async {
    // Server returns encrypted bytes only.
    return _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<ScaleTemplateEncryptedRecord> createScaleTemplate({
    required Uint8List encryptedMetadata,
  }) async {
    // Server stores encrypted bytes as-is.
    final id = 'st_${DateTime.now().millisecondsSinceEpoch}_${_seq++}';
    final record = ScaleTemplateEncryptedRecord(
      id: id,
      encryptedMetadata: encryptedMetadata,
      createdAt: DateTime.now(),
    );
    _store[id] = record;
    return record;
  }

  @override
  Future<void> updateScaleTemplate({
    required String id,
    required Uint8List encryptedMetadata,
  }) async {
    final existing = _store[id];
    if (existing == null) {
      throw Exception('template not found');
    }
    _store[id] = ScaleTemplateEncryptedRecord(
      id: id,
      encryptedMetadata: encryptedMetadata,
      createdAt: existing.createdAt,
    );
  }

  @override
  Future<void> deleteScaleTemplate({
    required String id,
  }) async {
    final existing = _store.remove(id);
    if (existing == null) {
      throw Exception('template not found');
    }
  }

  @override
  Future<Uint8List> encryptMetadata(Map<String, dynamic> metadata) async {
    // Pseudo-code is acceptable for this task.
    // encrypt(data): JSON -> bytes -> "encrypt" -> bytes
    final plain = jsonEncode(metadata);
    return Uint8List.fromList(utf8.encode('enc:$plain'));
  }

  @override
  Future<Map<String, dynamic>> decryptMetadata(
      Uint8List encryptedMetadata) async {
    // decrypt(data): bytes -> "decrypt" -> JSON
    final s = utf8.decode(encryptedMetadata, allowMalformed: true);
    final jsonStr = s.startsWith('enc:') ? s.substring(4) : s;
    final decoded = jsonDecode(jsonStr);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }
}
