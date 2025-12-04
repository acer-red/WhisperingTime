import 'package:flutter/material.dart';

class MyDialog {
  String? title;
  String content;
  MyDialog({this.title, required this.content});
}

// 定义一个函数，用于显示弹窗
Future<bool> showConfirmationDialog(
    BuildContext context, MyDialog dialog) async {
  bool? isConfirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: dialog.title != null ? Text(dialog.title!) : null,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(dialog.content), // 显示传入的内容
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop(false); // 返回 false 表示取消
            },
          ),
          TextButton(
            child: Text('确定'),
            onPressed: () {
              Navigator.of(context).pop(true); // 返回 true 表示确定
            },
          ),
        ],
      );
    },
  );

  return isConfirmed ?? false;
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

class Msg {
  static void diy(BuildContext context, String desc, {String? title}) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: Text(desc),
          actions: <Widget>[
            TextButton(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void showErrMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade300),
          SizedBox(width: 8),
          Text(msg),
        ],
      ),
      duration: Duration(seconds: 2),
    ),
  );
}

void showSuccessMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade300),
          SizedBox(width: 8),
          Text(msg),
        ],
      ),
      duration: Duration(seconds: 2),
    ),
  );
}

class ShortGreyLine extends StatelessWidget {
  const ShortGreyLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
