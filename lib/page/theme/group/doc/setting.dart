import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';

class DocSetting extends StatefulWidget {
  final String gid;
  final String did;
  final DateTime crtime;
  DocSetting({required this.gid, required this.did, required this.crtime});
  @override
  State<DocSetting> createState() => _DocSetting();
}

class LastPageDocSetting {
  LastPage state;

  DateTime? crtime;
  LastPageDocSetting({required this.state, this.crtime});
}

class _DocSetting extends State<DocSetting> {
  DateTime crtime = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => backPage(),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '创建时间: ${Time.string(crtime)}',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await datePacker(context);

                    TimeOfDay? pickedtime = await datePicker(context);

                    pickedDate ??= crtime;
                    if (pickedtime == null) {
                      crtime = pickedDate;
                    } else {
                      crtime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedtime.hour,
                        pickedtime.minute,
                        0, // 秒
                      );
                    }

                    if (mounted) {
                      setState(() {});
                    }

                    print(crtime.toString());
                  },
                  child: Text('修改时间'),
                ),
              ],
            ),
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

  Future<TimeOfDay?> datePicker(BuildContext context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(crtime), // 如果没有选择过时间，则使用当前时间
    );
  }

  Future<DateTime?> datePacker(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: crtime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
  }

  backPage() {
    if (widget.crtime != crtime) {
      return Navigator.of(context)
          .pop(LastPageDocSetting(state: LastPage.change, crtime: crtime));
    } else {
      return Navigator.of(context).pop(LastPageDocSetting(state: LastPage.ok));
    }
  }

  deleteDoc() async {
    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除", title: "提示")))) {
      return;
    }

    final ret = await Http(gid: widget.gid, did: widget.did)
        .deleteDoc();
    if (ret.isNotOK()) {
      return;
    }
    if (mounted) {
      Navigator.of(context).pop(LastPageDocSetting(state: LastPage.delete));
    }
  }
}
