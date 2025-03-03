import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whispering_time/env.dart';
import 'show.dart';
import 'develop_mode.dart';
import 'package:whispering_time/export.dart';

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
                    padding: EdgeInsets.only(bottom: 15, top: 15, left: 15),
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
                    padding: EdgeInsets.only(bottom: 15, top: 15, left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text("开发者"))),
            divider(),
            TextButton(
                onPressed: () => dialogExportOption(),
                child: Container(
                    padding: EdgeInsets.only(bottom: 15, top: 15, left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text("数据导出"))),
            divider(),
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: Settings().getuid()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('文本已复制到剪贴板')),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    "用户ID：${Settings().getuid()}",
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Future<void> dialogExportOption() async {
    await showDialog<int>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: null,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("导出到本地"),
                ElevatedButton(
                    onPressed: () {
                      Export.themeTXT();
                      Navigator.of(context).pop(0);
                    },
                    child: Text("纯文本")),
                divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
