import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:whispering_time/pages/welcome.dart';

class SettingPage extends StatefulWidget {
  @override
  State createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isOpened = Config.instance.devlopMode;
  TextEditingController serverAddressControl = TextEditingController();
  String isarurl = '';
  bool visualNoneTitle = Config.instance.visualNoneTitle;
  bool defaultShowTool = Config.instance.defaultShowTool;

  @override
  void initState() {
    super.initState();
    serverAddressControl.text = Config.instance.serverAddress;
    init();
  }

  void init() async {
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
        title: Text("设置"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              '显示',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            enabled: false, // 设置为 false 使其看起来像标题
          ),
          Column(
            children: [
              SwitchListTile(
                title: const Text('隐藏空白标题'),
                value: visualNoneTitle,
                onChanged: (bool value) {
                  setState(() {
                    visualNoneTitle = value;
                    Config.instance.setVisualNoneTitle(value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('默认显示工具栏'),
                value: defaultShowTool,
                onChanged: (bool value) {
                  setState(() {
                    defaultShowTool = value;
                    Config.instance.setDefaultShowTool(value);
                  });
                },
              ),
            ],
          ),
          ListTile(
            title: Text(
              '调试',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            enabled: false, // 设置为 false 使其看起来像标题
          ),
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
              : Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Column(
                    spacing: 18,
                    children: [
                      Row(children: [
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
                      isarurl.isEmpty
                          ? SizedBox.shrink()
                          : Row(children: [
                              Text(
                                '数据库后台管理',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  _launchUrl(isarurl);
                                },
                                child: Text("打开"),
                              )
                            ]),
                      Row(children: [
                        Text(
                          '本地数据管理',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            cleanDatabase();
                          },
                          child: Text("清空"),
                        )
                      ]),
                    ],
                  ),
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

  void cleanDatabase() async {
    final isarPath = await Config().getFilePath();
    final isarLockPath = "$isarPath.lock";
    await Config().close();
    SP().over();
    final info = await PackageInfo.fromPlatform();
    final d = await getLibraryDir();
    final spPath =
        path.join(d.path, "Preferences", "${info.packageName}.plist");
    print("isarPath: $isarPath");
    print("spPath: $spPath");

    final isarFile = File(isarPath);
    if (await isarFile.exists()) {
      await isarFile.delete();
    }
    final lockFile = File(isarLockPath);
    if (await lockFile.exists()) {
      await lockFile.delete();
    }
    final spFile = File(spPath);
    if (await spFile.exists()) {
      await spFile.delete();
    }

    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Welcome()));
    }
  }

  void backPage() {
    if (_isOpened != Config.instance.devlopMode) {
      Config.instance.setDevlopMode(_isOpened);
    }
    if (serverAddressControl.text != Config.instance.serverAddress) {
      Config.instance.setServerAddress(serverAddressControl.text);
    }
    Navigator.of(context).pop();
  }
}
