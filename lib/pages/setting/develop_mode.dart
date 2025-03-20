import 'package:flutter/material.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:url_launcher/url_launcher.dart';

class Devleopmode extends StatefulWidget {
  @override
  State createState() => _DevleopmodeState();
}

class _DevleopmodeState extends State<Devleopmode> {
  bool _isOpened = Config.instance.devlopMode;
  TextEditingController serverAddressControl = TextEditingController();
  String isarurl = '';
  @override
  void initState() {
    super.initState();
    serverAddressControl.text = Config.instance.serverAddress;
    init();
  }

  init() {
    setState(() {
      Config().getInspectorURL().then((onValue) {
        isarurl = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => backPage(),
        ),
        title: Text("开发者模式"),
      ),
      body: ListView(
        
        children: [
          SwitchListTile(
            title: const Text('开发者模式'),
            value: _isOpened,
            onChanged: (bool value) {
              setState(() {
                Config.instance.setDevlopMode(value);
                _isOpened = value;
              });
            },
          ),
          !_isOpened
              ? SizedBox.shrink()
              :divider(),
          !_isOpened
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        '服务器地址',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.right,
                        enabled: _isOpened,
                        maxLines: 1,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: serverAddressControl.text,
                          border: InputBorder.none,
                        ),
                        controller: serverAddressControl,
                        onChanged: (value) {
                          serverAddressControl.text = value;
                          Config.instance.setServerAddress(value);
                        },
                      ),
                    )
                  ]),
                ),
          !_isOpened ? SizedBox.shrink() : divider(),
           !_isOpened
              ? SizedBox.shrink()
              :Padding(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Row(children: [
              Text(
                '数据库后台管理',
                style: TextStyle(fontSize: 16.0),
              ),
              Spacer(),
              isarurl.isEmpty
                  ? SizedBox.shrink()
                  : TextButton(
                      onPressed: () {
                        _launchUrl(isarurl);
                      },
                      child: Text("打开"),
                    )
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  backPage() {
    if (_isOpened != Config.instance.devlopMode) {
      Config.instance.setDevlopMode(_isOpened);
    }
    if (serverAddressControl.text != Config.instance.serverAddress) {
      Config.instance.setServerAddress(serverAddressControl.text);
    }
    Navigator.of(context).pop();
  }
}
