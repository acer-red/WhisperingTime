import 'dart:convert';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/Isar/config.dart';
import 'package:whispering_time/services/Isar/font.dart';
import 'package:http/http.dart' as http;
import 'base.dart';

class FontItem {
  String name;
  String fullName;
  String subName;
  String copyRight;
  String license;
  String fileName;
  String version;
  String sha256;
  String downloadURL;
  FontItem(
      {required this.name,
      required this.fullName,
      required this.subName,
      required this.copyRight,
      required this.license,
      required this.version,
      required this.sha256,
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
        version: json['version'],
        sha256: json['sha256'],
        downloadURL: json['download_url']);
  }
}

class ResponseGetFonts extends Basic {
  List<FontItem> data = [];
  ResponseGetFonts(
      {required super.err, required super.msg, required this.data});
  factory ResponseGetFonts.fromJson(Map<String, dynamic> json) {
    return ResponseGetFonts(
        err: json['err'],
        msg: json['msg'],
        data: json['data']['items']
            .map<FontItem>((e) => FontItem.fromJson(e))
            .toList());
  }
}

class Fontx {
  String name;
  String downloadURL;
  Fontx({required this.name, required this.downloadURL});
  factory Fontx.fromJson(Map<String, dynamic> json) {
    return Fontx(name: json['name'], downloadURL: json['download_url']);
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
    final b = await Font().isExistFont(item.fileName, item.sha256);
    if (b) {
      return true;
    }

    final request = await http.get(Uri.parse(item.downloadURL));
    try {
      await Font(
        name: item.name,
        fullName: item.fullName,
        subName: item.subName,
        copyRight: item.copyRight,
        license: item.license,
        fileName: item.name,
        version: item.version,
        sha256: item.sha256,
        downloadURL: item.downloadURL,
      ).uploadFont(request.bodyBytes);

    } catch (e) {
      log.e("保存字体失败,${e.toString()}");
      return false;
    }
    log.i("下载字体文件 ${item.fullName}");
    return true;
  }
}
