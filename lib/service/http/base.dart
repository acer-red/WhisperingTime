import 'package:whispering_time/service/isar/config.dart';

enum Method { get, post, put, delete }

class HTTPConfig {
  static const String indexServerAddress = String.fromEnvironment(
    'INDEX_SERVER_ADDRESS',
    defaultValue: Config.indexServerAddress,
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

class URI {
  Uri get(String serverAddress, String path, {Map<String, String>? param}) {
    if (serverAddress.startsWith("https")) {
      return Uri.https(serverAddress.split("https://").last, path, param);
    } else if (serverAddress.startsWith("http")) {
      return Uri.http(serverAddress.split("http://").last, path, param);
    } else {
      throw Uri.http(serverAddress, path, param);
    }
  }
}
