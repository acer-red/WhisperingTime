import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/pages/theme/group/doc/setting.dart';

enum Method { get, post, put, delete }

class Basic {
  int err;
  String msg;
  Basic({required this.err, required this.msg});

  bool get isNotOK => err != 0;

  bool get isOK => err == 0;

  void getmsg() {
    print(msg);
  }
}

// theme
class ResponseGetThemes extends Basic {
  List<ThemeListData> data;
  ResponseGetThemes(
      {required super.err, required super.msg, required this.data});
  factory ResponseGetThemes.fromJson(Map<String, dynamic> json) {
    return ResponseGetThemes(
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

class ResponseGetThemesAndDataX extends Basic {
  List<XTheme> data;

  ResponseGetThemesAndDataX({
    required super.err,
    required super.msg,
    required this.data,
  });

  factory ResponseGetThemesAndDataX.fromJson(Map<String, dynamic> json) {
    return ResponseGetThemesAndDataX(
      err: json['err'] as int,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => XTheme.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ResponseGetThemesAndDataD extends Basic {
  List<DTheme> data;

  ResponseGetThemesAndDataD({
    required super.err,
    required super.msg,
    required this.data,
  });

  factory ResponseGetThemesAndDataD.fromJson(Map<String, dynamic> json) {
    return ResponseGetThemesAndDataD(
      err: json['err'] as int,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => DTheme.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DTheme {
  final String tid;
  final String name;
  final List<DGroup> groups;

  DTheme({
    required this.tid,
    required this.name,
    required this.groups,
  });

  factory DTheme.fromJson(Map<String, dynamic> json) {
    return DTheme(
      tid: json['tid'] as String,
      name: json['theme_name'] as String,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => DGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DGroup {
  final String gid;
  final String name;
  final List<DDoc> docs;

  DGroup({
    required this.gid,
    required this.name,
    required this.docs,
  });

  factory DGroup.fromJson(Map<String, dynamic> json) {
    return DGroup(
      gid: json['gid'] as String,
      name: json['name'] as String,
      docs: (json['docs'] as List<dynamic>)
          .map((e) => DDoc.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DDoc {
  final String id;
  final String plainText;
  final String title;
  final String content;
  final int level;
  final DateTime crtime;
  final DateTime uptime;
  String get crtimeString => DateFormat('yyyy-MM-dd HH:mm').format(crtime);
  String get levelString => Level.string(level);
  DDoc({
    required this.id,
    required this.plainText,
    required this.title,
    required this.content,
    required this.level,
    required this.crtime,
    required this.uptime,
  });

  factory DDoc.fromJson(Map<String, dynamic> json) {
    return DDoc(
      id: json['did'] as String,
      plainText: json['plain_text'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      level: json['level'] as int,
      crtime: Time.stringToTimeHasT(json['crtime'] as String),
      uptime: Time.stringToTimeHasT(json['uptime'] as String),
    );
  }
}

class XTheme {
  final String tid;
  final String name;
  final List<XGroup> groups;

  XTheme({
    required this.tid,
    required this.name,
    required this.groups,
  });

  factory XTheme.fromJson(Map<String, dynamic> json) {
    return XTheme(
      tid: json['tid'] as String,
      name: json['theme_name'] as String,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => XGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class XGroup {
  final String gid;
  final String name;
  final List<XDoc> docs;

  XGroup({
    required this.gid,
    required this.name,
    required this.docs,
  });

  factory XGroup.fromJson(Map<String, dynamic> json) {
    return XGroup(
      gid: json['gid'] as String,
      name: json['name'] as String,
      docs: (json['docs'] as List<dynamic>)
          .map((e) => XDoc.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class XDoc {
  final String did;
  final String plainText;
  final String title;
  final int level;
  final DateTime crtime;
  final DateTime uptime;
  String get crtimeString => DateFormat('yyyy-MM-dd HH:mm').format(crtime);
  String get levelString => Level.string(level);
  XDoc({
    required this.did,
    required this.plainText,
    required this.title,
    required this.level,
    required this.crtime,
    required this.uptime,
  });

  factory XDoc.fromJson(Map<String, dynamic> json) {
    return XDoc(
      did: json['did'] as String,
      plainText: json['plain_text'] as String,
      title: json['title'] as String,
      level: json['level'] as int,
      crtime: Time.stringToTimeHasT(json['crtime'] as String),
      uptime: Time.stringToTimeHasT(json['uptime'] as String),
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
class ResponseGetGroupAndDocDetail extends Basic {
  DGroup data;
  ResponseGetGroupAndDocDetail(
      {required super.err, required super.msg, required this.data});
  factory ResponseGetGroupAndDocDetail.fromJson(Map<String, dynamic> json) {

    return ResponseGetGroupAndDocDetail(
        err: json['err'] as int,
        msg: json['msg'] as String,
        data: json['data'] != null
            ? DGroup.fromJson(json['data'] as Map<String, dynamic>)
            : DGroup(gid: "", name: "", docs: List.empty()));
  }
}

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
      print("更新分组名:$name");
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
      crtime: Time.stringToTime(json['crtime'] as String),
      uptime: Time.stringToTime(json['uptime'] as String),
      overtime: Time.stringToTime(json['overtime'] as String),
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
  int get day => crtime.day;
  String get levelString => Level.string(level);
  String get crtimeString => DateFormat('yyyy-MM-dd HH:mm').format(crtime);
  String get uptimeString => DateFormat('yyyy-MM-dd HH:mm').format(uptime);
  late bool isSearch;
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
      crtime: Time.stringToTime(json['crtime'] as String),
      uptime: Time.stringToTime(json['uptime'] as String),
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
      {this.title,
      this.content,
      this.plainText,
      this.level,
      this.crtime,
      this.config});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'uptime': Time.toTimestampString(uptime)};

    if (content != null) {
      data['content'] = content;
      data['plain_text'] = plainText;
    }

    if (title != null) {
      data['title'] = title;
    }

    if (crtime != null) {
      data['crtime'] = Time.toTimestampString(crtime!);
    }

    if (level != null) {
      data['level'] = level;
    }
    if (config != null) {
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

// image
class RequestPostImage {
  String name;
  Uint8List data;
  RequestPostImage({required this.name, required this.data});
}

class ResponsePostImage {
  bool ok;
  String data;
  ResponsePostImage({required this.ok, required this.data});
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
  Future<ResponseGetThemes> getthemes() async {
    log.i("发送请求 获取主题列表");
    const String path = "/themes";

    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path);

    return _handleRequest<ResponseGetThemes>(
        Method.get, url, (json) => ResponseGetThemes.fromJson(json),
        headers: headers);
  }

  Future<ResponseGetThemesAndDataX> getThemesAndDoc() async {
    log.i("发送请求 获取主题列表和印迹");

    const String path = "/themes";
    const Map<String, String> param = {
      "doc": "1",
    };
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponseGetThemesAndDataX>(
        Method.get, url, (json) => ResponseGetThemesAndDataX.fromJson(json),
        headers: headers);
  }

  Future<ResponseGetThemesAndDataD> getThemesAndDocDetail() async {
    log.i("发送请求 获取主题列表和印迹（详细数据）");

    const String path = "/themes";
    const Map<String, String> param = {
      "doc": "1",
      "detail": "1",
    };
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponseGetThemesAndDataD>(
        Method.get, url, (json) => ResponseGetThemesAndDataD.fromJson(json),
        headers: headers);
  }

  Future<ResponsePostTheme> posttheme(RequestPostTheme req) async {
    log.i("发送请求 创建主题");
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
    log.i("发送请求 更新主题");
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
    log.i("发送请求 删除主题");
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
    log.i("发送请求 获取所有分组");

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

  Future<ResponseGetGroupAndDocDetail> getGroupAndDocDetail() async {
    log.i("发送请求 获取所有分组和印迹（详细数据）");

    String path = "/group/${tid!}/${gid!}";

    if (tid == null) {
      log.e('缺少tid');
    }

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final Map<String, String> param = {
      "doc": "1",
      "detail": "1",
    };
    final url = Uri.http(serverAddress, path, param);

    return _handleRequest<ResponseGetGroupAndDocDetail>(
        Method.get, url, (json) => ResponseGetGroupAndDocDetail.fromJson(json),
        headers: headers);
  }

  Future<ResponsePostGroup> postGroup(RequestPostGroup req) async {
    log.i("发送请求 创建分组");
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
    log.i("发送请求 更新分组");
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
    log.i("发送请求 删除分组");
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
  Future<ResponseGetDoc> getDocs(int? year, int? month) async {
    log.i("发送请求 获取分组的日志列表");

    String path = "/docs/${gid!}";
    if (year != null) {
      if (month != null) {
        path += "?year=$year&month=$month";
      } else {
        path += "?year=$year";
      }
    }

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

    // if (res.isOK) {
    //   for (Doc line in res.data) {
    //     line.crtime = line.crtime;
    //   }
    // }

    return res;
  }

  Future<ResponsePostDoc> postDoc(RequestPostDoc req) async {
    log.i("发送请求 创建印迹");

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
    log.i("发送请求 更新文档");

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
    log.i("发送请求 删除文档");
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

  // image
  Future<ResponsePostImage> postImage(RequestPostImage req) async {
    log.i("发送请求 上传图片");

    String path = "/image/${req.name}";

    final url = Uri.http(serverAddress, path);
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };

    Response response = await http.post(url, headers: headers, body: req.data);
    int status = response.statusCode;
    ResponsePostImage ret = ResponsePostImage(
        ok: status == 200, data: status == 200 ? response.body : "");

    return ret;
  }
}
