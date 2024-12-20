import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whispering_time/env.dart';
import 'package:intl/intl.dart';

class Basic {
  int err;
  String msg;
  Basic({required this.err, required this.msg});
  bool isNotOK() {
    if (isOK()) {
      return false;
    }
    print(msg);
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
  String get uptime => Time.nowTimestampString();

  String id;
  RequestPutTheme({required this.name, required this.id});
  Map<String, dynamic> toJson() => {'name': name, 'id': id, 'uptime': uptime};
}

class ResponsePutTheme extends Basic {
  String id;

  ResponsePutTheme({required super.err, required super.msg, required this.id});
  factory ResponsePutTheme.fromJson(Map<String, dynamic> json) {
    return ResponsePutTheme(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] as String,
    );
  }
}

class RequestPostTheme {
  String name;
  String get crtime =>
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  RequestPostTheme({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
        'crtime': crtime,
      };
}

class ResponsePostTheme extends Basic {
  String id;
  ResponsePostTheme({required super.err, required super.msg, required this.id});
  factory ResponsePostTheme.fromJson(Map<String, dynamic> json) {
    return ResponsePostTheme(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] as String,
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
      id: json['data']['id'] as String,
    );
  }
}

class ResponsePutGroup extends Basic {
  String id;

  ResponsePutGroup({required super.err, required super.msg, required this.id});
  factory ResponsePutGroup.fromJson(Map<String, dynamic> json) {
    return ResponsePutGroup(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] as String,
    );
  }
}

class RequestPutGroup {
  String id;

  String? name;
  DateTime? overtime;
  RequestPutGroup({this.name, required this.id, this.overtime});
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'id': id, 'uptime': Time.nowTimestampString()};

    if (name != null) {
      data['name'] = name!;
    }
    if (overtime != null) {
      data['overtime'] = Time.toTimestampString(overtime!);
    } else {
      // 这里有加这个代码的必要性，来混淆（在加密数据后）一个PUT操作到底更新了什么。
      data['overtime'] = Time.toTimestampString(Time.getForver());
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
  int level;
  String crtimeStr;
  DateTime? crtime;
  String uptimeStr;
  String id;
  Doc({
    required this.title,
    required this.content,
    required this.level,
    required this.crtimeStr,
    required this.uptimeStr,
    required this.id,
    this.crtime,
  });

  factory Doc.fromJson(Map<String, dynamic> json) {
    return Doc(
      title: json['title'] as String,
      content: json['content'] as String,
      level: json['level'] as int,
      crtimeStr: json['crtime'] as String,
      uptimeStr: json['crtime'] as String,
      id: json['id'] as String,
    );
  }
  String getCreateTime() {
    if (crtimeStr.isEmpty) {
      return crtimeStr;
    }
    // 将字符串转换为整数
    int timestamp = int.parse(crtimeStr);

    // 创建 DateTime 对象
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timestamp *= 1000);
    // 使用 DateFormat 格式化日期和时间
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedDatetime = formatter.format(datetime);

    return formattedDatetime;
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
  String crtime;
  int level;
  RequestPostDoc(
      {required this.content,
      required this.title,
      required this.level,
      required this.crtime});

  Map<String, dynamic> toJson() =>
      {'content': content, 'title': title, 'level': level, 'crtime': crtime};
}
class ResponsePostDoc extends Basic {
  String id;
  ResponsePostDoc({required super.err, required super.msg, required this.id});
  factory ResponsePostDoc.fromJson(Map<String, dynamic> json) {
    return ResponsePostDoc(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] as String,
    );
  }
}

class RequestPutDoc {
  String id;
  String? content;
  String? title;
  int? level;
  String? crtime;
  String get uptime => Time.nowTimestampString();
  RequestPutDoc(
      {required this.id, this.title, this.content, this.level, this.crtime});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'id': id, 'uptime': uptime};

    if (content != null) {
      print("更新文档内容");
      data['content'] = content;
    }

    if (title != null) {
      print("更新文档标题");
      data['title'] = title;
    }

    if (crtime != null) {
      print("更新文档创建时间");
      data['crtime'] = crtime;
    }

    if (level != null) {
      print("更新文档等级");
      data['level'] = level;
    }
    return data;
  }
}

class ResponsePutDoc extends Basic {
  String id;
  ResponsePutDoc({required super.err, required super.msg, required this.id});
  factory ResponsePutDoc.fromJson(Map<String, dynamic> json) {
    return ResponsePutDoc(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] as String,
    );
  }
}

class RequestDeleteDoc {
  String did;
  String gid;
  RequestDeleteDoc({required this.gid, required this.did});
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

enum Method { get, post, put, delete }

class Http {
  final String? content;
  final String? tid;
  final String? gid;
  final String? docid;
  static final String uid = Settings().getuid();
  static final String serverAddress = Settings().getServerAddress();

  Http({this.content, this.tid, this.gid, this.docid});

  Future<T> _handleRequest<T>(
      Method method, Uri u, Function(Map<String, dynamic>) fromJson,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    // final Map<String, String> param = {
    //   'uid': uid,
    // };

    // final Map<String, dynamic> data = {
    //   'data': req.toJson(),
    //   if (method == Method.put || method == Method.post) "uptime": Time.nowTimestampString(),
    // };

    // final Map<String, String> headers = {
    //   "Content-Type": "application/json",
    // };

    // final Uri u = Uri.http(serverAddress, path, param);

    try {
      final http.Response response;
      switch (method) {
        case Method.get:
          response = await http.get(u);
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
          response = await http.delete(u);
          break;
      }
      print(response.body);
      final Map<String, dynamic> json = jsonDecode(response.body);
      return fromJson(json);
    } catch (e) {
      print(e.toString());
      // Msg.diy(context, "服务器连接错误");
      return fromJson({'err': 1, 'msg': ''});
    }
  }

  Future<ResponseGetTheme> gettheme() async {
    if (uid == "") {
      throw ArgumentError('缺少uid');
    }

    final Map<String, String> param = {
      'uid': uid,
    };

    final url = Uri.http(serverAddress, "/theme", param);

    return _handleRequest<ResponseGetTheme>(
      Method.get,
      url,
      (json) => ResponseGetTheme.fromJson(json),
    );
  }

  Future<ResponsePostTheme> posttheme(RequestPostTheme req) async {
    const String path = "/theme";
    final Map<String, String> param = {
      'uid': uid,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponsePostTheme>(
      Method.post,
      url,
      (json) => ResponsePostTheme.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutTheme> puttheme(RequestPutTheme req) async {
    const String path = "/theme";

    final Map<String, String> param = {
      'uid': uid,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
      "uptime": Time.nowTimestampString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponsePutTheme>(
      Method.put,
      url,
      (json) => ResponsePutTheme.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteTheme> deletetheme() async {
    const String path = "/theme";

    final Map<String, String> param = {
      'uid': uid,
      'tid': content!,
    };
    final url = Uri.http(serverAddress, path, param);
    return _handleRequest<ResponseDeleteTheme>(
        Method.delete, url, (json) => ResponseDeleteTheme.fromJson(json));
  }

  Future<ResponseGetGroup> getGroup() async {
    const String path = "/group";

    if (tid == null) {
      throw ArgumentError('缺少tid');
    }

    final Map<String, String> param = {
      'uid': uid,
      'tid': tid!,
    };

    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponseGetGroup>(
      Method.get,
      url,
      (json) => ResponseGetGroup.fromJson(json),
    );
  }

  Future<ResponseDeleteGroup> deleteGroup() async {
    const String path = "/group";

    final Map<String, String> param = {'uid': uid, 'gid': gid!};
    final url = Uri.http(serverAddress, path, param);
    return _handleRequest<ResponseDeleteGroup>(
      Method.delete,
      url,
      (json) => ResponseDeleteGroup.fromJson(json),
    );
  }

  Future<ResponsePostGroup> postGroup(RequestPostGroup req) async {
    const String path = "/group";

    if (tid == null) {
      throw ArgumentError('缺少tid');
    }

    final Map<String, String> param = {
      'uid': uid,
      'tid': tid!,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
      "crtime": Time.nowTimestampString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponsePostGroup>(
      Method.post,
      url,
      (json) => ResponsePostGroup.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutGroup> putGroup(RequestPutGroup req) async {
    if (tid == null) {
      throw ArgumentError('缺少tid');
    }
    const String path = "/group";

    final Map<String, String> param = {
      'uid': uid,
      'tid': tid!,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponsePutGroup>(
      Method.put,
      url,
      (json) => ResponsePutGroup.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseGetDoc> getDocs() async {
    print("获取分组的日志列表");

    if (gid == null) {
      throw ArgumentError('缺少gid');
    }

    final Map<String, String> param = {
      'uid': uid,
      'gid': gid!,
    };

    final url = Uri.http(serverAddress, "/docs", param);

    final  res = await  _handleRequest<ResponseGetDoc>(
      Method.get,
      url,
      (json) => ResponseGetDoc.fromJson(json),
    );

    if (res.isOK()) {
      for (Doc line in res.data) {
        line.crtime = Time.datetime(line.crtimeStr);
      }
    }

    return res;
  }

  Future<ResponsePostDoc> postDoc(RequestPostDoc req) async {
    print("创建印迹");
    if (gid == null) {
      throw ArgumentError('缺少gid');
    }
    const String path = "/doc";
    final Map<String, String> param = {
      'uid': uid,
      'gid': gid!,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
      "crtime": Time.nowTimestampString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final url = Uri.http(serverAddress, path, param);
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
    if (tid == null) {
      throw ArgumentError('缺少tid');
    }
    const String path = "/doc";

    final Map<String, String> param = {
      'uid': uid,
      'gid': gid!,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(serverAddress, path, param);
    return _handleRequest<ResponsePutDoc>(
      Method.put,
      url,
      (json) => ResponsePutDoc.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteDoc> deleteDoc(RequestDeleteDoc req) async {
    print("删除文档");
    const String path = "/doc";

    final Map<String, String> param = {
      'uid': uid,
      'gid': req.gid,
      'did': req.did
    };
    final url = Uri.http(serverAddress, path, param);
    return _handleRequest<ResponseDeleteDoc>(
      Method.delete,
      url,
      (json) => ResponseDeleteDoc.fromJson(json),
    );
  }
}
