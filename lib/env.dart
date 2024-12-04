import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LastPage {
  delete ,
  nochange,
  change,
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
  }

  String getuid() {
    String? uid =  _prefs?.getString("uid");
    if (uid == null || uid.isEmpty) {
      uid = Uuid().v7();
      setString("uid", uid.replaceAll("-", ""));
      return uid;
    }
    return uid.replaceAll("-", "");
  }

  Future<bool> setString(String key, String value) {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }
}
