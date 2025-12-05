import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/export.dart';
import 'browser.dart';

class ThemeSettings extends StatefulWidget {
  final ThemeItem theme;
  final Function(String newName) onRenamed;
  final Function() onDeleted;

  const ThemeSettings({
    super.key,
    required this.theme,
    required this.onRenamed,
    required this.onDeleted,
  });

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  late final FocusNode _textFieldFocusNode;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode = FocusNode();
    _textController.text = widget.theme.name;

    // 监听焦点变化，失去焦点时自动保存
    _textFieldFocusNode.addListener(() {
      if (!_textFieldFocusNode.hasFocus) {
        if (_textController.text != widget.theme.name) {
          rename(_textController.text);
        }
      }
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// 重命名主题
  /// 在设置页面修改名称后，同步到服务器并更新本地状态
  void rename(String newName, {bool ishttp = true}) async {
    if (newName.trim().isEmpty) {
      return;
    }

    if (ishttp) {
      final res = await Http(tid: widget.theme.id)
          .putTheme(RequestPutTheme(name: newName));

      if (res.isNotOK) {
        return;
      }
    }

    if (mounted) {
      widget.onRenamed(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShortGreyLine(),
              const SizedBox(height: 16),

              // 重命名部分
              Row(
                children: [
                  const Text('重命名', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      textAlign: TextAlign.right,
                      focusNode: _textFieldFocusNode,
                      controller: _textController,
                      decoration: null,
                      onChanged: (value) {
                        rename(_textController.text, ishttp: false);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 导出部分
              Row(
                children: [
                  const Text("导出"),
                  const Spacer(),
                  SizedBox(
                    width: 50,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String value) {
                        // 处理菜单项点击事件
                        switch (value) {
                          case '保存到本地':
                            clickExport();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: '保存到本地',
                          child: Text('保存到本地'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => clickDeleteTheme(),
                    icon: Icon(Icons.delete, color: Colors.red.shade900),
                    label: Text(
                      "删除",
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 按钮：删除主题
  /// 位置：在设置中
  void clickDeleteTheme() async {
    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除？", title: "提示")))) {
      return;
    }

    final res = await Http(tid: widget.theme.id).deleteTheme();

    if (res.isNotOK) {
      return;
    }

    if (mounted) {
      widget.onDeleted();
      Navigator.of(context).pop();
    }
  }

  /// 按钮：导出当前主题
  /// 位置：在设置中
  void clickExport() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Export(
          ResourceType.theme,
          tid: widget.theme.id,
        );
      },
    );
  }
}
