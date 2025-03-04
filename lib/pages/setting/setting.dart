import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whispering_time/utils/env.dart';
import 'show.dart';
import 'develop_mode.dart';
import 'package:whispering_time/utils/export.dart';

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
                onPressed: () => dialogExport(),
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

  Future<void> dialogExport() async {
    Export().dialog(context, "导出所有数据", () {
      return  Export.themePDF();
    }, () {
      return Export.themeTXT();
    });
  }
}
