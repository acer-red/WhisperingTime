import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';

import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/util/secure.dart';
import 'package:whispering_time/service/isar/config.dart';
import '../http/base.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/group/model.dart';

import 'package:whispering_time/grpc_generated/whisperingtime.pbgrpc.dart'
    as pb;

class _Grpc {
  ClientChannel? _channel;
  late pb.ThemeServiceClient theme;
  late pb.GroupServiceClient group;
  late pb.DocServiceClient doc;
  late pb.ImageServiceClient image;
  late pb.BackgroundJobServiceClient job;
  late pb.FileServiceClient file;
  late pb.ScaleServiceClient scale;
  final Storage _storage = Storage();

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
    file = pb.FileServiceClient(_channel!);
    scale = pb.ScaleServiceClient(_channel!);
  }

  // 关键步骤: 构建带认证信息的metadata，对应 engine/grpcserver/auth.go
  Future<Map<String, String>> _buildMetadata(
      {Map<String, String>? extra}) async {
    final cookie = await _storage.readCookie();
    if (cookie == null) {
      throw Exception('No authentication cookie found.');
    }

    if (cookie.isEmpty) {
      throw Exception('Authentication token is empty.');
    }

    final metadata = <String, String>{
      'authorization': cookie,
      ...?extra,
    };

    return metadata;
  }

  Future<CallOptions> authOptions({Map<String, String>? extra}) async {
    final metadata = await _buildMetadata(extra: extra);
    return CallOptions(metadata: metadata);
  }
}

// Public helpers for other modules (avoid depending on private _Grpc type).
Future<pb.ScaleServiceClient> grpcScaleClient() async {
  await _Grpc.instance._ensureReady();
  return _Grpc.instance.scale;
}

Future<CallOptions> grpcAuthOptions({Map<String, String>? extra}) {
  return _Grpc.instance.authOptions(extra: extra);
}

// theme
class ResponseGetThemes extends Basic {
  List<ThemeListData> data;
  ResponseGetThemes(
      {required super.err, required super.msg, required this.data});
}

class ResponseGetThemesAndDataX extends Basic {
  List<XTheme> data;

  ResponseGetThemesAndDataX({
    required super.err,
    required super.msg,
    required this.data,
  });
}

class ResponseGetThemesAndDataD extends Basic {
  List<DTheme> data;

  ResponseGetThemesAndDataD({
    required super.err,
    required super.msg,
    required this.data,
  });
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
}

class DDoc {
  // final String id;
  final String title;
  final String content;
  final int level;
  final DateTime createAt;
  final DateTime updateAt;
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get levelString => Level.string(level);
  DDoc({
    // required this.id,
    required this.title,
    required this.content,
    required this.level,
    required this.createAt,
    required this.updateAt,
  });
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
}

class XDoc {
  final String did;
  final String title;
  final int level;
  final DateTime createAt;
  final DateTime updateAt;
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  String get levelString => Level.string(level);
  XDoc({
    required this.did,
    required this.title,
    required this.level,
    required this.createAt,
    required this.updateAt,
  });
}

class RequestUpdateTheme {
  String name;
  RequestUpdateTheme({required this.name});
}

class ResponseUpdateTheme extends Basic {
  ResponseUpdateTheme({required super.err, required super.msg});
}

class RequestCreateTheme {
  String name;
  RequestCreateTheme({required this.name});
}

class ResponseCreateTheme extends Basic {
  String id;
  ResponseCreateTheme(
      {required super.err, required super.msg, required this.id});
}

class ResponseDeleteTheme extends Basic {
  ResponseDeleteTheme({required super.err, required super.msg});
}

class ThemeListData {
  String name;
  String id;
  ThemeListData({required this.name, required this.id});
}

// group
class GroupConfigNULL {
  List<bool>? levels = [];
  int? viewType;
  int? sortType;
  int? autoFreezeDays;
  GroupConfigNULL(
      {this.levels, this.viewType, this.sortType, this.autoFreezeDays});
}

class ResponseGetGroupAndDocDetail extends Basic {
  DGroup data;
  ResponseGetGroupAndDocDetail(
      {required super.err, required super.msg, required this.data});
}

class ResponseGetGroup extends Basic {
  List<GroupListData> data;
  ResponseGetGroup(
      {required super.err, required super.msg, required this.data});
}

class ResponsePostGroup extends Basic {
  String id;
  ResponsePostGroup({required super.err, required super.msg, required this.id});
}

class ResponsePutGroup extends Basic {
  ResponsePutGroup({required super.err, required super.msg});
}

class RequestUpdateGroup {
  String? name;
  GroupConfigNULL? config;
  DateTime? overAt;
  RequestUpdateGroup({this.name, this.config, this.overAt});
}

class RequestCreateGroup {
  String name;
  int autoFreezeDays;

  RequestCreateGroup({required this.name, this.autoFreezeDays = 30});
}

class ResponseDeleteGroup extends Basic {
  ResponseDeleteGroup({required super.err, required super.msg});
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
}

class ResponseExportGroupConfig extends Basic {
  ResponseExportGroupConfig({required super.err, required super.msg});
}

class ResponseExportAllConfig extends Basic {
  ResponseExportAllConfig({required super.err, required super.msg});
}

class ResponseImportGroupConfig extends Basic {
  ResponseImportGroupConfig({required super.err, required super.msg});
}

// doc

class ResponseGetDocs extends Basic {
  List<Doc> data;
  ResponseGetDocs({required super.err, required super.msg, required this.data});
}

class ResponseGetDoc extends Basic {
  String id;
  ResponseGetDoc({required super.err, required super.msg, required this.id});
}

class RequestCreateDoc {
  String title;
  String content;
  DateTime createAt;
  int level;
  DocConfig config;
  RequestCreateDoc(
      {required this.content,
      required this.title,
      required this.createAt,
      required this.level,
      required this.config});
}

class ResponseCreateDoc extends Basic {
  String id;
  ResponseCreateDoc({required super.err, required super.msg, required this.id});
}

class RequestUpdateDoc {
  String? content;
  String? title;
  int? level;
  DateTime? createAt;
  DocConfig? config;
  DateTime get updateAt => DateTime.now();
  RequestUpdateDoc(
      {this.title, this.content, this.level, this.createAt, this.config});
}

class ResponsePutDoc extends Basic {
  ResponsePutDoc({required super.err, required super.msg});
}

class ResponseDeleteDoc extends Basic {
  ResponseDeleteDoc({required super.err, required super.msg});
}

// image
class ResponseDeleteImage extends Basic {
  ResponseDeleteImage({required super.err, required super.msg});
}

class RequestCreateImage {
  IMGType type;
  Uint8List data;
  RequestCreateImage({required this.type, required this.data});
}

class ResponsePostImage extends Basic {
  final String name;
  final String url;
  ResponsePostImage(
      {required super.err,
      required super.msg,
      required this.name,
      required this.url});
  String get imageFullUrl => url;
}

class ResponsePresignUpload extends Basic {
  final String? fileId;
  final String? uploadUrl;
  final String? objectPath;
  final int? expiresAt;
  ResponsePresignUpload(
      {required super.err,
      required super.msg,
      this.fileId,
      this.uploadUrl,
      this.objectPath,
      this.expiresAt});
}

class ResponsePresignDownload extends Basic {
  final String? fileId;
  final String? downloadUrl;
  final int? expiresAt;
  final String? ownerUid;
  final String? themeId;
  final String? groupId;
  final String? docId;
  final String? mime;
  final int? size;
  final Uint8List? encryptedKey;
  final Uint8List? iv;
  final Uint8List? encryptedMetadata;

  ResponsePresignDownload({
    required super.err,
    required super.msg,
    this.fileId,
    this.downloadUrl,
    this.expiresAt,
    this.ownerUid,
    this.themeId,
    this.groupId,
    this.docId,
    this.mime,
    this.size,
    this.encryptedKey,
    this.iv,
    this.encryptedMetadata,
  });
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
}

class JobError {
  final int code;
  final String message;

  JobError({
    required this.code,
    required this.message,
  });
}

class ResponseGetBackgroundJobs extends Basic {
  final List<BackgroundJob> jobs;

  ResponseGetBackgroundJobs({
    required super.err,
    required super.msg,
    required this.jobs,
  });
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

class _CipherWithKey {
  final Uint8List cipher;
  final Uint8List encryptedKey;
  _CipherWithKey({required this.cipher, required this.encryptedKey});
}

class _DocCipher {
  final Uint8List title;
  final Uint8List scales;
  final Uint8List level;
  final Uint8List encryptedKey;
  _DocCipher({
    required this.title,
    required this.scales,
    required this.level,
    required this.encryptedKey,
  });
}

class Grpc {
  final String? content;
  final String? tid;
  final String? gid;
  final String? did;
  final String uid = Config.instance.uid;
  final String serverAddress = Config.instance.serverAddress;
  final Storage _storage = Storage();

  Grpc({this.content, this.tid, this.gid, this.did});

  Future<_CipherWithKey> _encryptText(String value) async {
    final env = await _storage.envelopeEncrypt(utf8.encode(value));
    return _CipherWithKey(
        cipher: env.cipherText, encryptedKey: env.encryptedKey);
  }

  Future<_DocCipher> _encryptDocContent(
      String title, String scalesJson, int level) async {
    final dataKey = Uint8List.fromList(await KeyManager.generateAES());
    final encryptedKey = await _storage.wrapDataKey(dataKey);
    final titleCipher =
        await _storage.encryptWithDataKey(dataKey, utf8.encode(title));
    final scalesCipher =
        await _storage.encryptWithDataKey(dataKey, utf8.encode(scalesJson));
    final levelCipher =
        await _storage.encryptWithDataKey(dataKey, utf8.encode('$level'));
    return _DocCipher(
        title: titleCipher,
        scales: scalesCipher,
        level: levelCipher,
        encryptedKey: encryptedKey);
  }

  Future<Uint8List?> _unwrapDataKey(pb.PermissionEnvelope? permission) async {
    if (permission == null || permission.encryptedKey.isEmpty) return null;
    return _storage.unwrapDataKey(Uint8List.fromList(permission.encryptedKey));
  }

  Future<Uint8List> _decryptBytes(
      List<int> data, pb.PermissionEnvelope? permission) async {
    if (data.isEmpty) return Uint8List(0);
    final key = await _unwrapDataKey(permission);
    if (key != null) {
      return _storage.decryptWithDataKey(key, data);
    }
    return _storage.decryptData(Uint8List.fromList(data));
  }

  Future<String> _decryptText(
      List<int> data, pb.PermissionEnvelope? permission) async {
    try {
      final plain = await _decryptBytes(data, permission);
      return utf8.decode(plain);
    } catch (e) {
      log.e("Decryption failed: $e");
      return "解密失败";
    }
  }

  Future<int> _decryptLevel(
      List<int> data, pb.PermissionEnvelope? permission) async {
    if (data.isEmpty) return 0;
    try {
      final plain = await _decryptBytes(data, permission);
      final parsed = int.tryParse(utf8.decode(plain));
      if (parsed != null) return parsed;
    } catch (_) {
      // fall through to plain-text decoding
    }
    return int.tryParse(
            utf8.decode(Uint8List.fromList(data), allowMalformed: true)) ??
        0;
  }

  // theme
  Future<ResponseGetThemes> getthemes() async {
    log.i("发送请求 获取主题列表(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.listThemes(
      pb.ListThemesRequest(),
      options: await _Grpc.instance.authOptions(),
    );
    final data = await Future.wait(resp.themes.map((e) async => ThemeListData(
          name: await _decryptText(e.name, e.permission),
          id: e.id,
        )));
    return ResponseGetThemes(err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponseGetThemesAndDataX> getThemesAndDoc() async {
    log.i("发送请求 获取主题列表和印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.listThemes(
      pb.ListThemesRequest(includeDocs: true),
      options: await _Grpc.instance.authOptions(),
    );
    final data = await Future.wait(resp.themes.map((t) async {
      final themeName = await _decryptText(t.name, t.permission);
      final groups = await Future.wait(t.groups.map((g) async {
        final groupName = await _decryptText(g.name, g.permission);
        final docs = await Future.wait(g.docs.map((d) async {
          final titleBytes = await _decryptBytes(
              Uint8List.fromList(d.content.title), d.permission);
          final level = await _decryptLevel(d.content.level, d.permission);
          return XDoc(
            did: d.id,
            title: utf8.decode(titleBytes),
            level: level,
            createAt:
                DateTime.fromMillisecondsSinceEpoch(d.createAt.toInt() * 1000),
            updateAt:
                DateTime.fromMillisecondsSinceEpoch(d.updateAt.toInt() * 1000),
          );
        }));
        return XGroup(
          gid: g.id,
          name: groupName,
          docs: docs,
        );
      }));
      return XTheme(
        tid: t.id,
        name: themeName,
        groups: groups,
      );
    }));
    return ResponseGetThemesAndDataX(err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponseGetThemesAndDataD> getThemesAndDocDetail() async {
    log.i("发送请求 获取主题列表和印迹（详细数据）(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.listThemes(
      pb.ListThemesRequest(includeDocs: true, includeDetail: true),
      options: await _Grpc.instance.authOptions(),
    );
    final data = await Future.wait(resp.themes.map((t) async {
      final themeName = await _decryptText(t.name, t.permission);
      final groups = await Future.wait(t.groups.map((g) async {
        final groupName = await _decryptText(g.name, g.permission);
        final docs = await Future.wait(g.docs.map((d) async {
          final titleBytes = await _decryptBytes(
              Uint8List.fromList(d.content.title), d.permission);
          final contentBytes = await _decryptBytes(
              Uint8List.fromList(d.content.scales), d.permission);
          final level = await _decryptLevel(d.content.level, d.permission);
          return DDoc(
            title: utf8.decode(titleBytes),
            content: utf8.decode(contentBytes),
            level: level,
            createAt:
                DateTime.fromMillisecondsSinceEpoch(d.createAt.toInt() * 1000),
            updateAt:
                DateTime.fromMillisecondsSinceEpoch(d.updateAt.toInt() * 1000),
          );
        }));
        return DGroup(
          gid: g.id,
          name: groupName,
          docs: docs,
        );
      }));
      return DTheme(
        tid: t.id,
        name: themeName,
        groups: groups,
      );
    }));
    return ResponseGetThemesAndDataD(err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponseCreateTheme> createTheme(RequestCreateTheme req) async {
    log.i("发送请求 创建主题(gRPC)");
    await _Grpc.instance._ensureReady();
    final encName = await _encryptText(req.name);
    final encDefault = await _encryptText(defaultGroupName);
    final resp = await _Grpc.instance.theme.createTheme(
      pb.CreateThemeRequest(
        name: encName.cipher,
        encryptedKey: encName.encryptedKey,
        defaultGroupName: encDefault.cipher,
        defaultGroupEncryptedKey: encDefault.encryptedKey,
      ),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseCreateTheme(err: resp.err, msg: resp.msg, id: resp.id);
  }

  Future<ResponseUpdateTheme> updateTheme(RequestUpdateTheme req) async {
    log.i("发送请求 更新主题(gRPC)");
    await _Grpc.instance._ensureReady();
    final encName = await _encryptText(req.name);
    final resp = await _Grpc.instance.theme.updateTheme(
      pb.UpdateThemeRequest(
        id: tid!,
        name: encName.cipher,
        encryptedKey: encName.encryptedKey,
      ),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseUpdateTheme(err: resp.err, msg: resp.msg);
  }

  Future<ResponseDeleteTheme> deleteTheme() async {
    log.i("发送请求 删除主题(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.deleteTheme(
      pb.DeleteThemeRequest(id: tid!),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseDeleteTheme(err: resp.err, msg: resp.msg);
  }

  // group
  Future<ResponseGetGroup> getGroups() async {
    log.i("发送请求 获取所有分组(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.listGroups(
      pb.ListGroupsRequest(themeId: tid!),
      options: await _Grpc.instance.authOptions(),
    );
    final data = await Future.wait(resp.groups.map((g) async => GroupListData(
          name: await _decryptText(g.name, g.permission),
          id: g.id,
          createAt:
              DateTime.fromMillisecondsSinceEpoch(g.createAt.toInt() * 1000),
          updateAt:
              DateTime.fromMillisecondsSinceEpoch(g.updateAt.toInt() * 1000),
          overAt: g.overAt == 0
              ? null
              : DateTime.fromMillisecondsSinceEpoch(g.overAt.toInt() * 1000),
          config: GroupConfig(
            levels: g.config.levels,
            viewType: g.config.viewType,
            sortType: g.config.sortType,
            autoFreezeDays: g.config.autoFreezeDays,
          ),
        )));
    return ResponseGetGroup(err: resp.err, msg: resp.msg, data: data);
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
      options: await _Grpc.instance.authOptions(),
    );
    final g = resp.group;
    final groupName = await _decryptText(g.name, g.permission);
    final docs = await Future.wait(g.docs.map((d) async {
      final titleBytes = await _decryptBytes(
          Uint8List.fromList(d.content.title), d.permission);
      final contentBytes = await _decryptBytes(
          Uint8List.fromList(d.content.scales), d.permission);
      final level = await _decryptLevel(d.content.level, d.permission);
      return DDoc(
        title: utf8.decode(titleBytes),
        content: utf8.decode(contentBytes),
        level: level,
        createAt:
            DateTime.fromMillisecondsSinceEpoch(d.createAt.toInt() * 1000),
        updateAt:
            DateTime.fromMillisecondsSinceEpoch(d.updateAt.toInt() * 1000),
      );
    }));
    final data = DGroup(
      gid: g.id,
      name: groupName,
      docs: docs,
    );
    return ResponseGetGroupAndDocDetail(
        err: resp.err, msg: resp.msg, data: data);
  }

  Future<ResponsePostGroup> postGroup(RequestCreateGroup req) async {
    log.i("发送请求 创建分组(gRPC)");
    await _Grpc.instance._ensureReady();
    final encName = await _encryptText(req.name);
    final resp = await _Grpc.instance.group.createGroup(
      pb.CreateGroupRequest(
        themeId: tid!,
        name: encName.cipher,
        encryptedKey: encName.encryptedKey,
        autoFreezeDays: req.autoFreezeDays,
      ),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponsePostGroup(err: resp.err, msg: resp.msg, id: resp.id);
  }

  Future<ResponsePutGroup> putGroup(RequestUpdateGroup req) async {
    log.i("发送请求 更新分组(gRPC)");
    if (tid == null || gid == null) {
      log.e('缺少参数');
    }
    await _Grpc.instance._ensureReady();
    pb.GroupConfig? cfg;
    if (req.config != null) {
      cfg = pb.GroupConfig(
        levels: req.config!.levels ?? [],
        viewType: req.config!.viewType,
        sortType: req.config!.sortType,
        autoFreezeDays: req.config!.autoFreezeDays,
      );
    }
    final reqMsg = pb.UpdateGroupRequest(
      themeId: tid!,
      groupId: gid!,
      config: cfg,
      overAt: req.overAt != null
          ? Int64(req.overAt!.millisecondsSinceEpoch ~/ 1000)
          : Int64.ZERO,
    );
    if (req.name != null) {
      final enc = await _encryptText(req.name!);
      reqMsg
        ..name = enc.cipher
        ..encryptedKey = enc.encryptedKey;
    }
    final resp = await _Grpc.instance.group.updateGroup(
      reqMsg,
      options: await _Grpc.instance.authOptions(),
    );
    return ResponsePutGroup(err: resp.err, msg: resp.msg);
  }

  Future<ResponseDeleteGroup> deleteGroup() async {
    log.i("发送请求 删除分组(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.deleteGroup(
      pb.DeleteGroupRequest(themeId: tid!, groupId: gid!),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseDeleteGroup(err: resp.err, msg: resp.msg);
  }

  Future<ResponseExportGroupConfig> exportGroupConfig() async {
    log.i("发送请求 导出分组配置(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.group.exportGroupConfig(
      pb.ExportGroupConfigRequest(themeId: tid!, groupId: gid!),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseExportGroupConfig(err: resp.err, msg: resp.msg);
  }

  Future<ResponseExportAllConfig> exportAllConfig() async {
    log.i("发送请求 导出全部主题配置(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.exportAllConfig(
      pb.ExportAllConfigRequest(),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseExportAllConfig(err: resp.err, msg: resp.msg);
  }

  Future<ResponseImportGroupConfig> importGroupConfig(String filePath) async {
    log.i("发送请求 导入分组配置(gRPC)");
    await _Grpc.instance._ensureReady();
    final fileBytes = await File(filePath).readAsBytes();
    final resp = await _Grpc.instance.group.importGroupConfig(
      Stream.value(pb.BytesChunk(data: fileBytes)),
      options: await _Grpc.instance.authOptions(extra: {'theme_id': tid!}),
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
      options: await _Grpc.instance.authOptions(),
    );
    final docs = await Future.wait(resp.docs.map((d) async {
      try {
        final titleBytes = await _decryptBytes(
            Uint8List.fromList(d.content.title), d.permission);
        final scalesBytes = await _decryptBytes(
            Uint8List.fromList(d.content.scales), d.permission);
        final level = await _decryptLevel(d.content.level, d.permission);
        return Doc(
          title: utf8.decode(titleBytes),
          content: utf8.decode(scalesBytes),
          level: level,
          createAt:
              DateTime.fromMillisecondsSinceEpoch(d.createAt.toInt() * 1000),
          updateAt:
              DateTime.fromMillisecondsSinceEpoch(d.updateAt.toInt() * 1000),
          config: DocConfig(
            isShowTool: d.config.isShowTool,
            displayPriority: d.config.displayPriority,
          ),
          id: d.id,
        );
      } catch (e) {
        log.e("Decrypt doc ${d.id} failed: $e");
        return Doc(
          title: "解密失败",
          content: jsonEncode([
            {"insert": "文档解密失败，可能已损坏。\n$e\n"}
          ]),
          level: 0,
          createAt:
              DateTime.fromMillisecondsSinceEpoch(d.createAt.toInt() * 1000),
          updateAt:
              DateTime.fromMillisecondsSinceEpoch(d.updateAt.toInt() * 1000),
          config: DocConfig(
            isShowTool: d.config.isShowTool,
            displayPriority: d.config.displayPriority,
          ),
          id: d.id,
        );
      }
    }));
    return ResponseGetDocs(err: resp.err, msg: resp.msg, data: docs);
  }

  Future<ResponseCreateDoc> createDoc(RequestCreateDoc req) async {
    log.i("发送请求 创建印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final docCipher =
        await _encryptDocContent(req.title, req.content, req.level);
    final content = pb.Content();
    content
      ..title = docCipher.title
      ..scales = docCipher.scales
      ..level = docCipher.level;

    final resp = await _Grpc.instance.doc.createDoc(
      pb.CreateDocRequest(
        groupId: gid!,
        content: content,
        encryptedKey: docCipher.encryptedKey,
        createAt: Int64(req.createAt.millisecondsSinceEpoch ~/ 1000),
        config: pb.DocConfig(
          isShowTool: req.config.isShowTool ?? false,
          displayPriority: req.config.displayPriority ?? 0,
        ),
      ),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseCreateDoc(err: resp.err, msg: resp.msg, id: resp.id);
  }

  Future<ResponsePutDoc> putDoc(RequestUpdateDoc req) async {
    log.i("发送请求 更新印迹(gRPC)");
    await _Grpc.instance._ensureReady();

    pb.Content? content;
    Uint8List? encryptedKey;
    if (req.title != null || req.content != null || req.level != null) {
      content = pb.Content();
      final dataKey = Uint8List.fromList(await KeyManager.generateAES());
      encryptedKey = await _storage.wrapDataKey(dataKey);
      if (req.title != null) {
        content.title =
            await _storage.encryptWithDataKey(dataKey, utf8.encode(req.title!));
      }
      if (req.content != null) {
        content.scales = await _storage.encryptWithDataKey(
            dataKey, utf8.encode(req.content!));
      }
      if (req.level != null) {
        content.level = await _storage.encryptWithDataKey(
            dataKey, utf8.encode('${req.level!}'));
      }
    }

    final resp = await _Grpc.instance.doc.updateDoc(
      pb.UpdateDocRequest(
        groupId: gid!,
        docId: did!,
        content: content,
        encryptedKey: encryptedKey,
        createAt: req.createAt != null
            ? Int64(req.createAt!.millisecondsSinceEpoch ~/ 1000)
            : Int64.ZERO,
        config: req.config != null
            ? pb.DocConfig(
                isShowTool: req.config!.isShowTool ?? false,
                displayPriority: req.config!.displayPriority ?? 0,
              )
            : null,
      ),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponsePutDoc(err: resp.err, msg: resp.msg);
  }

  Future<ResponseDeleteDoc> deleteDoc() async {
    log.i("发送请求 删除印迹(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.doc.deleteDoc(
      pb.DeleteDocRequest(groupId: gid!, docId: did!),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseDeleteDoc(err: resp.err, msg: resp.msg);
  }

  // image
  Future<ResponsePostImage> postImage(RequestCreateImage req) async {
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
      options: await _Grpc.instance.authOptions(),
    );
    return ResponsePostImage(
        err: resp.err, msg: resp.msg, name: resp.name, url: resp.url);
  }

  Future<ResponseDeleteImage> deleteImage(String name) async {
    log.i("发送请求 删除印迹图片(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.image.deleteImage(
      pb.DeleteImageRequest(name: name),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseDeleteImage(err: resp.err, msg: resp.msg);
  }

  Future<ResponsePresignUpload> presignUploadFile({
    required String filename,
    required String mime,
    required int size,
    required Uint8List encryptedKey,
    Uint8List? iv,
    Uint8List? encryptedMetadata,
    int? expiresInSec,
  }) async {
    if (tid == null || gid == null || did == null) {
      return ResponsePresignUpload(
          err: 1, msg: 'missing theme/group/doc context');
    }
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.file.presignUploadFile(
      pb.PresignUploadFileRequest(
        themeId: tid!,
        groupId: gid!,
        docId: did!,
        filename: filename,
        mime: mime,
        size: Int64(size),
        encryptedKey: encryptedKey,
        iv: iv,
        encryptedMetadata: encryptedMetadata,
        expiresInSec: expiresInSec != null ? Int64(expiresInSec) : null,
      ),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponsePresignUpload(
      err: resp.err,
      msg: resp.msg,
      fileId: resp.fileId,
      uploadUrl: resp.uploadUrl,
      objectPath: resp.objectPath,
      expiresAt: resp.expiresAt.toInt(),
    );
  }

  Future<ResponsePresignDownload> presignDownloadFile(String fileId) async {
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.file.presignDownloadFile(
      pb.PresignDownloadFileRequest(fileId: fileId),
      options: await _Grpc.instance.authOptions(),
    );
    return ResponsePresignDownload(
      err: resp.err,
      msg: resp.msg,
      fileId: resp.fileId,
      downloadUrl: resp.downloadUrl,
      expiresAt: resp.expiresAt.toInt(),
      ownerUid: resp.ownerUid,
      themeId: resp.themeId,
      groupId: resp.groupId,
      docId: resp.docId,
      mime: resp.mime,
      size: resp.size.toInt(),
      encryptedKey: resp.encryptedKey.isEmpty
          ? null
          : Uint8List.fromList(resp.encryptedKey),
      iv: resp.iv.isEmpty ? null : Uint8List.fromList(resp.iv),
      encryptedMetadata: resp.encryptedMetadata.isEmpty
          ? null
          : Uint8List.fromList(resp.encryptedMetadata),
    );
  }

  Future<Basic> deleteFile(String fileId) async {
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.file.deleteFile(
      pb.DeleteFileRequest(fileId: fileId),
      options: await _Grpc.instance.authOptions(),
    );
    return Basic(err: resp.err, msg: resp.msg);
  }

  // background job
  Future<ResponseGetBackgroundJobs> getBackgroundJobs() {
    log.i("发送请求 获取后台任务(gRPC)");
    return _Grpc.instance._ensureReady().then((_) async {
      final resp = await _Grpc.instance.job.listJobs(
        pb.ListBackgroundJobsRequest(),
        options: await _Grpc.instance.authOptions(),
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
        options: await _Grpc.instance.authOptions(),
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
      options: await _Grpc.instance.authOptions(),
    );
    return ResponseDownloadBackgroundJobFile(
      err: resp.err,
      msg: resp.msg,
      data: resp.data.isEmpty ? null : Uint8List.fromList(resp.data),
      filename: resp.filename.isEmpty ? null : resp.filename,
    );
  }

  Future<Basic> deleteUserData(pb.DeleteUserDataRequest req) async {
    log.i("发送请求 删除用户数据(gRPC)");
    await _Grpc.instance._ensureReady();
    final resp = await _Grpc.instance.theme.deleteUserData(
      req,
      options: await _Grpc.instance.authOptions(),
    );
    return Basic(err: resp.err, msg: resp.msg);
  }
}
