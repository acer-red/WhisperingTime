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
  static const String fontHubServerAddress = "https://fonthub.acer.red:21520";
  static const String indexServerAddress = "https://acer.red";
  bool devlopMode = false;
  bool visualNoneTitle = false;
  bool defaultShowTool = true;
  List<APIsar> apis = [];

  static Config? _instance; // 静态实例缓存

  static Config get instance {
    if (_instance == null) {
      throw Exception("Config instance not initialized. Call init() first.");
    }
    return _instance!;
  }

  init(String id) async {
    if (_instance != null) {
      _instance = null;
      await isar.close();
    }

    final dir = await getMainStoreDir();
    final f = "${path.join(dir.path, id)}.isar";
    if (!File(f).existsSync()) {
      print("数据文件不存在");
      // 加入导入数据文件
    }
    print("数据文件库路径: $f");
    isar = await Isar.open(
      [ConfigSchema, FontSchema], // 你的模型 Schema 列表
      directory: dir.path, // 指定数据库存储目录
      inspector: true, // 启用 Isar Inspector 连接
      name: id, // 默认为default
    );

    // 检查 Isar 中是否已经存在 Config 对象
    final existingConfig = await isar.configs.where().findFirst();

    // 如果 Isar 中没有 Config 对象
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
    print("更新配置API列表 $apis");
    final l = apis.map((e) => APIsar(key: e.key, extime: e.extime)).toList();
    instance.apis = l;
    await isar.writeTxn(() async {
      await isar.configs.put(this);
    });
    return;
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
