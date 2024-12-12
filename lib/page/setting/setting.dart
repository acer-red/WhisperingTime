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

  Divider divider() {
    return Divider(
      height: 20, // 分割线高度 (包含上下间距)
      thickness: 1, // 分割线粗细
      indent: 20, // 左侧缩进
      endIndent: 20, // 右侧缩进
      color: Colors.grey[200], // 分割线颜色
    );
  }
}
