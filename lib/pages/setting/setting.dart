import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/services/Isar/config.dart';

import 'font_manager.dart';
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
                onPressed: () => dialogFontManager(),
                child: Container(
                    padding: EdgeInsets.only(bottom: 15, top: 15, left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text("字体管理"))),
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
                    Clipboard.setData(ClipboardData(text: Config.instance.uid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('文本已复制到剪贴板')),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    "用户ID：${Config.instance.uid}",
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Future<void> dialogExport() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Export(ResourceType.theme, title: "导出所有数据");
      },
    );
  }

  Future<void> dialogFontManager() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return FontManager();
      },
    );
  }
}
