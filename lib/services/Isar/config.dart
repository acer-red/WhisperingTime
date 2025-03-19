import 'package:isar/isar.dart';
import 'env.dart';
import 'package:whispering_time/utils/uuid.dart';

part 'config.g.dart';

@Collection()
class Config {
  Id id = Isar.autoIncrement;

  String uid = '';
  String serverAddress = 'http://127.0.0.1:21523';
  String fontHubServerAddress = "https://fonthub.acer.red:21520";
  String indexServerAddress = "https://acer.red";
  bool devlopMode = false;
  bool visualNoneTitle = false;
  bool defaultShowTool = true;

  static Config? _instance; // 静态实例缓存

  static Config get instance {
    if (_instance == null) {
      throw Exception("Config instance not initialized. Call init() first.");
    }
    return _instance!;
  }

  init() async {
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
  // Future<String> getuid()async {
  //   final c =await isar.configs.where().findFirst();
  //  return c!.uid;
  // }

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
}
