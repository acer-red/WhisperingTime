import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whispering_time/env.dart';
import 'package:whispering_time/page/theme/group/doc/setting.dart';

enum Method { get, post, put, delete }

class Basic {
  int err;
  String msg;
  Basic({required this.err, required this.msg});
  bool isNotOK() {
    if (isOK()) {
      return false;
    }
    return true;
  }

  bool isOK() {
    return err == 0;
  }

  void getmsg() {
    print(msg);
  }
}

// theme
class ResponseGetTheme extends Basic {
  List<ThemeListData> data;
  ResponseGetTheme(
      {required super.err, required super.msg, required this.data});
  factory ResponseGetTheme.fromJson(Map<String, dynamic> json) {
    return ResponseGetTheme(
      err: json['err'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) =>
                  ThemeListData.fromJson(item as Map<String, dynamic>))
              .toList()
          : List.empty(),
    );
  }
}

class RequestPutTheme {
  String name;
  RequestPutTheme({required this.name});
  Map<String, dynamic> toJson() =>
      {'name': name, 'uptime': Time.nowTimestampString()};
}

class ResponsePutTheme extends Basic {
  ResponsePutTheme({required super.err, required super.msg});
  factory ResponsePutTheme.fromJson(Map<String, dynamic> json) {
    return ResponsePutTheme(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class RequestPostThemeDefaultGroup {
  String name;
  RequestPostThemeDefaultGroup({required this.name});
  Map<String, dynamic> toJson() => {
        'name': name,
        'crtime': Time.nowTimestampString(),
        'overtime': Time.toTimestampString(Time.getForver())
      };
}

class RequestPostTheme {
  String name;
  RequestPostTheme({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
        'crtime': Time.nowTimestampString(),
        'default_group':
            RequestPostThemeDefaultGroup(name: defaultGroupName).toJson()
      };
}

class ResponsePostTheme extends Basic {
  String id;
  ResponsePostTheme({required super.err, required super.msg, required this.id});
  factory ResponsePostTheme.fromJson(Map<String, dynamic> json) {
    return ResponsePostTheme(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] == null ? "" : json['data']['id'] as String,
    );
  }
}

class ResponseDeleteTheme extends Basic {
  ResponseDeleteTheme({required super.err, required super.msg});
  factory ResponseDeleteTheme.fromJson(Map<String, dynamic> json) {
    return ResponseDeleteTheme(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class ThemeListData {
  String name;
  String id;
  ThemeListData({required this.name, required this.id});

  factory ThemeListData.fromJson(Map<String, dynamic> json) {
    return ThemeListData(
      name: json['name'] as String,
      id: json['id'] as String,
    );
  }
}

// group
class ResponseGetGroup extends Basic {
  List<GroupListData> data;
  ResponseGetGroup(
      {required super.err, required super.msg, required this.data});
  factory ResponseGetGroup.fromJson(Map<String, dynamic> json) {
    return ResponseGetGroup(
        err: json['err'] as int,
        msg: json['msg'] as String,
        data: json['data'] != null
            ? (json['data'] as List<dynamic>)
                .map((item) =>
                    GroupListData.fromJson(item as Map<String, dynamic>))
                .toList()
            : List.empty());
  }
}

class ResponsePostGroup extends Basic {
  String id;
  ResponsePostGroup({required super.err, required super.msg, required this.id});
  factory ResponsePostGroup.fromJson(Map<String, dynamic> json) {
    return ResponsePostGroup(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] == null ? "" : json['data']['id'] as String,
    );
  }
}

class ResponsePutGroup extends Basic {
  ResponsePutGroup({required super.err, required super.msg});
  factory ResponsePutGroup.fromJson(Map<String, dynamic> json) {
    return ResponsePutGroup(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class RequestPutGroup {
  String? name;
  DateTime? overtime;
  RequestPutGroup({this.name, this.overtime});
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'uptime': Time.nowTimestampString()};

    if (name != null) {
      print("更新分组名,$name");
      data['name'] = name!;
    }
    if (overtime != null) {
      print("更新定格时间,$overtime");
      data['overtime'] = Time.toTimestampString(overtime!);
    }
    return data;
  }
}

class RequestPostGroup {
  String name;
  DateTime overtime = Time.getForver();

  RequestPostGroup({required this.name});
  Map<String, dynamic> toJson() => {
        'name': name,
        'crtime': Time.nowTimestampString(),
        'uptime': Time.nowTimestampString(),
        'overtime': Time.toTimestampString(overtime)
      };
}

class ResponseDeleteGroup extends Basic {
  ResponseDeleteGroup({required super.err, required super.msg});
  factory ResponseDeleteGroup.fromJson(Map<String, dynamic> json) {
    return ResponseDeleteGroup(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class GroupListData {
  String name;
  String id;
  DateTime crtime;
  DateTime uptime;
  DateTime overtime;
  GroupListData(
      {required this.name,
      required this.id,
      required this.crtime,
      required this.overtime,
      required this.uptime});

  factory GroupListData.fromJson(Map<String, dynamic> json) {
    return GroupListData(
      name: json['name'] as String,
      id: json['id'] as String,
      crtime: Time.datetime(json['crtime'] as String),
      uptime: Time.datetime(json['uptime'] as String),
      overtime: Time.datetime(json['overtime'] as String),
    );
  }
}

// doc
class Doc {
  String title;
  String content;
  String plainText;
  int level;
  DateTime crtime;
  DateTime uptime;
  DocConfigration config;
  String id;
  Doc({
    required this.title,
    required this.content,
    required this.plainText,
    required this.level,
    required this.crtime,
    required this.uptime,
    required this.config,
    required this.id,
  });

  factory Doc.fromJson(Map<String, dynamic> json) {
    return Doc(
      title: json['title'] as String,
      content: json['content'] as String,
      plainText: json['plain_text'] as String,
      level: json['level'] as int,
      crtime: Time.datetime(json['crtime'] as String),
      uptime: Time.datetime(json['uptime'] as String),
      config:
          DocConfigration(isShowTool: json['config']['is_show_tool'] as bool),
      id: json['id'] as String,
    );
  }
}

class ResponseGetDoc extends Basic {
  List<Doc> data;
  ResponseGetDoc({required super.err, required super.msg, required this.data});
  factory ResponseGetDoc.fromJson(Map<String, dynamic> json) {
    return ResponseGetDoc(
      err: json['err'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) => Doc.fromJson(item as Map<String, dynamic>))
              .toList()
          : List.empty(), // Handle null case,
    );
  }
}

class RequestPostDoc {
  String title;
  String content;
  String plainText;
  DateTime crtime;
  int level;
  DocConfigration config;
  RequestPostDoc(
      {required this.content,
      required this.title,
      required this.plainText,
      required this.crtime,
      required this.level,
      required this.config});

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'plain_text': plainText,
        'level': level,
        'crtime': Time.toTimestampString(crtime),
        'config': config.toJson(),
      };
}

class ResponsePostDoc extends Basic {
  String id;
  ResponsePostDoc({required super.err, required super.msg, required this.id});
  factory ResponsePostDoc.fromJson(Map<String, dynamic> json) {
    return ResponsePostDoc(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] == null ? "" : json['data']['id'] as String,
    );
  }
}

class RequestPutDoc {
  String? content;
  String? title;
  String? plainText;
  int? level;
  DateTime? crtime;
  DocConfigration? config;
  DateTime get uptime => DateTime.now();
  RequestPutDoc(
      {this.title, this.content, this.plainText, this.level, this.crtime,this.config});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'uptime': Time.toTimestampString(uptime)};

    if (content != null) {
      print("更新文档内容");
      data['content'] = content;
      data['plain_text'] = plainText;
    }

    if (title != null) {
      print("更新文档标题");
      data['title'] = title;
    }

    if (crtime != null) {
      print("更新文档创建时间");
      data['crtime'] = Time.toTimestampString(crtime!);
    }

    if (level != null) {
      print("更新文档等级");
      data['level'] = level;
    }
    if (config!=null){
      print("更新文档配置");
      data['config'] = config!.toJson();
    }
    return data;
  }
}

class ResponsePutDoc extends Basic {
  ResponsePutDoc({required super.err, required super.msg});
  factory ResponsePutDoc.fromJson(Map<String, dynamic> json) {
    return ResponsePutDoc(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class ResponseDeleteDoc extends Basic {
  ResponseDeleteDoc({required super.err, required super.msg});
  factory ResponseDeleteDoc.fromJson(Map<String, dynamic> json) {
    return ResponseDeleteDoc(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class Http {
  final String? content;
  final String? tid;
  final String? gid;
  final String? did;
  static final String uid = Settings().getuid();
  static final String serverAddress = Settings().getServerAddress();

  Http({this.content, this.tid, this.gid, this.did});
  String getAuthorization() {
    final credentials = '$uid:';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

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

  // theme
  Future<ResponseGetTheme> getthemes() async {
    String path = "/themes";

    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponseGetTheme>(
        Method.get, url, (json) => ResponseGetTheme.fromJson(json),
        headers: headers);
  }

  Future<ResponsePostTheme> posttheme(RequestPostTheme req) async {
    String path = "/theme";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponsePostTheme>(
      Method.post,
      url,
      (json) => ResponsePostTheme.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutTheme> puttheme(RequestPutTheme req) async {
    String path = "/theme/${tid!}";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponsePutTheme>(
      Method.put,
      url,
      (json) => ResponsePutTheme.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteTheme> deletetheme() async {
    String path = "/theme/${tid!}";

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);
    return _handleRequest<ResponseDeleteTheme>(
        Method.delete, url, (json) => ResponseDeleteTheme.fromJson(json),
        headers: headers);
  }

  // group
  Future<ResponseGetGroup> getGroups() async {
    String path = "/groups/${tid!}";

    if (tid == null) {
      log.e('缺少tid');
    }

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };

    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponseGetGroup>(
        Method.get, url, (json) => ResponseGetGroup.fromJson(json),
        headers: headers);
  }

  Future<ResponsePostGroup> postGroup(RequestPostGroup req) async {
    String path = "/group/${tid!}";

    if (tid == null) {
      log.e('缺少tid');
    }

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponsePostGroup>(
      Method.post,
      url,
      (json) => ResponsePostGroup.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutGroup> putGroup(RequestPutGroup req) async {
    if (tid == null || gid == null) {
      log.e('缺少参数');
    }

    String path = "/group/${tid!}/${gid!}";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponsePutGroup>(
      Method.put,
      url,
      (json) => ResponsePutGroup.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteGroup> deleteGroup() async {
    if (tid == null || gid == null) {
      log.e('缺少参数');
    }

    String path = "/group/${tid!}/${gid!}";

    final Map<String, String> headers = {
      "Authorization": getAuthorization(),
    };

    final url = Uri.http(serverAddress, path);
    return _handleRequest<ResponseDeleteGroup>(
        Method.delete, url, (json) => ResponseDeleteGroup.fromJson(json),
        headers: headers);
  }

  // doc
  Future<ResponseGetDoc> getDocs() async {
    print("获取分组的日志列表");

    String path = "/docs/${gid!}";

    final url = Uri.http(serverAddress, path);
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };

    final res = await _handleRequest<ResponseGetDoc>(
      Method.get,
      url,
      (json) => ResponseGetDoc.fromJson(json),
      headers: headers,
    );

    if (res.isOK()) {
      for (Doc line in res.data) {
        line.crtime = line.crtime;
      }
    }

    return res;
  }

  Future<ResponsePostDoc> postDoc(RequestPostDoc req) async {
    print("创建印迹");

    String path = "/doc/${gid!}";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);
    return _handleRequest<ResponsePostDoc>(
      Method.post,
      url,
      (json) => ResponsePostDoc.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutDoc> putDoc(RequestPutDoc req) async {
    print("更新文档");

    String path = "/doc/${gid!}/${did!}";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);
    return _handleRequest<ResponsePutDoc>(
      Method.put,
      url,
      (json) => ResponsePutDoc.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteDoc> deleteDoc() async {
    print("删除文档");
    String path = "/doc/${gid!}/${did!}";
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(
      serverAddress,
      path,
    );
    return _handleRequest<ResponseDeleteDoc>(
      Method.delete,
      url,
      (json) => ResponseDeleteDoc.fromJson(json),
      headers: headers,
    );
  }
}
