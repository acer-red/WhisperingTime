import 'dart:convert';

import 'package:http/http.dart' as http;

import './base.dart';
import 'package:whispering_time/utils/env.dart';

// 用户登陆
class RequestPostUserLogin {
  final String account;
  final String password;
  RequestPostUserLogin({required this.account, required this.password});
  Map<String, dynamic> toJson() {
    return {'account': account, 'password': password};
  }
}

class ReponsePostUserLogin extends Basic {
  final String id;

  ReponsePostUserLogin(
      {required super.err, required super.msg, required this.id});

  factory ReponsePostUserLogin.fromJson(Map<String, dynamic> g) {
    return ReponsePostUserLogin(
        err: g['err'],
        msg: g['msg'],
        id: g['data'] != null ? g['data']['id'] : '');
  }
}

// 用户注册
class RequestPostUserRegister {
  final String username;
  final String email;
  final String password;

  RequestPostUserRegister({
    required this.username,
    required this.email,
    required this.password,
  });
  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password, 'email': email};
  }
}

class ReponsePostUserRegister extends Basic {
  final String id;

  ReponsePostUserRegister({
    required super.err,
    required super.msg,
    required this.id,
  });
  factory ReponsePostUserRegister.fromJson(Map<String, dynamic> g) {
    return ReponsePostUserRegister(
      err: g['err'],
      msg: g['msg'],
      id: g['data'] != null ? g['data']['id'] : '',
    );
  }
}

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

class Http {
  final String serverAddress = HTTPConfig.indexServerAddress;

  Http() {
    print("服务器:$serverAddress");
  }
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
      if (err(response.statusCode)) {
        return fromJson({'err': 1, 'msg': getMsg(response.statusCode)});
      }
    } catch (e) {
      log.e("请求失败\n${e.toString()}");
      return fromJson({'err': 1, 'msg': '登陆失败，请稍后尝试'});
    }
    try {
      return fromJson(jsonDecode(response.body));
    } catch (e) {
      log.e("解析数据失败 ${e.toString()}\n${response.body}");
      return fromJson({'err': 1, 'msg': '未知错误'});
    }
  }

  bool err(int statusCode) {
    return statusCode >= 400;
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

  Future<ReponsePostUserRegister> userRegister(RequestPostUserRegister req) {
    final path = "/api/v1/user/register";
    final uri = Uri.parse(serverAddress + path);

    return _handleRequest(
      Method.post,
      uri,
      (g) => ReponsePostUserRegister.fromJson(g),
      data: req.toJson(),
    );
  }

  Future<ReponsePostUserLogin> userLogin(RequestPostUserLogin req) async {
    final path = "/api/v1/user/login";
    final uri = Uri.parse(serverAddress + path);
    return _handleRequest(
      Method.post,
      uri,
      (g) => ReponsePostUserLogin.fromJson(g),
      data: req.toJson(),
    );
  }

  getMsg(int statusCode) {
    final String msg;
    switch (statusCode) {
      case 400:
        msg = "用户名或密码错误";
        break;
      case 409:
        msg = "已存在";
        break;
      case 500:
        msg = "服务器错误";
        break;
      default:
        msg = "未知错误，稍后重试";
        break;
    }
    return msg;
  }
}
