import 'package:flutter/material.dart';
import 'package:whispering_time/pages/theme/theme.dart';
import 'package:whispering_time/pages/setting/setting.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 10, top: 10.0, left: 50, right: 50),
          child: Column(
            children: [
              ThemePage(),
              SizedBox(height: 40),
              SettingPage(),
            ],
          ),
        ),
      ),
    );
  }
}
