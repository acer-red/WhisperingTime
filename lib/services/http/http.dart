import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/pages/doc/setting.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'base.dart';

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
  final DateTime createAt;
  final DateTime updateAt;
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get levelString => Level.string(level);
  DDoc({
    required this.id,
    required this.plainText,
    required this.title,
    required this.content,
    required this.level,
    required this.createAt,
    required this.updateAt,
  });

  factory DDoc.fromJson(Map<String, dynamic> json) {
    return DDoc(
      id: json['did'] as String,
      plainText: json['plain_text'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      level: json['level'] as int,
      createAt: Time.stringToTimeHasT(json['createAt'] as String),
      updateAt: Time.stringToTimeHasT(json['updateAt'] as String),
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
  final DateTime createAt;
  final DateTime updateAt;
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get levelString => Level.string(level);
  XDoc({
    required this.did,
    required this.plainText,
    required this.title,
    required this.level,
    required this.createAt,
    required this.updateAt,
  });

  factory XDoc.fromJson(Map<String, dynamic> json) {
    return XDoc(
      did: json['did'] as String,
      plainText: json['plain_text'] as String,
      title: json['title'] as String,
      level: json['level'] as int,
      createAt: Time.stringToTimeHasT(json['createAt'] as String),
      updateAt: Time.stringToTimeHasT(json['updateAt'] as String),
    );
  }
}

class RequestPutTheme {
  String name;
  RequestPutTheme({required this.name});
  Map<String, dynamic> toJson() =>
      {'name': name, 'updateAt': Time.nowTimestampString()};
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
        'createAt': Time.nowTimestampString(),
        'overtime': Time.toTimestampString(Time.getForver())
      };
}

class RequestPostTheme {
  String name;
  RequestPostTheme({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
        'createAt': Time.nowTimestampString(),
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
class GroupConfigNULL {
  bool? isMulti;
  bool? isAll;
  List<bool>? levels = [];
  int? viewType;
  GroupConfigNULL({this.isMulti, this.isAll, this.levels, this.viewType});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (isMulti != null) {
      data['is_multi'] = isMulti;
    }
    if (isAll != null) {
      data['is_all'] = isAll;
    }
    if (levels != null) {
      if (levels!.isNotEmpty) {
        data['levels'] = levels;
      }
    }
    if (viewType != null) {
      data['view_type'] = viewType;
    }

    return data;
  }
}

class GroupConfig {
  bool isMulti;
  bool isAll;
  List<bool> levels = [];
  int viewType;
  GroupConfig(
      {required this.isMulti,
      required this.isAll,
      required this.levels,
      required this.viewType});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['is_multi'] = isMulti;
    data['is_all'] = isAll;
    if (levels.isNotEmpty) {
      data['levels'] = levels;
    }
    data['view_type'] = viewType;
    return data;
  }

  static GroupConfig getDefault() {
    return GroupConfig(
        isAll: false,
        isMulti: false,
        levels: [true, false, false, false, false],
        viewType: 0);
  }
}

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
  GroupConfigNULL? config;
  RequestPutGroup({this.name, this.overtime, this.config});
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'updateAt': Time.nowTimestampString()};

    if (name != null) {
      print("更新分组名:$name");
      data['name'] = name!;
    }
    if (overtime != null) {
      print("更新定格时间,$overtime");
      data['overtime'] = Time.toTimestampString(overtime!);
    }
    if (config != null) {
      print("更新分组配置选项");
      data['config'] = config!.toJson();
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
        'createAt': Time.nowTimestampString(),
        'updateAt': Time.nowTimestampString(),
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
  DateTime createAt;
  DateTime updateAt;
  DateTime overtime;
  GroupConfig config;
  GroupListData({
    required this.name,
    required this.id,
    required this.createAt,
    required this.overtime,
    required this.updateAt,
    required this.config,
  });

  factory GroupListData.fromJson(Map<String, dynamic> json) {
    return GroupListData(
      name: json['name'] as String,
      id: json['id'] as String,
      createAt: Time.stringToTime(json['createAt'] as String),
      updateAt: Time.stringToTime(json['updateAt'] as String),
      overtime: Time.stringToTime(json['overtime'] as String),
      config: GroupConfig(
        isMulti: json['config']['isMulti'] as bool,
        isAll: json['config']['isAll'] as bool,
        levels: (json['config']['levels'] as List<dynamic>)
            .map((e) => e as bool)
            .toList(),
        viewType: json['config']['viewType'] as int,
      ),
    );
  }
}

class ResponseExportGroupConfig extends Basic {
  ResponseExportGroupConfig({required super.err, required super.msg});
  factory ResponseExportGroupConfig.fromJson(Map<String, dynamic> json) {
    return ResponseExportGroupConfig(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class ResponseImportGroupConfig extends Basic {
  ResponseImportGroupConfig({required super.err, required super.msg});
  factory ResponseImportGroupConfig.fromJson(Map<String, dynamic> json) {
    return ResponseImportGroupConfig(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

// doc
class Doc {
  String title;
  String content;
  String plainText;
  int level;
  DateTime createAt;
  DateTime updateAt;
  DocConfigration config;
  String id;
  int get day => createAt.day;
  String get levelString => Level.string(level);
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get updateAtString => DateFormat('yyyy-MM-dd HH:mm').format(updateAt);
  late bool isSearch;
  Doc({
    required this.title,
    required this.content,
    required this.plainText,
    required this.level,
    required this.createAt,
    required this.updateAt,
    required this.config,
    required this.id,
  });

  factory Doc.fromJson(Map<String, dynamic> json) {
    return Doc(
      title: json['title'] as String,
      content: json['content'] as String,
      plainText: json['plain_text'] as String,
      level: json['level'] as int,
      createAt: Time.stringToTime(json['createAt'] as String),
      updateAt: Time.stringToTime(json['updateAt'] as String),
      config:
          DocConfigration(isShowTool: json['config']['is_show_tool'] as bool),
      id: json['id'] as String,
    );
  }
}

class ResponseGetDocs extends Basic {
  List<Doc> data;
  ResponseGetDocs({required super.err, required super.msg, required this.data});
  factory ResponseGetDocs.fromJson(Map<String, dynamic> json) {
    return ResponseGetDocs(
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

class ResponseGetDoc extends Basic {
  String id;
  ResponseGetDoc({required super.err, required super.msg, required this.id});
  factory ResponseGetDoc.fromJson(Map<String, dynamic> json) {
    return ResponseGetDoc(
        err: json['err'] as int,
        msg: json['msg'] as String,
        id: json['id'] != null ? json['id'] as String : "");
  }
}

class RequestPostDoc {
  String title;
  String content;
  String plainText;
  DateTime createAt;
  int level;
  DocConfigration config;
  RequestPostDoc(
      {required this.content,
      required this.title,
      required this.plainText,
      required this.createAt,
      required this.level,
      required this.config});

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'plain_text': plainText,
        'level': level,
        'createAt': Time.toTimestampString(createAt),
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
  DateTime? createAt;
  DocConfigration? config;
  DateTime get updateAt => DateTime.now();
  RequestPutDoc(
      {this.title,
      this.content,
      this.plainText,
      this.level,
      this.createAt,
      this.config});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'updateAt': Time.toTimestampString(updateAt)};

    if (content != null) {
      data['content'] = content;
      data['plain_text'] = plainText;
    }

    if (title != null) {
      data['title'] = title;
    }

    if (createAt != null) {
      data['createAt'] = Time.toTimestampString(createAt!);
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
class ResponseDeleteImage extends Basic {
  ResponseDeleteImage({required super.err, required super.msg});
  factory ResponseDeleteImage.fromJson(Map<String, dynamic> json) {
    return ResponseDeleteImage(
      err: json['err'] as int,
      msg: json['msg'] as String,
    );
  }
}

class RequestPostImage {
  IMGType type;
  Uint8List data;
  RequestPostImage({required this.type, required this.data});
}

class ResponsePostImage extends Basic {
  final String name;
  final String url;
  ResponsePostImage(
      {required super.err,
      required super.msg,
      required this.name,
      required this.url});
  factory ResponsePostImage.fromJson(Map<String, dynamic> json) {
    return ResponsePostImage(
      err: json['err'] as int,
      msg: json['msg'] as String,
      name: json['data']['name'] as String,
      url: json['data']['url'] as String,
    );
  }
  String get imageFullUrl => url;
}

// 后台任务
class BackgroundJob {
  final String id;
  final String name;
  final String jobType;
  final String status;
  final String createdAt;
  final String? startedAt;
  final String? completedAt;
  final Map<String, dynamic>? result;
  final JobError? error;
  final int priority;
  final int retryCount;

  BackgroundJob({
    required this.id,
    required this.name,
    required this.jobType,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.result,
    this.error,
    required this.priority,
    required this.retryCount,
  });

  factory BackgroundJob.fromJson(Map<String, dynamic> json) {
    return BackgroundJob(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      jobType: json['jobType'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] != null ? JobError.fromJson(json['error']) : null,
      priority: json['priority'] ?? 0,
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

class JobError {
  final int code;
  final String message;

  JobError({
    required this.code,
    required this.message,
  });

  factory JobError.fromJson(Map<String, dynamic> json) {
    return JobError(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class ResponseGetBackgroundJobs extends Basic {
  final List<BackgroundJob> jobs;

  ResponseGetBackgroundJobs({
    required super.err,
    required super.msg,
    required this.jobs,
  });

  factory ResponseGetBackgroundJobs.fromJson(Map<String, dynamic> json) {
    return ResponseGetBackgroundJobs(
      err: json['err'] as int,
      msg: json['msg'] as String,
      jobs: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) =>
                  BackgroundJob.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class ResponseDownloadBackgroundJobFile extends Basic {
  final Uint8List? data;
  final String? filename;

  ResponseDownloadBackgroundJobFile({
    required super.err,
    required super.msg,
    this.data,
    this.filename,
  });
}

class Http {
  final String? content;
  final String? tid;
  final String? gid;
  final String? did;
  final String uid = Config.instance.uid;
  final String serverAddress = Config.instance.serverAddress;

  Http({this.content, this.tid, this.gid, this.did});

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

  String getAuthorization() {
    final credentials = '$uid:';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  // theme
  Future<ResponseGetThemes> getthemes() async {
    log.i("发送请求 获取主题列表");
    const String path = "/themes";

    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);

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
    final url = URI().get(serverAddress, path, param: param);

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
    final url = URI().get(serverAddress, path, param: param);

    return _handleRequest<ResponseGetThemesAndDataD>(
        Method.get, url, (json) => ResponseGetThemesAndDataD.fromJson(json),
        headers: headers);
  }

  Future<ResponsePostTheme> postTheme(RequestPostTheme req) async {
    log.i("发送请求 创建主题");
    String path = "/theme";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);

    return _handleRequest<ResponsePostTheme>(
      Method.post,
      url,
      (json) => ResponsePostTheme.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutTheme> putTheme(RequestPutTheme req) async {
    log.i("发送请求 更新主题");
    String path = "/theme/${tid!}";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);

    return _handleRequest<ResponsePutTheme>(
      Method.put,
      url,
      (json) => ResponsePutTheme.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteTheme> deleteTheme() async {
    log.i("发送请求 删除主题");
    String path = "/theme/${tid!}";

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);
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

    final url = URI().get(serverAddress, path);

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
    final url = URI().get(serverAddress, path, param: param);

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
    final url = URI().get(serverAddress, path);

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
    final url = URI().get(serverAddress, path);

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

    final url = URI().get(serverAddress, path);
    return _handleRequest<ResponseDeleteGroup>(
        Method.delete, url, (json) => ResponseDeleteGroup.fromJson(json),
        headers: headers);
  }

  Future<ResponseExportGroupConfig> exportGroupConfig() async {
    log.i("发送请求 导出分组配置");
    String path = "/group/${tid!}/${gid!}/export_config";

    final Map<String, String> headers = {
      "Authorization": getAuthorization(),
    };

    final url = URI().get(serverAddress, path);
    return _handleRequest<ResponseExportGroupConfig>(
      Method.post,
      url,
      (json) => ResponseExportGroupConfig.fromJson(json),
      headers: headers,
    );
  }

  Future<ResponseImportGroupConfig> importGroupConfig(String filePath) async {
    log.i("发送请求 导入分组配置");
    String path = "/group/${tid!}/from_config";

    final url = URI().get(serverAddress, path);
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = getAuthorization();
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseBody);
    return ResponseImportGroupConfig.fromJson(json);
  }

  // doc
  Future<ResponseGetDocs> getDocs(int? year, int? month) async {
    log.i("发送请求 获取分组的日志列表");

    String path = "/docs/${gid!}";
    Map<String, String> param = {};
    if (year != null) {
      param["year"] = year.toString();
    }
    if (month != null) {
      param["month"] = month.toString();
    }

    final url =
        URI().get(serverAddress, path, param: param.isEmpty ? null : param);
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };

    final res = await _handleRequest<ResponseGetDocs>(
      Method.get,
      url,
      (json) => ResponseGetDocs.fromJson(json),
      headers: headers,
    );

    return res;
  }

  // Future<ResponseGetDoc> getPreviousDoc(int id) async {
  //   log.i("发送请求 获取单个印迹");

  //   String path = "/doc/${gid!}?previous=1";

  //   final url = URI().get(serverAddress, path);
  //   final Map<String, String> headers = {
  //     "Content-Type": "application/json",
  //     'Authorization': getAuthorization(),
  //   };

  //   return _handleRequest<ResponseGetDoc>(
  //     Method.get,
  //     url,
  //     (json) => ResponseGetDoc.fromJson(json),
  //     headers: headers,
  //   );
  // }

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
    final url = URI().get(serverAddress, path);
    return _handleRequest<ResponsePostDoc>(
      Method.post,
      url,
      (json) => ResponsePostDoc.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponsePutDoc> putDoc(RequestPutDoc req) async {
    log.i("发送请求 更新印迹");

    String path = "/doc/${gid!}/${did!}";

    final Map<String, dynamic> data = {
      'data': req.toJson(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);
    return _handleRequest<ResponsePutDoc>(
      Method.put,
      url,
      (json) => ResponsePutDoc.fromJson(json),
      data: data,
      headers: headers,
    );
  }

  Future<ResponseDeleteDoc> deleteDoc() async {
    log.i("发送请求 删除印迹");
    String path = "/doc/${gid!}/${did!}";
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = URI().get(
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
    log.i("发送请求 上传印迹图片");

    String path = "/image";
    final String mine;
    switch (req.type) {
      case IMGType.jpg:
        mine = "image/jpeg";
        break;
      case IMGType.png:
        mine = "image/png";
        break;
    }
    final url = URI().get(serverAddress, path);
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
      "Content-Type": mine,
    };

    http.Response response =
        await http.post(url, headers: headers, body: req.data);

    return ResponsePostImage.fromJson(jsonDecode(response.body));
  }

  Future<ResponseDeleteImage> deleteImage(String name) async {
    log.i("发送请求 删除印迹图片");
    String path = "/image/$name";
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = URI().get(
      serverAddress,
      path,
    );
    return _handleRequest<ResponseDeleteImage>(
      Method.delete,
      url,
      (json) => ResponseDeleteImage.fromJson(json),
      headers: headers,
    );
  }

  // background job
  Future<ResponseGetBackgroundJobs> getBackgroundJobs() {
    log.i("发送请求 获取后台任务");
    final String path = "/bgjobs";
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);
    return _handleRequest<ResponseGetBackgroundJobs>(
      Method.get,
      url,
      (json) => ResponseGetBackgroundJobs.fromJson(json),
      headers: headers,
    );
  }

  Future<Basic> deleteBackgroundJob(String jobId) {
    log.i("发送请求 删除后台任务: $jobId");
    final String path = "/bgjob/$jobId";
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);
    return _handleRequest<Basic>(
      Method.delete,
      url,
      (json) => Basic(err: json['err'] as int, msg: json['msg'] as String),
      headers: headers,
    );
  }

  Future<ResponseDownloadBackgroundJobFile> downloadBackgroundJobFile(
      String jobId) async {
    log.i("发送请求 下载后台任务文件: $jobId");
    final String path = "/bgjob/$jobId/download";
    final Map<String, String> headers = {
      'Authorization': getAuthorization(),
    };
    final url = URI().get(serverAddress, path);

    try {
      final response = await http.get(url, headers: headers);

      // 处理 404 错误（文件未找到）
      if (response.statusCode == 404) {
        return ResponseDownloadBackgroundJobFile(
          err: 404,
          msg: '文件未找到',
        );
      }

      // 处理其他错误状态码（400, 500 等）
      if (response.statusCode != 200) {
        // 后端错误时返回 JSON 格式
        try {
          final json = jsonDecode(response.body);
          return ResponseDownloadBackgroundJobFile(
            err: json['err'] ?? response.statusCode,
            msg: json['msg'] ?? '下载失败',
          );
        } catch (e) {
          return ResponseDownloadBackgroundJobFile(
            err: response.statusCode,
            msg: '下载失败: HTTP ${response.statusCode}',
          );
        }
      }

      // 成功时（200），后端直接返回文件二进制数据
      // 从响应头中获取文件名
      String? filename;
      final contentDisposition = response.headers['content-disposition'];
      if (contentDisposition != null) {
        // 优先尝试解析 RFC 2231 格式 (filename*=UTF-8''encoded_name)
        final rfc2231Regex = RegExp(r"filename\*=UTF-8''([^;]+)");
        final rfc2231Match = rfc2231Regex.firstMatch(contentDisposition);
        if (rfc2231Match != null) {
          final encodedFilename = rfc2231Match.group(1);
          if (encodedFilename != null) {
            try {
              filename = Uri.decodeComponent(encodedFilename);
            } catch (e) {
              log.e("解码文件名失败: $e");
            }
          }
        }

        // 如果 RFC 2231 解析失败，尝试普通格式
        if (filename == null) {
          final regex = RegExp(r'filename="?([^";]+)"?');
          final match = regex.firstMatch(contentDisposition);
          if (match != null) {
            filename = match.group(1)?.trim();
          }
        }
      }

      return ResponseDownloadBackgroundJobFile(
        err: 0,
        msg: 'ok',
        data: response.bodyBytes,
        filename: filename,
      );
    } catch (e) {
      log.e("下载后台任务文件失败: $e");
      return ResponseDownloadBackgroundJobFile(
        err: -1,
        msg: '网络错误: ${e.toString()}',
      );
    }
  }
}
