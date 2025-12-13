import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'base.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/util/secure.dart';
import 'package:whispering_time/service/sp/sp.dart';
import 'package:whispering_time/welcome.dart';

// 用户登陆
class RequestUserLogin {
  final String account;
  final String password;
  RequestUserLogin({required this.account, required this.password});
  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'password': password,
      'category': appNameEn,
      'uid': SP().getUID()
    };
  }
}

class ReponseUserLogin extends Basic {
  final String id;
  final List<API> apis;
  ReponseUserLogin({
    required super.err,
    required super.msg,
    required this.id,
    required this.apis,
  });

  factory ReponseUserLogin.fromJson(Map<String, dynamic> g) {
    return ReponseUserLogin(
        err: g['err'] as int,
        msg: g['msg'] as String,
        id: g['data'] != null ? g['data']['id'] : '',
        apis: g['data'] != null && g['data']['api'] != null
            ? (g['data']['api'] as List<dynamic>)
                .map((e) => API.fromJson(e))
                .toList()
            : []);
  }
}

// 用户注册
class RequestCreateUserRegister {
  final String username;
  final String email;
  final String password;
  final String uid;
  final List<int> publicKey;
  RequestCreateUserRegister({
    required this.username,
    required this.email,
    required this.password,
    required this.publicKey,
    required this.uid,
  });
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'category': appNameEn,
      'uid': uid,
      'public_key': base64Encode(publicKey),
    };
  }
}

class ReponsePostUserRegister extends Basic {
  final String id;
  final List<API> apis;
  ReponsePostUserRegister({
    required super.err,
    required super.msg,
    required this.id,
    required this.apis,
  });
  factory ReponsePostUserRegister.fromJson(Map<String, dynamic> g) {
    return ReponsePostUserRegister(
        err: g['err'] as int,
        msg: g['msg'] as String,
        id: g['data'] != null ? g['data']['id'] : '',
        apis: g['data'] != null && g['data']['api'] != null
            ? (g['data']['api'] as List<dynamic>)
                .map((e) => API.fromJson(e as Map<String, dynamic>))
                .toList()
            : []);
  }
}

class RequestCreateUserRegisterVisitor {
  RequestCreateUserRegisterVisitor();
  Map<String, dynamic> toJson() {
    return {
      'category': appNameEn,
    };
  }
}

// 用户信息
class ReponseGetUserInfo extends Basic {
  final String username;
  final String email;
  final String createAt;
  final Profile profile;

  ReponseGetUserInfo({
    required super.err,
    required super.msg,
    required this.username,
    required this.email,
    required this.createAt,
    required this.profile,
  });
  factory ReponseGetUserInfo.fromJson(Map<String, dynamic> g) {
    return ReponseGetUserInfo(
      err: g['err'],
      msg: g['msg'],
      username: g['data'] != null ? g['data']['username'] : '',
      email: g['data'] != null ? g['data']['email'] : '',
      createAt: g['data'] != null ? g['data']['createAt'] : '',
      profile: g['data'] != null && g['data']['profile'] != null
          ? Profile.fromJson(g['data']['profile'])
          : Profile(nickname: '', avatar: Avatar(name: "", url: "url")),
    );
  }
}

// 用户头像和昵称
class RequestUpdateUserProfile {
  final String? nickname;
  final Uint8List? bytes;
  final String? ext;
  RequestUpdateUserProfile({this.nickname, this.bytes, this.ext});
}

class ReponsePutUserProfile extends Basic {
  String? url;
  ReponsePutUserProfile({required super.err, required super.msg, this.url});
  factory ReponsePutUserProfile.fromJson(Map<String, dynamic> g) {
    return ReponsePutUserProfile(
      err: g['err'] as int,
      msg: g['msg'] as String,
      url: g['data'] != null ? g['data']['url'] : null,
    );
  }
}

// 反馈
class FeedBack {
  final String fbid;
  final FeedbackType type;
  final String title;
  final String content;
  final bool isPublic;
  final String? deviceFile;
  final List<String>? images;

  final String createAt;
  final String updateAt;

  FeedBack({
    required this.fbid,
    required this.type,
    required this.title,
    required this.content,
    required this.isPublic,
    required this.createAt,
    required this.updateAt,
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
      createAt: json['createAt'] as String,
      updateAt: json['updateAt'] as String,
    );
  }
}

class RequestCreateFeedback {
  FeedbackType fbType;
  String title;
  String content;
  bool isPublic;
  String? deviceFilePath;
  List<String>? images;
  RequestCreateFeedback(
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

  Future<T> _handleRequest<T>(
    Method method,
    Uri u,
    Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    FutureOr<void> Function(http.Response response)? onResponse,
  }) async {
    final requestHeaders = headers != null
        ? Map<String, String>.from(headers)
        : <String, String>{};
    final cookie = await Storage().readCookie();
    if (cookie != null && cookie.isNotEmpty) {
      requestHeaders.putIfAbsent('Cookie', () => cookie);
    }
    if (data != null) {
      log.i("请求路径:${u.path} 请求数据\n $data");
    }
    final http.Response response;

    // 发送请求
    try {
      switch (method) {
        case Method.get:
          response = await http.get(u, headers: requestHeaders);
          break;
        case Method.post:
          response = await http.post(
            u,
            body: jsonEncode(data),
            headers: requestHeaders,
          );

          break;
        case Method.put:
          response = await http.put(
            u,
            body: jsonEncode(data),
            headers: requestHeaders,
          );
          break;
        case Method.delete:
          response = await http.delete(
            u,
            body: jsonEncode(data),
            headers: requestHeaders,
          );
          break;
      }

      if (response.statusCode == 410) {
        final cookie = await Storage().readCookie();
        if (cookie != null && cookie.isNotEmpty) {
          final navigator = navigatorKey.currentState;
          if (navigator != null && navigator.mounted) {
            final context = navigator.context;
            if (!context.mounted) return fromJson({'err': 1, 'msg': '账号已注销'});
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text('账号已注销'),
                content: Text('您的账号已被注销，请重新登录或注册。'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await Storage().deleteAll();
                      SP().over();
                      if (!nav.mounted) return;
                      nav.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Welcome()),
                        (route) => false,
                      );
                    },
                    child: Text('确定'),
                  ),
                ],
              ),
            );
          }
        }
        return fromJson({'err': 1, 'msg': '账号已注销'});
      }

      if (!err(response.statusCode)) {
        await onResponse?.call(response);
      }
      if (err(response.statusCode)) {
        return fromJson({'err': 1, 'msg': getMsg(response.statusCode)});
      }
    } catch (e) {
      log.e("请求失败\n${e.toString()}");
      return fromJson({'err': 1, 'msg': '登陆失败，请稍后尝试'});
    }
    try {
      final j = jsonDecode(response.body);
      // log.i("请求路径:${u.path}  \n原始响应数据:\n${response.body}\nJOSN响应数据:\n${const JsonEncoder.withIndent('  ').convert(j)}");
      return fromJson(j);
    } catch (e) {
      log.e("解析数据失败 ${e.toString()}\n${response.body}");
      return fromJson({'err': 1, 'msg': '未知错误'});
    }
  }

  bool err(int statusCode) {
    return statusCode >= 400;
  }

  Future<ResponsePostFeedback> postFeedback(RequestCreateFeedback req) async {
    log.i("发送请求 提交反馈");
    String path = "/api/v1/feedback";

    final url = URI().get(serverAddress, path);
    var request = http.MultipartRequest('POST', url);
    request.headers['Cookie'] = await Storage().readCookie() ?? '';
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

  Future<ResponseGetFeedbacks> getFeedbacks({String? text}) async {
    log.i("发送请求 获取反馈列表");
    final String path = "/api/v1/feedbacks";
    Map<String, String> param = {};
    if (text != null) {
      param = {
        "text": text,
      };
    }
    final Map<String, String> headers = {
      'Cookie': await Storage().readCookie() ?? '',
    };
    final url = URI().get(serverAddress, path, param: param);
    return _handleRequest<ResponseGetFeedbacks>(
      Method.get,
      url,
      (json) => ResponseGetFeedbacks.fromJson(json),
      headers: headers,
    );
  }

  Future<ReponsePostUserRegister> userRegister(RequestCreateUserRegister req) {
    log.i("发送请求 用户注册");
    final path = "/api/v1/user/register";

    final uri = URI().get(serverAddress, path);

    return _handleRequest(
      Method.post,
      uri,
      (g) => ReponsePostUserRegister.fromJson(g),
      data: req.toJson(),
      onResponse: _persistCookie,
    );
  }

  Future<ReponsePostUserRegister> userRegisterVisitor() {
    log.i("发送请求 游客注册");
    RequestCreateUserRegisterVisitor req = RequestCreateUserRegisterVisitor();

    final path = "/api/v1/user/register";
    final Map<String, String> param = {
      "visitor": "1",
    };

    final uri = URI().get(serverAddress, path, param: param);

    return _handleRequest(
      Method.post,
      uri,
      (g) => ReponsePostUserRegister.fromJson(g),
      data: req.toJson(),
      onResponse: _persistCookie,
    );
  }

  Future<ReponseUserLogin> userLogin(RequestUserLogin req) async {
    log.i("发送请求 用户登陆");
    final path = "/api/v1/user/login";
    final uri = URI().get(serverAddress, path);

    return _handleRequest(
      Method.post,
      uri,
      (g) => ReponseUserLogin.fromJson(g),
      data: req.toJson(),
      onResponse: _persistCookie,
    );
  }

  Future<ReponseGetUserInfo> userInfo() async {
    log.i("发送请求 获取用户信息");
    final path = "/api/v1/user/info";
    final uri = Uri.parse(serverAddress + path);
    final Map<String, String> header = {
      'Cookie': await Storage().readCookie() ?? '',
    };
    return _handleRequest(
      Method.get,
      uri,
      (g) => ReponseGetUserInfo.fromJson(g),
      headers: header,
    );
  }

  Future<ReponsePutUserProfile> userProfile(
      RequestUpdateUserProfile req) async {
    final path = "/api/v1/user/profile";
    final uri = URI().get(serverAddress, path);

    final Map<String, String> header = {
      'Cookie': await Storage().readCookie() ?? '',
      'Content-Type': 'multipart/form-data',
    };

    final http.MultipartRequest request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(header);
    if (req.nickname != null) {
      log.i("发送请求 更新用户昵称");
      request.fields['nickname'] = req.nickname!;
    }
    if (req.bytes != null && req.ext != null) {
      log.i("发送请求 更新用户头像");
      request.fields['ext'] = req.ext!;
      request.files.add(http.MultipartFile.fromBytes(
        'avatar',
        req.bytes!,
        filename: 'avatar.${req.ext}',
      ));
    }

    final http.StreamedResponse response = await request.send();
    if (response.statusCode != 200) {
      return ReponsePutUserProfile(err: 1, msg: getMsg(response.statusCode));
    }
    final String responseBody = await response.stream.bytesToString();
    if (responseBody.isEmpty) {
      return ReponsePutUserProfile(err: 1, msg: '未知错误');
    }

    final Map<String, dynamic> json = jsonDecode(responseBody);
    return ReponsePutUserProfile.fromJson(json);
  }

  // 解绑应用
  Future<Basic> unbindApp() async {
    log.i("发送请求 解绑应用");
    final path = "/api/v1/user/app";
    final uri = URI().get(serverAddress, path);
    final Map<String, String> header = {
      'Cookie': await Storage().readCookie() ?? '',
      'Content-Type': 'application/json',
    };
    return _handleRequest(
      Method.delete,
      uri,
      (g) => Basic.fromJson(g),
      headers: header,
      data: {"category": appNameEn},
    );
  }

  // 注销账户
  Future<Basic> deleteAccount() async {
    log.i("发送请求 注销账户");
    final path = "/api/v1/user/info";
    final uri = URI().get(serverAddress, path);
    final Map<String, String> header = {
      'Cookie': await Storage().readCookie() ?? '',
    };
    return _handleRequest(
      Method.delete,
      uri,
      (g) => Basic.fromJson(g),
      headers: header,
    );
  }

  String getAPI() {
    final api = Config().getAPIkey();
    if (api.isEmpty) {
      log.e("api key 为空");
      return '';
    }
    return api;
  }

  String getMsg(int statusCode) {
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

  // 关键步骤: 客户端保存cookie
  Future<void> _persistCookie(http.Response response) async {
    final cookie = _extractCookie(response.headers);
    if (cookie == null || cookie.isEmpty) {
      return;
    }
    log.i("提取到 cookie: $cookie");
    try {
      await Storage().writeCookie(cookie);
    } catch (e) {
      log.e("保存 cookie 失败: ${e.toString()}");
    }
  }

  String? _extractCookie(Map<String, String> headers) {
    final raw = headers['set-cookie'];
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final parsed = Cookie.fromSetCookieValue(raw);
      if (parsed.name.isEmpty) {
        return null;
      }
      return "${parsed.name}=${parsed.value}";
    } catch (_) {
      final fallback = raw.split(';').first.trim();
      return fallback.isEmpty ? null : fallback;
    }
  }
}
