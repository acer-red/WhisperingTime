import 'dart:typed_data';

class ScaleTemplateEncryptedRecord {
  final String id;
  final Uint8List encryptedMetadata;
  final DateTime createdAt;

  const ScaleTemplateEncryptedRecord({
    required this.id,
    required this.encryptedMetadata,
    required this.createdAt,
  });
}

/// Frontend-only abstraction.
///
/// ZKA principle:
/// - This layer returns/accepts `bytes` for payload fields.
/// - Plaintext metadata is only handled on the client via decrypt().
abstract class ScaleService {
  Future<List<ScaleTemplateEncryptedRecord>> listScaleTemplates();

  Future<ScaleTemplateEncryptedRecord> createScaleTemplate({
    required Uint8List encryptedMetadata,
  });

  Future<void> updateScaleTemplate({
    required String id,
    required Uint8List encryptedMetadata,
  });

  Future<void> deleteScaleTemplate({
    required String id,
  });

  /// Mock crypto helpers (explicitly modeled for ZKA flow).
  Future<Uint8List> encryptMetadata(Map<String, dynamic> metadata);
  Future<Map<String, dynamic>> decryptMetadata(Uint8List encryptedMetadata);
}
