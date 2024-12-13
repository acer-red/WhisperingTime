import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SharedPrefsManager {
  static final SharedPrefsManager _instance = SharedPrefsManager._internal();
  SharedPreferences? _prefs;

  factory SharedPrefsManager() {
    return _instance;
  }

  SharedPrefsManager._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    print("用户ID${getuid()}");
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

  Future<bool> setString(String key, String value) {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }
}

class Setting {
  static final Setting _instance = Setting._internal(); // 私有静态实例

  factory Setting() {
    return _instance;
  }

  Setting._internal();

  bool isVisualNoneTitle = true;

  bool visualNoneTitle() {
    return isVisualNoneTitle == true;
  }
}
