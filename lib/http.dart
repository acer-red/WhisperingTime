import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:sprintf/sprintf.dart';
class Themerequest {
  final String name;
  final String id;
  Themerequest(this.name, this.id);
  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };
}

class Http {
  final String? data;
  final String uid;
  static const String baseurl = "192.168.1.201:21523";
  // static const String baseurl="127.0.0.1:21523";
  // static const String baseurl = "192.168.3.68:21523";

  Http({this.data, required this.uid});

  postdoc(String docid) async {
    Map<String, String> param = {
      'uid': uid,
    };
    Map<String, dynamic> postdata = {
      'data': data,
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
      "docid": docid,
    };

    final packageUrl = Uri.http(baseurl, "/doc", param);
    final response = await http.post(packageUrl, body: postdata);
    print(response.body);
    return jsonDecode(response.body);
  }

  posttheme() async {
    final Map<String, String> param = {
      'uid': uid,
    };
    final Map<String, dynamic> postdata = {
      'data': Themerequest(data!, "").toJson(),
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(baseurl, "/theme", param);
    print("$url\n$postdata");
    final response =
        await http.post(url, body: jsonEncode(postdata), headers: headers);
    print(response.body);
    return jsonDecode(response.body);
  }

  puttheme(String name, String id) async {
    final Map<String, String> param = {
      'uid': uid,
    };
    final Map<String, dynamic> postdata = {
      'data': Themerequest(name, id),
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(baseurl, "/theme", param);
    print("$url\n$postdata");
    final response =
        await http.put(url, body: jsonEncode(postdata), headers: headers);
    print(response.body);
    return jsonDecode(response.body);
  }

  Future<List<ThemeListData>> gettheme() async {
    if (uid==""){
      print("跳过");
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
      print(res['msg']);
      return List.empty();
    }
    final List<dynamic> dataList = res['data'] as List;
    print(response.body);
    return dataList.map((item) => ThemeListData.fromJson(item)).toList();
  }

  deletetheme() async {
    final Map<String, String> param = {
      'uid': uid,
      'themeid': data!,
    };
    final url = Uri.http(baseurl, "/theme", param);
    final response = await http.delete(url);
    print(response.body);
    return jsonDecode(response.body);
  }
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
