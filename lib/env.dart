import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

enum LastPage { ok, delete, nochange, change, create, nocreate }

class Level {
  static const List<String> l = ['未分类', '平淡的', '触动的', '重要的', '深刻的'];

  String string(int index) {
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
    if (b == null) {
      b = false;
      setBool("devlop_mode", b);
      return b;
    }
    return b;
  }

  Future<bool> setDevlopMode(bool b) async {
    print("更新配置 开发者模式 $b");
    return setBool("devlop_mode", b);
  }

  bool getVisualNoneTitle() {
    bool? b = _prefs?.getBool("VisualNoneTitle");
    if (b == null) {
      b = false;
      setBool("VisualNoneTitle", b);
      return b;
    }
    return b;
  }

  Future<bool> setVisualNoneTitle(bool b) async {
    print("更新配置 隐藏空白标题 $b");
    return setBool("devlop_mode", b);
  }

  Future<bool> setString(String key, String value) {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  Future<bool> setBool(String key, bool value) {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }
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

  static String nowTimestampString() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
  }

  static String toTimestampString(DateTime t) {
    return (t.millisecondsSinceEpoch / 1000).round().toString();
  }

  static DateTime getForver() {
    return DateTime.now().add(const Duration(days: 9999999));
  }

  // 默认为一天
  static Duration getOverTime() {
    return const Duration(days: 1);
  }

  static DateTime getNextDay() {
    return DateTime.now().add(Time.getOverTime());
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

  return isConfirmed ?? false; // 如果用户没有点击按钮，则默认为 false
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
  static final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  static OverlayEntry? _overlayEntry;
  static Timer? _timer; // 定义一个 Timer 变量

  static void error(String content) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red.shade800),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    content,
                    style: TextStyle(
                        fontSize: 15.0,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlayKey.currentState!.insert(_overlayEntry!);

    _timer = Timer(Duration(seconds: 5), () {
      hideOverlay();
    });
  }

  static void hideOverlay() {
    _timer?.cancel(); // 取消定时器
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
