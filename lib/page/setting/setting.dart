import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'show.dart';
import 'develop_mode.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("设置"),
        ),
        body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Show()),
                  );
                },
                child: Container(
                    padding: EdgeInsets.only(bottom: 15, top: 15,left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text("显示"))),
            divider(),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Devleopmode()),
                  );
                },
                child: Container(
                    padding: EdgeInsets.only(bottom: 15, top: 15,left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text("开发者"))),
          ],
        ));
  }
}
