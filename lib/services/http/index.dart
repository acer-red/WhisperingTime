import 'dart:convert';

import 'package:http/http.dart' as http;

import './base.dart';
import 'package:whispering_time/utils/env.dart';


// feedback
class FeedBack {
  final String fbid;
  final FeedbackType type;
  final String title;
  final String content;
  final bool isPublic;
  final String? deviceFile;
  final List<String>? images;

  final String crtime;
  final String uptime;

  FeedBack({
    required this.fbid,
    required this.type,
    required this.title,
    required this.content,
    required this.isPublic,
    required this.crtime,
    required this.uptime,
    this.deviceFile,
    this.images,
  });
  factory FeedBack.fromJson(Map<String, dynamic> json) {
    return FeedBack(
      fbid: json['fbid'] as String,
      type: FeedbackType.values[json['fb_type'] as int],
      title: json['title'] as String,
      content: json['content'] as String,
      isPublic: json['is_public'] as bool,
      deviceFile: json['device_file'] as String,
      images: json['images'] != null
          ? (json['images'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      crtime: json['crtime'] as String,
      uptime: json['uptime'] as String,
    );
  }
}

class RequestPostFeedback {
  FeedbackType fbType;
  String title;
  String content;
  bool isPublic;
  String? deviceFilePath;
  List<String>? images;
  RequestPostFeedback(
      {required this.fbType,
      required this.title,
      required this.content,
      required this.isPublic,
      this.deviceFilePath,
      this.images});
}

class ResponsePostFeedback extends Basic {
  String id;
  ResponsePostFeedback(
      {required super.err, required super.msg, required this.id});
  factory ResponsePostFeedback.fromJson(Map<String, dynamic> json) {
    return ResponsePostFeedback(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] == null ? "" : json['data']['id'] as String,
    );
  }
}

class ResponseGetFeedbacks extends Basic {
  List<FeedBack> data;
  ResponseGetFeedbacks(
      {required super.err, required super.msg, required this.data});
  factory ResponseGetFeedbacks.fromJson(Map<String, dynamic> json) {
    return ResponseGetFeedbacks(
      err: json['err'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) => FeedBack.fromJson(item as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
  }
}

class Http{
  final String serverAddress = HTTPConfig().indexServerAddress;

    Future<T> _handleRequest<T>(
      Method method, Uri u, Function(Map<String, dynamic>) fromJson,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    if (data != null) {
      log.d(data);
    }
    final http.Response response;

    try {
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
    } catch (e) {
      log.e("请求失败:${e.toString()}");
      return fromJson({'err': 1, 'msg': ''});
    }

    try {
      final Map<String, dynamic> g = jsonDecode(response.body);
      return fromJson(g);
    } catch (e) {
      log.e("解析数据失败 \n${response.body}\n${e.toString()}");
      return fromJson({'err': 1, 'msg': ''});
    }
  }


  Future<ResponsePostFeedback> postFeedback(RequestPostFeedback req) async {
    log.i("发送请求 提交反馈");
    String path = "/api/v1/feedback";

    final url = Uri.https(serverAddress, path);
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = "";
    request.fields['fb_type'] = req.fbType.index.toString();
    request.fields['title'] = req.title;
    request.fields['content'] = req.content;
    request.fields['is_public'] = req.isPublic ? "1" : "0";
    if (req.deviceFilePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'device_file',
        req.deviceFilePath!,
      ));
    }

    if (req.images != null && req.images!.isNotEmpty) {
      for (String imagePath in req.images!) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          imagePath,
        ));
      }
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseBody);
    return ResponsePostFeedback.fromJson(json);
  }

  Future<ResponseGetFeedbacks> getFeedbacks({String? text}) {
    log.i("发送请求 获取反馈列表");
    final String path = "/api/v1/feedbacks";
    Map<String, String> param = {};
    if (text != null) {
      param = {
        "text": text,
      };
    }
    final Map<String, String> headers = {
      'Authorization': "",
    };
    final url = Uri.https(serverAddress, path, param.isEmpty ? null : param);
    return _handleRequest<ResponseGetFeedbacks>(
      Method.get,
      url,
      (json) => ResponseGetFeedbacks.fromJson(json),
      headers: headers,
    );
  }

}