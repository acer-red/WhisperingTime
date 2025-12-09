import 'package:shared_preferences/shared_preferences.dart';
import 'package:whispering_time/util/uuid.dart';

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

  void over() {
    _prefs?.clear();
  }

  Future<bool> setIsVisitor(bool s) {
    return Future.value(_prefs!.setBool("is_visitor", s));
  }

  Future<bool> setIsAutoLogin(bool s) {
    return Future.value(_prefs!.setBool("is_auto_login", s));
  }

  Future<bool> setIsVisitorLogged(bool s) {
    return Future.value(_prefs!.setBool("is_visitor_logged", s));
  }

  bool getIsVisitorLogged() {
    final b = _prefs!.getBool("is_visitor_logged");
    if (b == null) {
      setIsVisitorLogged(false);
      return false;
    }
    return b;
  }

  bool getIsAutoLogin() {
    final v = _prefs!.getBool("is_auto_login");
    if (v == null) {
      setIsAutoLogin(false);
      return false;
    }
    return v;
  }

  Future<bool> setUID(String s) {
    return Future.value(_prefs!.setString("uid", s));
  }

  String getUID() {
    final v = _prefs!.getString("uid");
    if (v == null) {
      final uid = UUID().build;
      setUID(uid);
      return uid;
    }
    if (v.isEmpty) {
      final uid = UUID().build;
      setUID(uid);
      return uid;
    }
    return v;
  }

  Future<bool> setVisitorUID(String s) {
    return Future.value(_prefs!.setString("visitor_uid", s));
  }

  String getVisitorUID() {
    final v = _prefs!.getString("visitor_uid");
    if (v == null) {
      final uid = UUID().build;
      setVisitorUID(uid);
      return uid;
    }
    return v;
  }

  bool getIsVisitor() {
    final v = _prefs!.getBool("is_visitor");
    if (v == null) {
      setIsVisitor(true);
      return true;
    }
    return v;
  }

  Future<bool> setbool(String s, bool b) {
    return _prefs!.setBool(s, b);
  }

  Future<bool> setString(String s, String str) {
    return _prefs!.setString(s, str);
  }
}
