import 'dart:convert';
import 'dart:typed_data';

import 'package:whispering_time/grpc_generated/whisperingtime.pb.dart' as pb;
import 'package:whispering_time/service/grpc/grpc.dart'
    show grpcAuthOptions, grpcScaleClient;
import 'package:whispering_time/util/secure.dart';

import 'scale_service.dart';

class ScaleServiceGrpc implements ScaleService {
  final Storage _storage;

  ScaleServiceGrpc({Storage? storage}) : _storage = storage ?? Storage();

  @override
  Future<List<ScaleTemplateEncryptedRecord>> listScaleTemplates() async {
    final client = await grpcScaleClient();
    final resp = await client.listScaleTemplates(
      pb.ListScaleTemplatesRequest(),
      options: await grpcAuthOptions(),
    );

    if (resp.err != 0) {
      throw Exception(resp.msg);
    }

    return resp.templates
        .map(
          (t) => ScaleTemplateEncryptedRecord(
            id: t.id,
            encryptedMetadata: Uint8List.fromList(t.encryptedMetadata),
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              t.createdAt.toInt() * 1000,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<ScaleTemplateEncryptedRecord> createScaleTemplate({
    required Uint8List encryptedMetadata,
  }) async {
    final client = await grpcScaleClient();
    final resp = await client.createScaleTemplate(
      pb.CreateScaleTemplateRequest(encryptedMetadata: encryptedMetadata),
      options: await grpcAuthOptions(),
    );

    if (resp.err != 0) {
      throw Exception(resp.msg);
    }

    return ScaleTemplateEncryptedRecord(
      id: resp.id,
      encryptedMetadata: encryptedMetadata,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateScaleTemplate({
    required String id,
    required Uint8List encryptedMetadata,
  }) async {
    final client = await grpcScaleClient();
    final resp = await client.updateScaleTemplate(
      pb.UpdateScaleTemplateRequest(
        id: id,
        encryptedMetadata: encryptedMetadata,
      ),
      options: await grpcAuthOptions(),
    );

    if (resp.err != 0) {
      throw Exception(resp.msg);
    }
  }

  @override
  Future<void> deleteScaleTemplate({
    required String id,
  }) async {
    final client = await grpcScaleClient();
    final resp = await client.deleteScaleTemplate(
      pb.DeleteScaleTemplateRequest(id: id),
      options: await grpcAuthOptions(),
    );

    if (resp.err != 0) {
      throw Exception(resp.msg);
    }
  }

  /// Packs an envelope payload into a single bytes blob:
  /// {"v":1,"c":"base64(cipherText)","k":"base64(encryptedKey)"}
  @override
  Future<Uint8List> encryptMetadata(Map<String, dynamic> metadata) async {
    final plain = utf8.encode(jsonEncode(metadata));
    final env = await _storage.envelopeEncrypt(plain);

    final packed = <String, dynamic>{
      'v': 1,
      'c': base64Encode(env.cipherText),
      'k': base64Encode(env.encryptedKey),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(packed)));
  }

  @override
  Future<Map<String, dynamic>> decryptMetadata(
      Uint8List encryptedMetadata) async {
    if (encryptedMetadata.isEmpty) return <String, dynamic>{};

    // Backward-compatible:
    // - New format: packed envelope JSON with c/k
    // - Legacy/mock: plaintext JSON bytes
    final decodedText = utf8.decode(encryptedMetadata, allowMalformed: true);
    dynamic parsed;
    try {
      parsed = jsonDecode(decodedText);
    } catch (_) {
      return <String, dynamic>{};
    }

    if (parsed is Map && parsed['c'] is String && parsed['k'] is String) {
      final cipherText = base64Decode(parsed['c'] as String);
      final encryptedKey = base64Decode(parsed['k'] as String);
      final plainBytes = await _storage.envelopeDecrypt(
        cipherText: Uint8List.fromList(cipherText),
        encryptedKey: Uint8List.fromList(encryptedKey),
      );
      final plainText = utf8.decode(plainBytes, allowMalformed: true);
      final meta = jsonDecode(plainText);
      if (meta is Map<String, dynamic>) return meta;
      if (meta is Map) return meta.map((k, v) => MapEntry('$k', v));
      return <String, dynamic>{};
    }

    if (parsed is Map<String, dynamic>) return parsed;
    if (parsed is Map) return parsed.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }
}
