import 'package:flutter/material.dart';
import 'package:whispering_time/pages/theme/theme.dart';
import 'package:whispering_time/pages/user/user.dart';
import 'package:whispering_time/pages/setting/setting.dart';
import 'package:whispering_time/pages/feedback/feedback.dart';
import 'package:whispering_time/pages/welcome.dart';
import 'package:whispering_time/pages/font_manager/font_manager.dart';

import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/export.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => menu(),
        ),
      ]),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 0, top: 0, left: 50, right: 50),
          child: Column(
            spacing: 40,
            children: [
              UserPage(),
              ThemePage(),
            ],
          ),
        ),
      ),
    );
  }

  menu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 0, 0, 0),
      items: [
         PopupMenuItem(
          child: Row(
            spacing: 10,
            children: [
              Icon(Icons.settings),
              Text("设置"),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingPage(),
              ),
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            spacing: 10,
            children: [Icon(Icons.download), Text("导出")],
          ),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return Export(ResourceType.theme, title: "导出所有印迹数据");
              },
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            spacing: 10,
            children: [Icon(Icons.font_download), Text("字体")],
          ),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return FontManager();
              },
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            spacing: 10,
            children: [
              Icon(Icons.chat),
              Text("反馈"),
            ],
          ),
          
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedbackPage(),
              ),
            );
          },
        ),
        PopupMenuItem(
            child: Row(
              spacing: 10,
              children: [
                Icon(Icons.exit_to_app),
                Text('退出'),
              ],
            ),
            onTap: () {
              logout();
            }),
      ],
    );
  }

  logout() {
    showConfirmationDialog(context, MyDialog(content: "确定退出吗？")).then((value) {
      if (!value) {
        return;
      }
      Config().close();
      SP().setIsAutoLogin(false);
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Welcome(),
            ));
      }
    });
  }
}
