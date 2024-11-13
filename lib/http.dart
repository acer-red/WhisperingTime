import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:sprintf/sprintf.dart';
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
    if (response.statusCode != 200) {
      print('return ${response.statusCode}');
      return;
    }
    print(response.body);
    // _packageData = jsonDecode(response.body);
  }

  posttheme() async {
    final Map<String, String> param = {
      'uid': uid,
    };
    final Map<String, dynamic> postdata = {
      'data': data,
      "uptime": DateTime.now().microsecondsSinceEpoch.toString(),
    };
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = Uri.http(baseurl, "/theme", param);
    print("$url\n$postdata");
    final response =
        await http.post(url, body: jsonEncode(postdata), headers: headers);
    if (response.statusCode != 200) {
      print('return ${response.statusCode}');
      return;
    }
    print(response.body);
    // _packageData = jsonDecode(response.body);
  }

  Future<List<ThemeListData>> gettheme() async {
    final Map<String, String> param = {
      'uid': uid,
    };

    final url = Uri.http(baseurl, "/theme", param);
    final response = await http.get(
      url,
    );
    if (response.statusCode != 200) {
      print('return ${response.statusCode}');
      return List.empty();
    }
    print(response.body);
    final res = await jsonDecode(response.body);
    if (res['err'] != 0) {
      print(res['msg']);
      return List.empty();
    }
    final List<dynamic> dataList= res['data'] as List;
     return dataList.map((item) => ThemeListData.fromJson(item)).toList();
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
