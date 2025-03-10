import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/self.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/utils/ui.dart';

class DocConfigration {
  bool? isShowTool;
  DocConfigration({this.isShowTool});
  Map<String, dynamic> toJson() {
    return {
      'is_show_tool': isShowTool,
    };
  }
}

class DocSetting extends StatefulWidget {
  final String gid;
  final String? did;
  final DocConfigration config;
  final DateTime crtime;
  DocSetting(
      {required this.gid,
      required this.did,
      required this.crtime,
      required this.config});
  @override
  State<DocSetting> createState() => _DocSetting();
}

class LastPageDocSetting {
  LastPage state;
  DocConfigration? config;
  DateTime? crtime;
  LastPageDocSetting({required this.state, this.config, this.crtime});
}

class _DocSetting extends State<DocSetting> {
  bool isShowTool = false;
  bool isChange = false;

  DateTime crtime = DateTime.now();
  @override
  void initState() {
    super.initState();
    isShowTool = widget.config.isShowTool!;
    crtime = widget.crtime;
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
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '创建时间',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => setCRTime(),
                    child: Text(Time.string(crtime)),
                  ),
                ],
              ),
            ),
            SwitchListTile(
                title: const Text('显示工具栏'),
                subtitle: const Text('含图片上传'),
                value: isShowTool,
                onChanged: (bool value) => setTool(value)),
            ElevatedButton(
              onPressed: () => deleteDoc(),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.red.shade900),
                minimumSize: WidgetStateProperty.all(Size(200, 60)),
              ),
              child: Text(
                '删除',
                style:
                    TextStyle(color: Color(Colors.white.hashCode), fontSize: 17),
              ),
            )
          ],
        ),
      ),
    );
  }

  setTool(bool value) async {
    isChange = true;
    if (widget.did != null) {
      final res = await Http(gid: widget.gid, did: widget.did)
          .putDoc(RequestPutDoc(config: DocConfigration(isShowTool: value)));
      if (res.isNotOK) {
        return;
      }
    }

    setState(() {
      isShowTool = value;
    });
  }

  Future<TimeOfDay?> timePicker(BuildContext context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.crtime), // 如果没有选择过时间，则使用当前时间
    );
  }

  Future<DateTime?> datePicker(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: widget.crtime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
  }

  backPage() {
    if (!isChange) {
      return Navigator.of(context).pop(LastPageDocSetting(state: LastPage.ok));
    }
    return Navigator.of(context).pop(LastPageDocSetting(
        state: LastPage.change,
        crtime: crtime,
        config: DocConfigration(isShowTool: isShowTool)));
  }

  deleteDoc() async {
    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除", title: "提示")))) {
      return;
    }

    final ret = await Http(gid: widget.gid, did: widget.did).deleteDoc();
    if (ret.isNotOK) {
      return;
    }
    if (mounted) {
      Navigator.of(context).pop(LastPageDocSetting(state: LastPage.delete));
    }
  }

  setCRTime() async {
    DateTime? pickedDate = await datePicker(context);
    pickedDate ??= crtime;

    if (mounted) {
      TimeOfDay? pickedTime = await timePicker(context);

      if (pickedTime == null) {
        pickedDate = DateTime(crtime.year, crtime.month, crtime.day,
            crtime.hour, crtime.minute, 0);
      } else {
        pickedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
          0, // 秒
        );
      }

      if (crtime == pickedDate) {
        return;
      }
      isChange = true;

      setState(() {
        crtime = pickedDate!;
      });

      // 如果这个设置页面并没有id（发生在未上传到服务器时打开设置页面）
      // 则退出
      if (widget.did == null) {
        return;
      }
      final res = await Http(gid: widget.gid, did: widget.did)
          .putDoc(RequestPutDoc(crtime: pickedDate));
      if (res.isNotOK) {
        return;
      }
    }
  }
}
