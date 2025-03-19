import 'package:whispering_time/services/isar/config.dart';

enum Method { get, post, put, delete }

class HTTPConfig {
  static const  String indexServerAddress = String.fromEnvironment(
    'INDEX_SERVER_ADDRESS',
    defaultValue:  Config.indexServerAddress,
  );
}

class Basic {
  int err;
  String msg;
  Basic({required this.err, required this.msg});

  bool get isNotOK => err != 0;

  bool get isOK => err == 0;

  void getmsg() {
    print(msg);
  }
}
