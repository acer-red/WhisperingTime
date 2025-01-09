import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whispering_time/env.dart';
import 'package:whispering_time/http.dart';
import 'show.dart';
import 'develop_mode.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
                onPressed: () => export(),
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

  export() async {
    int ret = await dialogExportOption();
    switch (ret) {
      case 0:
        exportDesktopTXT();
        break;
      default:
        break;
    }
  }

  exportDesktopTXT() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    // 用户取消了操作
    if (selectedDirectory == null) {
      return;
    }

    Directory directory = Directory(selectedDirectory);
    print('选择的文件夹路径：${directory.path}');

    final themes = await Http().getThemesAndDoc();
    if (themes.isNotOK) {
      return;
    }
    if (themes.data.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (XTheme theme in themes.data) {
      for (XGroup group in theme.groups) {
        for (XDoc doc in group.docs) {
          // 文件名: XTheme.name/XGroup.name/XDoc.title
          // 文件内容: XTheme.name/XGroup.name/XDoc.plainText
          final String fileName = doc.title.isEmpty ? "无题" : doc.title;
          final String savePath =
              '$selectedDirectory/枫迹/$currentDate/${theme.name}/${group.name}';

          // 创建文件夹并写入文件
          final filePath = '$savePath/$fileName.txt';

          File file = File(filePath);
          try {
            await Directory(savePath).create(recursive: true);
            await file.writeAsString(doc.plainText);
          } catch (e) {
            if (mounted) {
              Msg.diy(context, "写入文件时出错");
            }
            print('写入文件时出错: $e');
            return;
          }
        }
      }
    }
  }

  Future<int> dialogExportOption() async {
    int? ret = await showDialog<int>(
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

    return ret ?? -1; // 如果用户没有点击按钮，则默认为 false
  }
}
