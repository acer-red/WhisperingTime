import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';


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

class Settings {
  static final Settings _instance = Settings._internal();
  SharedPreferences? _prefs;

  factory Settings() {
    return _instance;
  }

  Settings._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    print("用户ID ${getuid()}");
  }

  String getuid() {
    String? uid = _prefs?.getString("uid");
    if (uid == null) {
      uid = Uuid().v7().replaceAll("-", "");
      setString("uid", uid);
      return uid;
    }
    return uid.replaceAll("-", "");
  }

  String getServerAddress() {
    String? str = _prefs?.getString("server_address");
    if (str == null) {
      str = '127.0.0.1:21523';
      setString("server_address", str);
      return str;
    }
    return str;
  }

  Future<bool> setServerAddress(String str) {
    print("更新配置 服务器地址 $str");
    return setString("server_address", str);
  }

  bool getDevlopMode() {
    bool? b = _prefs?.getBool("devlop_mode");

    if (b != null) {
      return b;
    }

    setBool("devlop_mode", false);
    return false;
  }

  Future<bool> setDevlopMode(bool b) async {
    print("更新配置 开发者模式 $b");
    return setBool("devlop_mode", b);
  }

  bool getVisualNoneTitle() {
    bool? b = _prefs?.getBool("VisualNoneTitle");

    if (b != null) {
      return b;
    }

    setBool("VisualNoneTitle", false);
    return false;
  }

  Future<bool> setVisualNoneTitle(bool b) async {
    print("更新配置 隐藏空白标题 $b");
    return setBool("VisualNoneTitle", b);
  }

  bool getDefaultShowTool() {
    bool? b = _prefs?.getBool("DefaultShowTool");

    if (b != null) {
      return b;
    }

    setBool("DefaultShowTool", true);
    return true;
  }

  Future<bool> setDefaultShowTool(bool b) async {
    print("更新配置 默认显示工具栏 $b");
    return setBool("DefaultShowTool", b);
  }

  Future<bool> setString(String key, String value) {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  Future<bool> setBool(String key, bool value) {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }
}

class UUID {
  static String get create => Uuid().v7().replaceAll("-", "");
}

class Time {
  static DateTime datetime(String t) {
    if (t.isEmpty) {
      return DateTime.now();
    }
    int timestamp = int.parse(t);

    return DateTime.fromMillisecondsSinceEpoch(timestamp *= 1000);
  }

  static String string(DateTime t) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(t);
  }

  static DateTime stringToTime(String t) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    // 获取北京时区
    // tz.Location beijing = tz.getLocation('Asia/Shanghai');
    // 将 UTC 时间转换为北京时间
    // DateTime beijingTime = tz.TZDateTime.from(utcTime, beijing);
    return formatter.parse(t, false);
  }
  static DateTime stringToTimeHasT(String t) {
    return DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(t, false);
  }
  static String nowTimestampString() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
  }

  static String toTimestampString(DateTime t) {
    return (t.millisecondsSinceEpoch / 1000).round().toString();
  }

  static DateTime getForver() {
    return DateTime.now().add(const Duration(days: 36500));
  }

  // 定格时间设置
  static Duration getOverTime() {
    return const Duration(days: 7);
  }

  static DateTime getOverDay() {
    return DateTime.now().add(Time.getOverTime());
  }

  static Future<DateTime?> datePacker(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
  }

  static String getCurrentTime() {
    return DateFormat('yyyy年MM月dd日HH时mm分ss秒').format(DateTime.now());
  }
}

class MyDialog {
  String title;
  String content;
  MyDialog({required this.title, required this.content});
}

// 定义一个函数，用于显示弹窗
Future<bool> showConfirmationDialog(
    BuildContext context, MyDialog dialog) async {
  bool? isConfirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(dialog.title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(dialog.content), // 显示传入的内容
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop(false); // 返回 false 表示取消
            },
          ),
          TextButton(
            child: Text('确定'),
            onPressed: () {
              Navigator.of(context).pop(true); // 返回 true 表示确定
            },
          ),
        ],
      );
    },
  );

  return isConfirmed ?? false;
}

Divider divider() {
  return Divider(
    height: 20, // 分割线高度 (包含上下间距)
    thickness: 1, // 分割线粗细
    indent: 20, // 左侧缩进
    endIndent: 20, // 右侧缩进
    color: Colors.grey[200], // 分割线颜色
  );
}

class Msg {
  static diy(BuildContext context, String desc, {String? title}) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: Text(desc),
          actions: <Widget>[
            TextButton(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
