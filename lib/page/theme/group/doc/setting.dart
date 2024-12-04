import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';

class Setting extends StatefulWidget {
  String gid;
  String did;
  Setting({required this.gid, required this.did});
  @override
  State<Setting> createState() => _Setting();
}

class _Setting extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => deleteDoc(),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.red.shade900), // 设置红色背景
                minimumSize:
                    WidgetStateProperty.all(Size(200, 60)), // 设置按钮大小为 200x60
              ),
              child: Text(
                '删除',
                style:
                    TextStyle(color: Color(Colors.white.value), fontSize: 17),
              ),
            )
          ],
        ),
      ),
    );
  }

  deleteDoc() async {
    final ret = await Http().deleteDoc(RequestDeleteDoc(gid:widget.gid, did: widget.did));
    if (ret.err != 0) {
      return;
    }
    if (mounted) {
      Navigator.of(context).pop(LastPage.delete);
    }
  }
}
