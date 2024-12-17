// 设置页面
import 'package:flutter/material.dart';
import '../../env.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          // 显示标题
          SwitchListTile(
            title: const Text('隐藏空白标题'),
            value: Setting().isVisualNoneTitle,
            onChanged: (bool value) {
              setState(() {
                Setting().isVisualNoneTitle = value;
                print(Setting().isVisualNoneTitle);
              });
            },
          ),
          divider(), // 分割线
        ],
      ),
    );
  }


}
