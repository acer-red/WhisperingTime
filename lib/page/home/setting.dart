import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/service/sp/sp.dart';
import 'package:whispering_time/util/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:whispering_time/welcome.dart';
import 'package:whispering_time/service/http/official.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/grpc_generated/whisperingtime.pb.dart';
import 'package:whispering_time/util/secure.dart';

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
  bool keepAnimationWhenLostFocus = Config.instance.keepAnimationWhenLostFocus;

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
              SwitchListTile(
                title: const Text('失去焦点保持动画'),
                value: keepAnimationWhenLostFocus,
                onChanged: (bool value) {
                  setState(() {
                    keepAnimationWhenLostFocus = value;
                    Config.instance.setKeepAnimationWhenLostFocus(value);
                  });
                },
              ),
            ],
          ),
          ListTile(
            title: Text(
              '账号',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            enabled: false,
          ),
          ListTile(
            title: Text('清空账号'),
            subtitle: Text('删除应用数据或注销账户'),
            onTap: _showClearAccountDialog,
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

  void _showClearAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('清空账号'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('删除应用数据'),
                subtitle: Text('执行后，当前应用的本地数据和云端数据将删除。'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(false);
                },
              ),
              ListTile(
                title: Text('删除账户'),
                subtitle: Text('执行后，当前账号的信息将无法登录任何应用。'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(bool isDeleteAccount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认操作'),
        content:
            Text(isDeleteAccount ? '确定要注销账户吗？此操作不可逆。' : '确定要删除应用数据吗？此操作不可逆。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _executeDelete(isDeleteAccount);
            },
            child: Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _executeDelete(bool isDeleteAccount) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. HTTP Request
      final http = Http();
      final res =
          isDeleteAccount ? await http.deleteAccount() : await http.unbindApp();
      if (!mounted) return;
      if (res.isNotOK) {
        Navigator.pop(context); // Dismiss loading
        return;
      }

      // 2. gRPC Request
      final grpcRes = await Grpc().deleteUserData(DeleteUserDataRequest());
      if (!mounted) return;
      if (grpcRes.isNotOK) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('服务器数据删除失败: ${grpcRes.msg}')));
        return;
      }

      // 3. Clear Local Data
      await Storage().deleteAll();
      cleanDatabase();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('发生错误: $e')));
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
