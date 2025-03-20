import 'package:shared_preferences/shared_preferences.dart';

class SP {
  static final SP _instance = SP._internal();
  SharedPreferences? _prefs;

  factory SP() {
    return _instance;
  }

  SP._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> setIsVisitor(bool s) {
    return Future.value(_prefs!.setBool("is_visitor", s));
  }

  Future<bool> setIsAutoLogin(bool s) {
    return Future.value(_prefs!.setBool("is_auto_login", s));
  }

  Future<bool> getIsAutoLogin() {
    return Future.value(_prefs!.getBool("is_auto_login"));
  }

  Future<bool> setRegisterAccount(String s) {
    return Future.value(_prefs!.setString("register_account", s));
  }

  Future<String> getRegisterAccount() {
    return Future.value(_prefs!.getString("register_account"));
  }

  Future<String> getID() async {
    final v = await getIsVisitor();
    if (v) {
      return "visitor";
    } else {
      return Future.value(_prefs!.getString("visitor_account"));
    }
  }

  Future<bool> getIsVisitor() {
    return Future.value(_prefs!.getBool("is_visitor"));
  }

  Future<bool> setbool(String s, bool b) {
    return _prefs!.setBool(s, b);
  }

  Future<bool> setString(String s, String str) {
    return _prefs!.setString(s, str);
  }
}
