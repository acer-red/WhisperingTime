import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/util/secure.dart';
import 'package:http/http.dart' as http;

class DocImage extends StatelessWidget {
  final String imageSource;
  final BoxFit fit;

  const DocImage({
    super.key,
    required this.imageSource,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    String src = imageSource;
    if (src.startsWith('file:')) {
      return EncryptedImage(fileId: src.substring(5));
    }
    if (!src.startsWith('http://') && !src.startsWith('https://')) {
      final serverAddress = Config.instance.serverAddress;
      final uid = Config.instance.uid;
      src = '$serverAddress/image/$uid/$src';
    }
    return Image.network(
      src,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Icon(Icons.error));
      },
    );
  }
}

class CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    var imageSource = embedContext.node.value.data as String;

    if (imageSource.startsWith('file:')) {
      return EncryptedImage(fileId: imageSource.substring(5));
    }

    // 如果不是完整URL（不以http开头），则拼接服务器地址
    if (!imageSource.startsWith('http://') &&
        !imageSource.startsWith('https://')) {
      final serverAddress = Config.instance.serverAddress;
      final uid = Config.instance.uid;
      imageSource = '$serverAddress/image/$uid/$imageSource';
    }

    // 使用默认的图片widget显示
    return Image.network(
      imageSource,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
                SizedBox(height: 8),
                Text('图片加载中...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        );
      },
    );
  }
}

class EncryptedImage extends StatefulWidget {
  final String fileId;

  const EncryptedImage({required this.fileId});

  @override
  State<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends State<EncryptedImage> {
  late Future<Uint8List> _future;
  final Storage _storage = Storage();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Uint8List> _load() async {
    final presign = await Grpc().presignDownloadFile(widget.fileId);
    if (!presign.isOK ||
        presign.downloadUrl == null ||
        presign.encryptedKey == null) {
      throw Exception(presign.msg.isEmpty ? '无法获取文件' : presign.msg);
    }

    final resp = await http.get(Uri.parse(presign.downloadUrl!));
    if (resp.statusCode >= 400) {
      throw Exception('下载失败: HTTP ${resp.statusCode}');
    }

    return _storage.envelopeDecrypt(
      cipherText: Uint8List.fromList(resp.bodyBytes),
      encryptedKey: presign.encryptedKey!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                const SizedBox(height: 4),
                Text('图片加载失败',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return const SizedBox.shrink();
        }
        return Image.memory(data, fit: BoxFit.contain);
      },
    );
  }
}
