import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whispering_time/env.dart';

class Themerequest {
  final String name;
  final String id;
  Themerequest(this.name, this.id);
  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };
}

class ThemeListData {
  String name;
  String id;
  ThemeListData({required this.name, required this.id});

  factory ThemeListData.fromJson(Map<String, dynamic> json) {
    return ThemeListData(
      name: json['name'] as String,
      id: json['id'] as String,
    );
  }
}

class Basic {
  int err;
  String msg;
  Basic({required this.err, required this.msg});
}

class ResponseDeleteGroup {
  int err;
  String msg;
  ResponseDeleteGroup(this.err, this.msg);
}

class ResponsePostGroup extends Basic {
  String id;
  ResponsePostGroup({required super.err, required super.msg, required this.id});
  factory ResponsePostGroup.fromJson(Map<String, dynamic> json) {
    return ResponsePostGroup(
      err: json['err'] as int,
      msg: json['msg'] as String,
      id: json['data']['id'] as String,
    );
  }
}

class ResponsePutGroup extends Basic {
  ResponsePutGroup({required super.err, required super.msg});
  factory ResponsePutGroup.fromJson(Map<String, dynamic> json) {
    return ResponsePutGroup(
      err: json['err'] as int,
      msg: json['msg'] as String,

    );
  }
}
class RequestPutGroup {
  String name;
  String id;
  RequestPutGroup({required this.name, required this.id});
    Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };
}
class RequestPostGroup {
  String name;
  RequestPostGroup({required this.name});
    Map<String, dynamic> toJson() => {
        'name': name,
      };
}

class GroupListData {
  String name;
  String id;
  GroupListData({required this.name, required this.id});

  factory GroupListData.fromJson(Map<String, dynamic> json) {
    return GroupListData(
      name: json['name'] as String,
      id: json['id'] as String,
    );
  }
}

class Http {
  final String? content;

  // theme id
  final String? tid;
  // group id
  final String? gid;
  final String? docid;
  static final String uid = SharedPrefsManager().getuid();
  // static const String baseurl = "192.168.1.201:21523";
  static const String baseurl = "127.0.0.1:21523";
  // static const String baseurl = "192.168.3.68:21523";

  Http({this.content, this.tid, this.gid, this.docid});

  Future<List<ThemeListData>> gettheme() async {
    if (uid == "") {
      return List.empty();
    }

    final Map<String, String> param = {
      'uid': uid,
    };

    final url = Uri.http(baseurl, "/theme", param);
    final response = await http.get(
      url,
    );
    if (response.statusCode != 200) {
      return List.empty();
    }

    final res = await jsonDecode(response.body);
    if (res['err'] != 0) {
      return List.empty();
    }
    final List<dynamic> dataList = res['data'] as List;
    return dataList.map((item) => ThemeListData.fromJson(item)).toList();
  }

  posttheme() async {
    const String path = "/theme";

    final Map<String, String> param = {
      'uid': uid,
    };
    final Map<String, dynamic> data = {
      'data': Themerequest(content!, "").toJson(),
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final u = Uri.http(baseurl, path, param);

    final response =
        await http.post(u, body: jsonEncode(data), headers: headers);
    print(response.body);
    return jsonDecode(response.body);
  }

  puttheme(String name, String id) async {
    const String path = "/theme";

    final Map<String, String> param = {
      'uid': uid,

    };
    final Map<String, dynamic> data = {
      'data': Themerequest(name, id).toJson(),
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final u = Uri.http(baseurl, path, param);
    final response =
        await http.put(u, body: jsonEncode(data), headers: headers);
    print(response.body);
    return jsonDecode(response.body);
  }

  deletetheme() async {
    const String path = "/theme";

    final Map<String, String> param = {
      'uid': uid,
      'tid': content!,
    };
    final url = Uri.http(baseurl, path, param);
    final response = await http.delete(url);
    print(response.body);
    return jsonDecode(response.body);
  }

  postdoc({String? group, String? title}) async {
    const String path = "/doc";
    Map<String, String> param = {
      'uid': uid,
    };
    Map<String, dynamic> data = {
      'data': content,
      'tid': tid!,
      'title': title,
      'group': group,
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final u = Uri.http(baseurl, path, param);
    final response =
        await http.post(u, body: jsonEncode(data), headers: headers);

    print(response.body);
    return jsonDecode(response.body);
  }

  Future<List<GroupListData>> getgroup() async {
    if (tid == "") {
      return List.empty();
    }

    final Map<String, String> param = {
      'uid': uid,
      'tid': tid!,
    };

    final url = Uri.http(baseurl, "/group", param);
    final response = await http.get(
      url,
    );
    if (response.statusCode != 200) {
      return List.empty();
    }

    final res = await jsonDecode(response.body);
    if (res['err'] != 0) {
      return List.empty();
    }
    if (res['data'] == null) {
      return List.empty();
    }
    final List<dynamic> dataList = res['data'] as List;
    print(response.body);
    return dataList.map((item) => GroupListData.fromJson(item)).toList();
  }

  Future<ResponseDeleteGroup> deletegroup() async {
    const String path = "/group";

    final Map<String, String> param = {'uid': uid, 'gid': gid!};
    final url = Uri.http(baseurl, path, param);
    final response = await http.delete(url);
    print(response.body);
    final json = jsonDecode(response.body);

    final res = ResponseDeleteGroup(json['err'], json['msg']);
    return res;
  }

  Future<ResponsePostGroup> postgroup(RequestPostGroup req) async {
    const String path = "/group";

    if (tid == "") {
      throw ArgumentError('缺少tid');
    }

    final Map<String, String> param = {
      'uid': uid,
      'tid': tid!,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final url = Uri.http(baseurl, path, param);
    final response =
        await http.post(url, body: jsonEncode(data), headers: headers);
    if (response.statusCode != 200) {
      throw ArgumentError('请求错误');
    }

    final res = ResponsePostGroup.fromJson(await jsonDecode(response.body));

    return res;
  }

  Future<ResponsePutGroup> putgroup(RequestPutGroup req) async {
    if (tid == "") {
      throw ArgumentError('缺少tid');
    }
    const String path = "/group";

    final Map<String, String> param = {
      'uid': uid,
      'tid': tid!,
    };
    final Map<String, dynamic> data = {
      'data': req.toJson(),
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(baseurl, path, param);
    final response =
        await http.put(url, body: jsonEncode(data), headers: headers);

    if (response.statusCode != 200) {
      throw ArgumentError('请求错误');
    }

    final res = ResponsePutGroup.fromJson(await jsonDecode(response.body));

    return res;
  }
}
