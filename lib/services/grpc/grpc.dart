import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:whispering_time/grpc_generated/whisperingtime.pbgrpc.dart'
    as pb;

import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/services/isar/config.dart';
import '../http/base.dart';
import 'package:whispering_time/pages/doc/model.dart';
import 'package:whispering_time/pages/group/model.dart';

class _Grpc {
  ClientChannel? _channel;
  late pb.ThemeServiceClient theme;
  late pb.GroupServiceClient group;
  late pb.DocServiceClient doc;
  late pb.ImageServiceClient image;
  late pb.BackgroundJobServiceClient job;

  static final _Grpc instance = _Grpc._internal();
  _Grpc._internal();

  Future<void> _ensureReady() async {
    if (_channel != null) return;
    final cfg = Config.instance;
    final uri = Uri.parse(cfg.serverAddress);
    final host = uri.host.isEmpty ? cfg.serverAddress : uri.host;
    final port = uri.port == 0 ? 50051 : uri.port;

    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    theme = pb.ThemeServiceClient(_channel!);
    group = pb.GroupServiceClient(_channel!);
    doc = pb.DocServiceClient(_channel!);
    image = pb.ImageServiceClient(_channel!);
    job = pb.BackgroundJobServiceClient(_channel!);
  }

  CallOptions get _authOptions => CallOptions(metadata: {
        'authorization': Http.basicAuthorization(),
      });
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
  // final String id;
  final String plainText;
  final String title;
  final String content;
  final int level;
  final DateTime createAt;
  final DateTime updateAt;
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get levelString => Level.string(level);
  DDoc({
    // required this.id,
    required this.plainText,
    required this.title,
    required this.content,
    required this.level,
    required this.createAt,
    required this.updateAt,
  });

  factory DDoc.fromJson(Map<String, dynamic> json) {
    return DDoc(
      // id: json['did'] as String,
      plainText: json['plain_text'] == null ? '' : json['plain_text'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      level: json['level'] as int,
      createAt: DateTime.parse(json['createAt'] as String),
      updateAt: DateTime.parse(json['updateAt'] as String),
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
      plainText: json['plain_text'] == null ? '' : json['plain_text'] as String,
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
  int autoFreezeDays;
  RequestPostThemeDefaultGroup({required this.name, this.autoFreezeDays = 30});
  Map<String, dynamic> toJson() => {
        'name': name,
        'createAt': Time.nowTimestampString(),
        'config': {
          'auto_freeze_days': autoFreezeDays,
        }
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
  int? sortType;
  int? autoFreezeDays;
  GroupConfigNULL(
      {this.isMulti,
      this.isAll,
      this.levels,
      this.viewType,
      this.sortType,
      this.autoFreezeDays});

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
    if (sortType != null) {
      data['sort_type'] = sortType;
    }
    if (autoFreezeDays != null) {
      data['auto_freeze_days'] = autoFreezeDays;
    }

    return data;
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
  GroupConfigNULL? config;
  DateTime? overAt;
  RequestPutGroup({this.name, this.config, this.overAt});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'updateAt': Time.nowTimestampString()};

    if (name != null) {
      data['name'] = name!;
    }
    if (config != null) {
      data['config'] = config!.toJson();
    }
    if (overAt != null) {
      data['overAt'] = Time.toTimestampString(overAt!);
    }
    return data;
  }
}

class RequestPostGroup {
  String name;
  int autoFreezeDays;

  RequestPostGroup({required this.name, this.autoFreezeDays = 30});
  Map<String, dynamic> toJson() => {
        'name': name,
        'createAt': Time.nowTimestampString(),
        'updateAt': Time.nowTimestampString(),
        'config': {
          'auto_freeze_days': autoFreezeDays,
        }
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
  DateTime? overAt;
  GroupConfig config;
  GroupListData({
    required this.name,
    required this.id,
    required this.createAt,
    required this.updateAt,
    required this.overAt,
    required this.config,
  });

  factory GroupListData.fromJson(Map<String, dynamic> json) {
    return GroupListData(
      name: json['name'] as String,
      id: json['id'] as String,
      createAt: Time.stringToTime(json['createAt'] as String),
      updateAt: Time.stringToTime(json['updateAt'] as String),
      overAt: json['overAt'] != null && (json['overAt'] as String).isNotEmpty
          ? Time.stringToTime(json['overAt'] as String)
          : null,
      config: GroupConfig(
        isMulti: json['config']['is_multi'] as bool,
        isAll: json['config']['is_all'] as bool,
        levels: (json['config']['levels'] as List<dynamic>)
            .map((e) => e as bool)
            .toList(),
        viewType: json['config']['view_type'] as int,
        sortType: json['config']['sort_type'] != null
            ? json['config']['sort_type'] as int
            : 0,
        autoFreezeDays: json['config']['auto_freeze_days'] != null
            ? json['config']['auto_freeze_days'] as int
            : 30,
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

class ResponseExportAllConfig extends Basic {
  ResponseExportAllConfig({required super.err, required super.msg});
  factory ResponseExportAllConfig.fromJson(Map<String, dynamic> json) {
    return ResponseExportAllConfig(
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
  DocConfig config;
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
  DocConfig? config;
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

  static String basicAuthorization() {
    final credentials = '${Config.instance.uid}:';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  // ignore: unused_element
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
      log.e("解析数据失败 \n${response.body}\n${e.toString()}",
          stackTrace: StackTrace.current);
      return fromJson({'err': 1, 'msg': ''});
    }
  }

  String getAuthorization() {
    final credentials = '$uid:';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  // theme
  Future<ResponseGetThemes> getthemes() async {
    log.i("发送请求 获取主题列表(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.listThemes(
      pb.ListThemesRequest(),
      options: _Grpc.instance._authOptions,
    );
    final data =
        resp.themes.map((e) => ThemeListData(name: e.name, id: e.id)).toList();
    return ResponseGetThemes(err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponseGetThemesAndDataX> getThemesAndDoc() async {
    log.i("发送请求 获取主题列表和印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.listThemes(
      pb.ListThemesRequest(includeDocs: true),
      options: _Grpc.instance._authOptions,
    );
    final data = resp.themes
        .map((t) => XTheme(
              tid: t.id,
              name: t.name,
              groups: t.groups
                  .map((g) => XGroup(
                        gid: g.id,
                        name: g.name,
                        docs: g.docs
                            .map((d) => XDoc(
                                  did: d.id,
                                  plainText: d.plainText,
                                  title: d.title,
                                  level: d.level,
                                  createAt: DateTime.fromMillisecondsSinceEpoch(
                                      d.createAt.toInt() * 1000),
                                  updateAt: DateTime.fromMillisecondsSinceEpoch(
                                      d.updateAt.toInt() * 1000),
                                ))
                            .toList(),
                      ))
                  .toList(),
            ))
        .toList();
    return ResponseGetThemesAndDataX(err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponseGetThemesAndDataD> getThemesAndDocDetail() async {
    log.i("发送请求 获取主题列表和印迹（详细数据）(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.listThemes(
      pb.ListThemesRequest(includeDocs: true, includeDetail: true),
      options: _Grpc.instance._authOptions,
    );
    final data = resp.themes
        .map((t) => DTheme(
              tid: t.id,
              name: t.name,
              groups: t.groups
                  .map((g) => DGroup(
                        gid: g.id,
                        name: g.name,
                        docs: g.docs
                            .map((d) => DDoc(
                                  plainText: d.plainText,
                                  title: d.title,
                                  content: d.content,
                                  level: d.level,
                                  createAt: DateTime.fromMillisecondsSinceEpoch(
                                      d.createAt.toInt() * 1000),
                                  updateAt: DateTime.fromMillisecondsSinceEpoch(
                                      d.updateAt.toInt() * 1000),
                                ))
                            .toList(),
                      ))
                  .toList(),
            ))
        .toList();
    return ResponseGetThemesAndDataD(err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponsePostTheme> postTheme(RequestPostTheme req) async {
    log.i("发送请求 创建主题(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.createTheme(
      pb.CreateThemeRequest(name: req.name),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePostTheme(err: resp.err, msg: resp.msg, id: resp.id);
  }

  Future<ResponsePutTheme> putTheme(RequestPutTheme req) async {
    log.i("发送请求 更新主题(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.updateTheme(
      pb.UpdateThemeRequest(id: tid!, name: req.name),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePutTheme(err: resp.err, msg: resp.msg);
  }

  Future<ResponseDeleteTheme> deleteTheme() async {
    log.i("发送请求 删除主题(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.deleteTheme(
      pb.DeleteThemeRequest(id: tid!),
      options: _Grpc.instance._authOptions,
    );
    return ResponseDeleteTheme(err: resp.err, msg: resp.msg);
  }

  // group
  Future<ResponseGetGroup> getGroups() async {
    log.i("发送请求 获取所有分组(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.listGroups(
      pb.ListGroupsRequest(themeId: tid!),
      options: _Grpc.instance._authOptions,
    );
    return ResponseGetGroup(
        err: resp.err,
        msg: resp.msg,
        data: resp.groups
            .map((g) => GroupListData(
                  name: g.name,
                  id: g.id,
                  createAt: DateTime.fromMillisecondsSinceEpoch(
                      g.createAt.toInt() * 1000),
                  updateAt: DateTime.fromMillisecondsSinceEpoch(
                      g.updateAt.toInt() * 1000),
                  overAt: g.overAt == 0
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(
                          g.overAt.toInt() * 1000),
                  config: GroupConfig(
                    isMulti: g.config.isMulti,
                    isAll: g.config.isAll,
                    levels: g.config.levels,
                    viewType: g.config.viewType,
                    sortType: g.config.sortType,
                    autoFreezeDays: g.config.autoFreezeDays,
                  ),
                ))
            .toList());
  }

  Future<ResponseGetGroupAndDocDetail> getGroupAndDocDetail() async {
    log.i("发送请求 获取所有分组和印迹（详细数据）(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.getGroup(
      pb.GetGroupRequest(
        themeId: tid!,
        groupId: gid!,
        includeDocs: true,
        includeDetail: true,
      ),
      options: _Grpc.instance._authOptions,
    );
    final g = resp.group;
    final data = DGroup(
      gid: g.id,
      name: g.name,
      docs: g.docs
          .map((d) => DDoc(
                plainText: d.plainText,
                title: d.title,
                content: d.content,
                level: d.level,
                createAt: DateTime.fromMillisecondsSinceEpoch(
                    d.createAt.toInt() * 1000),
                updateAt: DateTime.fromMillisecondsSinceEpoch(
                    d.updateAt.toInt() * 1000),
              ))
          .toList(),
    );
    return ResponseGetGroupAndDocDetail(
        err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponsePostGroup> postGroup(RequestPostGroup req) async {
    log.i("发送请求 创建分组(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.createGroup(
      pb.CreateGroupRequest(
        themeId: tid!,
        name: req.name,
        autoFreezeDays: req.autoFreezeDays,
      ),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePostGroup(err: resp.err, msg: resp.msg, id: resp.id);
  }

  Future<ResponsePutGroup> putGroup(RequestPutGroup req) async {
    log.i("发送请求 更新分组(gRPC)");
    if (tid == null || gid == null) {
      log.e('缺少参数');
    }
    await _Grpc.instance._ensureReady();
    pb.GroupConfig? cfg;
    if (req.config != null) {
      cfg = pb.GroupConfig(
        isMulti: req.config!.isMulti,
        isAll: req.config!.isAll,
        levels: req.config!.levels ?? [],
        viewType: req.config!.viewType,
        sortType: req.config!.sortType,
        autoFreezeDays: req.config!.autoFreezeDays,
      );
    }
    final resp = await _Grpc.instance.group.updateGroup(
      pb.UpdateGroupRequest(
        themeId: tid!,
        groupId: gid!,
        name: req.name,
        config: cfg,
        overAt: req.overAt != null
            ? Int64(req.overAt!.millisecondsSinceEpoch ~/ 1000)
            : Int64.ZERO,
      ),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePutGroup(err: resp.err, msg: resp.msg);
  }

  Future<ResponseDeleteGroup> deleteGroup() async {
    log.i("发送请求 删除分组(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.deleteGroup(
      pb.DeleteGroupRequest(themeId: tid!, groupId: gid!),
      options: _Grpc.instance._authOptions,
    );
    return ResponseDeleteGroup(err: resp.err, msg: resp.msg);
  }

  Future<ResponseExportGroupConfig> exportGroupConfig() async {
    log.i("发送请求 导出分组配置(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.exportGroupConfig(
      pb.ExportGroupConfigRequest(themeId: tid!, groupId: gid!),
      options: _Grpc.instance._authOptions,
    );
    return ResponseExportGroupConfig(err: resp.err, msg: resp.msg);
  }

  Future<ResponseExportAllConfig> exportAllConfig() async {
    log.i("发送请求 导出全部主题配置(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.exportAllConfig(
      pb.ExportAllConfigRequest(),
      options: _Grpc.instance._authOptions,
    );
    return ResponseExportAllConfig(err: resp.err, msg: resp.msg);
  }

  Future<ResponseImportGroupConfig> importGroupConfig(String filePath) async {
    log.i("发送请求 导入分组配置(gRPC)");
    await _Grpc.instance._ensureReady();
    final fileBytes = await File(filePath).readAsBytes();
    final resp = await _Grpc.instance.group.importGroupConfig(
      Stream.value(pb.BytesChunk(data: fileBytes)),
      options: CallOptions(
        metadata: {
          'authorization': Http.basicAuthorization(),
          'theme_id': tid!,
        },
      ),
    );
    return ResponseImportGroupConfig(err: resp.err, msg: resp.msg);
  }

  // doc
  Future<ResponseGetDocs> getDocs(int? year, int? month) async {
    log.i("发送请求 获取分组的日志列表(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.doc.listDocs(
      pb.ListDocsRequest(
        groupId: gid!,
        year: year ?? 0,
        month: month ?? 0,
      ),
      options: _Grpc.instance._authOptions,
    );
    final docs = resp.docs
        .map((d) => Doc(
              title: d.title,
              content: d.plainText,
              plainText: d.plainText,
              level: d.level,
              createAt: DateTime.fromMillisecondsSinceEpoch(
                  d.createAt.toInt() * 1000),
              updateAt: DateTime.fromMillisecondsSinceEpoch(
                  d.updateAt.toInt() * 1000),
              config: DocConfig(isShowTool: true),
              id: d.id,
            ))
        .toList();
    return ResponseGetDocs(err: resp.err, msg: resp.msg, data: docs);
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
    log.i("发送请求 创建印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.doc.createDoc(
      pb.CreateDocRequest(
        groupId: gid!,
        title: req.title,
        content: req.content,
        plainText: req.plainText,
        level: req.level,
        createAt: Int64(req.createAt.millisecondsSinceEpoch ~/ 1000),
      ),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePostDoc(err: resp.err, msg: resp.msg, id: resp.id);
  }

  Future<ResponsePutDoc> putDoc(RequestPutDoc req) async {
    log.i("发送请求 更新印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.doc.updateDoc(
      pb.UpdateDocRequest(
        groupId: gid!,
        docId: did!,
        title: req.title ?? "",
        content: req.content ?? "",
        plainText: req.plainText ?? "",
        level: req.level ?? 0,
        createAt: req.createAt != null
            ? Int64(req.createAt!.millisecondsSinceEpoch ~/ 1000)
            : Int64.ZERO,
      ),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePutDoc(err: resp.err, msg: resp.msg);
  }

  Future<ResponseDeleteDoc> deleteDoc() async {
    log.i("发送请求 删除印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.doc.deleteDoc(
      pb.DeleteDocRequest(groupId: gid!, docId: did!),
      options: _Grpc.instance._authOptions,
    );
    return ResponseDeleteDoc(err: resp.err, msg: resp.msg);
  }

  // image
  Future<ResponsePostImage> postImage(RequestPostImage req) async {
    log.i("发送请求 上传印迹图片(gRPC)");
    await _Grpc.instance._ensureReady();
    final String mime;
    switch (req.type) {
      case IMGType.jpg:
        mime = "image/jpeg";
        break;
      case IMGType.png:
        mime = "image/png";
        break;
    }
    final resp = await _Grpc.instance.image.uploadImage(
      Stream.value(pb.ImageUploadChunk(
        userId: Config.instance.uid,
        mime: mime,
        data: req.data,
      )),
      options: _Grpc.instance._authOptions,
    );
    return ResponsePostImage(
        err: resp.err, msg: resp.msg, name: resp.name, url: resp.url);
  }

  Future<ResponseDeleteImage> deleteImage(String name) async {
    log.i("发送请求 删除印迹图片(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.image.deleteImage(
      pb.DeleteImageRequest(name: name),
      options: _Grpc.instance._authOptions,
    );
    return ResponseDeleteImage(err: resp.err, msg: resp.msg);
  }

  // background job
  Future<ResponseGetBackgroundJobs> getBackgroundJobs() {
    log.i("发送请求 获取后台任务(gRPC)");
    return _Grpc.instance._ensureReady().then((_) async {
      final resp = await _Grpc.instance.job.listJobs(
        pb.ListBackgroundJobsRequest(),
        options: _Grpc.instance._authOptions,
      );
      final jobs = resp.jobs.map((j) {
        Map<String, dynamic>? result;
        JobError? error;
        if (j.resultJson.isNotEmpty) {
          try {
            result = jsonDecode(j.resultJson) as Map<String, dynamic>;
          } catch (_) {}
        }
        if (j.errorJson.isNotEmpty) {
          try {
            final errMap = jsonDecode(j.errorJson) as Map<String, dynamic>;
            error = JobError(
              code: errMap['code'] ?? 0,
              message: errMap['message'] ?? '',
            );
          } catch (_) {}
        }
        return BackgroundJob(
          id: j.id,
          name: j.name,
          jobType: j.jobType,
          status: j.status,
          createdAt: j.createdAt,
          startedAt: j.startedAt.isEmpty ? null : j.startedAt,
          completedAt: j.completedAt.isEmpty ? null : j.completedAt,
          result: result,
          error: error,
          priority: j.priority,
          retryCount: j.retryCount,
        );
      }).toList();
      return ResponseGetBackgroundJobs(
          err: resp.err, msg: resp.msg, jobs: jobs);
    });
  }

  Future<Basic> deleteBackgroundJob(String jobId) {
    log.i("发送请求 删除后台任务(gRPC): $jobId");
    return _Grpc.instance._ensureReady().then((_) async {
      final resp = await _Grpc.instance.job.deleteJob(
        pb.DeleteBackgroundJobRequest(id: jobId),
        options: _Grpc.instance._authOptions,
      );
      return Basic(err: resp.err, msg: resp.msg);
    });
  }

  Future<ResponseDownloadBackgroundJobFile> downloadBackgroundJobFile(
      String jobId) async {
    log.i("发送请求 下载后台任务文件(gRPC): $jobId");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.job.downloadJobFile(
      pb.DownloadBackgroundJobFileRequest(id: jobId),
      options: _Grpc.instance._authOptions,
    );
    return ResponseDownloadBackgroundJobFile(
      err: resp.err,
      msg: resp.msg,
      data: resp.data.isEmpty ? null : Uint8List.fromList(resp.data),
      filename: resp.filename.isEmpty ? null : resp.filename,
    );
  }
}
