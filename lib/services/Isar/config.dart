import 'dart:io';

import 'package:isar/isar.dart';
import 'package:whispering_time/utils/uuid.dart';
import 'package:whispering_time/services/isar/font.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:whispering_time/utils/env.dart';

import 'package:path/path.dart' as path;
import 'dart:developer';

part 'config.g.dart';

late Isar isar; // 声明 Isar 实例

@Collection()
class Config {
  Id id = Isar.autoIncrement;

  String uid = '';
  String serverAddress = 'http://127.0.0.1:13341';
  static const String fontHubServerAddress = "https://fonthub.acer.red";
  static const String indexServerAddress = "https://acer.red";
  bool devlopMode = false;
  bool visualNoneTitle = false;
  bool defaultShowTool = false;
  List<APIsar> apis = [];

  static Config? _instance; // 静态实例缓存
  static String _id = '';
  static Config get instance {
    if (_instance == null) {
      throw Exception("isar instance not initialized.");
    }
    return _instance!;
  }

  Future<String> getFilePath() async {
    final dir = await getMainStoreDir();
    final f = "${path.join(dir.path, _id)}.isar";
    return f;
  }

  open(String id) async {
    final dir = await getMainStoreDir();
    log.i("打开配置 $id");
    isar = await Isar.open(
      [ConfigSchema, FontSchema], // 你的模型 Schema 列表
      directory: dir.path, // 指定数据库存储目录
      inspector: true, // 启用 Isar Inspector 连接
      name: id, // 默认为default
    );
  }

  // 数据库不存在时，初始化
  init(String paramID) async {
    log.i("isar初始化");
    if (_instance != null) {
      await isar.close();
      _instance = null;
    }

    _id = paramID;
    final dir = await getMainStoreDir();
    final f = await getFilePath();
    if (!File(f).existsSync()) {}

    isar = await Isar.open(
      [ConfigSchema, FontSchema], // 你的模型 Schema 列表
      directory: dir.path, // 指定数据库存储目录
      inspector: true, // 启用 Isar Inspector 连接
      name: paramID, // 默认为default
    );
    final existingConfig = await isar.configs.where().findFirst();

    if (existingConfig != null) {
      _instance = existingConfig; // 从数据库加载实例
      return;
    }

    uid = UUID().build;
    _instance = this; // 将当前实例缓存为静态实例
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
  }

  void close() async {
    if (_instance != null) {
      _instance = null;
      await isar.close();
    }
  }

  Future<String> getInspectorURL() async {
    final info = await Service.getInfo();
    final serviceUri = info.serverUri;
    if (serviceUri == null) {
      return "";
    }
    final port = serviceUri.port;
    var path = serviceUri.path;
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.endsWith('=')) {
      path = path.substring(0, path.length - 1);
    }
    return 'https://inspect.isar.dev/${Isar.version}/#/$port$path';
  }

  setDevlopMode(bool b) async {
    print("更新配置 开发者模式 $b");
    instance.devlopMode = b;
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
  }

  setVisualNoneTitle(bool b) async {
    print("更新配置 隐藏空白标题 $b");
    instance.visualNoneTitle = b;
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
  }

  setDefaultShowTool(bool b) async {
    print("更新配置 默认显示工具栏 $b");
    instance.defaultShowTool = b;
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
  }

  setServerAddress(String str) async {
    print("更新配置 服务器地址 $str");
    instance.serverAddress = str;
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
  }

  setAPIs(List<API> apis) async {
    print("更新配置API列表 ");
    instance.apis =
        apis.map((e) => APIsar(key: e.key, extime: e.extime)).toList();
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
  }

  String getAPIkey() {
    if (instance.apis.isEmpty) {
      return '';
    }
    return instance.apis.first.key!;
  }
}

@embedded
class APIsar {
  String? key;
  String? extime;
  APIsar({this.key, this.extime});
  factory APIsar.fromJson(Map<String, dynamic> g) {
    return APIsar(
      key: g['apikey'],
      extime: g['extime'],
    );
  }
}
