import 'package:flutter/material.dart';
import 'package:whispering_time/pages/theme/theme.dart';
import 'package:whispering_time/pages/user/user.dart';
import 'package:whispering_time/pages/setting/setting.dart';
import 'package:whispering_time/pages/welcome.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/ui.dart';

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
          icon: const Icon(Icons.logout),
          onPressed: logout,
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
              SettingPage(),
            ],
          ),
        ),
      ),
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
