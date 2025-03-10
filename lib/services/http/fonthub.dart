import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/Isar/config.dart';
import 'package:http/http.dart' as http;
import 'base.dart';

class FontItem {
  String name;
  String fullName;
  String subName;
  String copyRight;
  String license;
  String fileName;
  String downloadURL;
  FontItem(
      {required this.name,
      required this.fullName,
      required this.subName,
      required this.copyRight,
      required this.license,
      required this.fileName,
      required this.downloadURL});
  factory FontItem.fromJson(Map<String, dynamic> json) {
    return FontItem(
        name: json['name'],
        fullName: json['full_name'],
        subName: json['sub_name'],
        copyRight: json['copy_right'],
        license: json['license'],
        fileName: json['file_name'],
        downloadURL: json['download_url']);
  }
}

class ResponseGetFonts extends Basic {
  List<FontItem> data = [];
  ResponseGetFonts({required super.err, required super.msg, required this.data});
  factory ResponseGetFonts.fromJson(Map<String, dynamic> json) {
    return ResponseGetFonts(
        err: json['err'],
        msg: json['msg'],
        data: json['data']['items']
            .map<FontItem>((e) => FontItem.fromJson(e))
            .toList());
  }
}

class Font {
  String name;
  String downloadURL;
  Font({required this.name, required this.downloadURL});
  factory Font.fromJson(Map<String, dynamic> json) {
    return Font(name: json['name'], downloadURL: json['download_url']);
  }
}

class Http {
  static final String serverAddress = Config.instance.fontHubServerAddress;

  Future<T> _handleRequest<T>(
      Method method, Uri u, Function(Map<String, dynamic>) fromJson,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    if (data != null) {
      log.d(data);
    }
    try {
      final http.Response response;
      switch (method) {
        case Method.get:
          response = await http.get(u, headers: headers);
          break;
        case Method.post:
          response =
              await http.post(u, body: jsonEncode(data), headers: headers);
          break;
        case Method.put:
          response =
              await http.put(u, body: jsonEncode(data), headers: headers);
          break;
        case Method.delete:
          response =
              await http.delete(u, body: jsonEncode(data), headers: headers);
          break;
      }
      if (response.body.isEmpty) {
        log.e("服务器返回空");
        return fromJson({'err': 1, 'msg': ''});
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      return fromJson(json);
    } catch (e) {
      log.e(e.toString());
      return fromJson({'err': 1, 'msg': ''});
    }
  }

  Future<ResponseGetFonts> getFonts() async {
    final Uri u = Uri.parse("$serverAddress/api/fonts");
    return _handleRequest<ResponseGetFonts>(Method.get, u, (json) {
      return ResponseGetFonts.fromJson(json);
    });
  }

  Future<bool> getFontFile(FontItem item) async {
    Directory path = await getTemporaryDirectory();
    if (await File("${path.path}/${item.fileName}").exists()) {
      return true;
    }
    String savePath = "${path.path}/${item.fileName}";
    File file = File(savePath);
    var request = await http.get(Uri.parse(item.downloadURL));
    var bytes = request.bodyBytes;
    await file.writeAsBytes(bytes);
    log.i("下载字体文件 ${item.fullName} 到 $savePath");
    return true;
  }
}
