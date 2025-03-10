import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
enum LastPage {
  ok,
  err,
  delete,
  nochange,
  change,
  changeConfig,
  create,
  nocreate
}
extension LastPageMethods on LastPage {
  bool get isErr => this == LastPage.err;
}
const String appName = "whipseringtime";
const String defaultGroupName = "默认分组";

var log = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // 设置调用堆栈层级为1
  ),
);

class Level {
  static const List<String> l = ['未分类', '平淡的', '触动的', '重要的', '深刻的'];

  static String string(int index) {
    return l[index];
  }

  static Widget levelWidget(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(l[index]),
    );
  }
}

// class Settings {
//   static final Settings _instance = Settings._internal();
//   SharedPreferences? _prefs;

//   factory Settings() {
//     return _instance;
//   }

//   Settings._internal();

//   Future<void> init() async {
//     _prefs ??= await SharedPreferences.getInstance();
//     print("用户ID ${getuid()}");
//   }

//   String getuid() {
//     String? uid = _prefs?.getString("uid");
//     if (uid == null) {
//       uid = UUID().build;
//       setString("uid", uid);
//       return uid;
//     }
//     return uid.replaceAll("-", "");
//   }

  // String getServerAddress() {
  //   String? str = _prefs?.getString("server_address");
  //   if (str == null) {
  //     str = '127.0.0.1:21523';
  //     setString("server_address", str);
  //     return str;
  //   }
  //   return str;
  // }

  // Future<bool> setServerAddress(String str) {
  //   print("更新配置 服务器地址 $str");
  //   return setString("server_address", str);
  // }

  // String getFontHubServerAddress() {
  //   String? str = _prefs?.getString("font_hub_server_address");
  //   if (str == null) {
  //     str = 'https://fonthub.acer.red:21520';
  //     setString("font_hub_server_address", str);
  //     return str;
  //   }
  //   return str;
  // }

  // Future<bool> setFontHubServerAddress(String str) {
  //   print("更新配置 fonthub服务器地址 $str");
  //   return setString("font_hub_server_address", str);
  // }

  // bool getDevlopMode() {
  //   bool? b = _prefs?.getBool("devlop_mode");

  //   if (b != null) {
  //     return b;
  //   }

  //   setBool("devlop_mode", false);
  //   return false;
  // }

  // Future<bool> setDevlopMode(bool b) async {
  //   print("更新配置 开发者模式 $b");
  //   return setBool("devlop_mode", b);
  // }

  // bool getVisualNoneTitle() {
  //   bool? b = _prefs?.getBool("VisualNoneTitle");

  //   if (b != null) {
  //     return b;
  //   }

  //   setBool("VisualNoneTitle", false);
  //   return false;
  // }

  // Future<bool> setVisualNoneTitle(bool b) async {
  //   print("更新配置 隐藏空白标题 $b");
  //   return setBool("VisualNoneTitle", b);
  // }

  // bool getDefaultShowTool() {
  //   bool? b = _prefs?.getBool("DefaultShowTool");

  //   if (b != null) {
  //     return b;
  //   }

  //   setBool("DefaultShowTool", true);
  //   return true;
  // }

  // Future<bool> setDefaultShowTool(bool b) async {
  //   print("更新配置 默认显示工具栏 $b");
  //   return setBool("DefaultShowTool", b);
  // }

//   Future<bool> setString(String key, String value) {
//     return _prefs?.setString(key, value) ?? Future.value(false);
//   }

//   Future<bool> setBool(String key, bool value) {
//     return _prefs?.setBool(key, value) ?? Future.value(false);
//   }
// }

Future<Directory> getCacheDir() async {
  final directory = await getApplicationCacheDirectory();
  return directory;
}
// Future<Directory> getMainStoreDir() async {
//   final document = await getApplicationDocumentsDirectory();
//   final storePath =path.join(document.path,appName);
//   return Directory(storePath);
// }
Future<Directory> getMainStoreDir() async {
  final document = await getApplicationDocumentsDirectory();
  return document;
}