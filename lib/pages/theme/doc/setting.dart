import 'package:flutter/material.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/utils/env.dart';

class DocConfigration {
  bool? isShowTool;
  DocConfigration({this.isShowTool});
  Map<String, dynamic> toJson() {
    return {
      'is_show_tool': isShowTool,
    };
  }
}

class LastStateDocSetting {
  LastState state;
  DateTime? crtime;
  DocConfigration? config;
  LastStateDocSetting({required this.state, this.config, this.crtime});
}

// 文档设置弹窗
class DocSettingsDialog extends StatefulWidget {
  final String gid;
  final String? did;
  final DocConfigration config;
  final DateTime crtime;

  DocSettingsDialog({
    required this.gid,
    required this.did,
    required this.crtime,
    required this.config,
  });

  @override
  State<DocSettingsDialog> createState() => _DocSettingsDialogState();
}

class _DocSettingsDialogState extends State<DocSettingsDialog> {
  late bool isShowTool;
  late DateTime crtime;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    isShowTool = widget.config.isShowTool ?? false;
    crtime = widget.crtime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('文档设置'),
      contentPadding: EdgeInsets.symmetric(vertical: 20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 创建时间设置
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('创建时间'),
              trailing: TextButton(
                onPressed: () => _setCRTime(),
                child: Text(
                  Time.string(crtime),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            Divider(height: 1),
            // 显示工具栏开关
            SwitchListTile(
              secondary: Icon(Icons.build),
              title: Text('显示工具栏'),
              subtitle: Text('含图片上传'),
              value: isShowTool,
              onChanged: (value) => _setTool(value),
            ),
            Divider(height: 1),
            // 删除文档按钮
            if (widget.did != null)
              ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    '删除文档',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final ok = await _deleteDoc();
                    if (!ok) return;
                    if (!mounted) return;
                       Navigator.of(context).pop({
                          'changed': true,
                          'deleted': true,
                        });
                  }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'changed': isChanged,
              'crtime': crtime,
              'config': DocConfigration(isShowTool: isShowTool),
            });
          },
          child: Text('确定'),
        ),
      ],
    );
  }

  // 设置工具栏显示
  void _setTool(bool value) async {
    isChanged = true;
    if (widget.did != null) {
      final res = await Http(gid: widget.gid, did: widget.did)
          .putDoc(RequestPutDoc(config: DocConfigration(isShowTool: value)));
      if (res.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('设置失败')),
          );
        }
        return;
      }
    }

    setState(() {
      isShowTool = value;
    });
  }

  // 设置创建时间
  void _setCRTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: crtime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );

    pickedDate ??= crtime;

    if (!mounted) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(crtime),
    );

    DateTime newCrtime;
    if (pickedTime == null) {
      newCrtime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        crtime.hour,
        crtime.minute,
        0,
      );
    } else {
      newCrtime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        0,
      );
    }

    if (crtime == newCrtime) {
      return;
    }

    isChanged = true;

    setState(() {
      crtime = newCrtime;
    });

    // 如果文档已保存，立即更新到服务器
    if (widget.did != null) {
      final res = await Http(gid: widget.gid, did: widget.did)
          .putDoc(RequestPutDoc(crtime: newCrtime));
      if (res.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('时间设置失败')),
          );
        }
        return;
      }
    }
  }

  // 删除文档
  Future<bool> _deleteDoc() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除这篇文档吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return false;
    }

    final res = await Http(gid: widget.gid, did: widget.did).deleteDoc();
    if (!mounted) return false;

    if (res.isNotOK) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败')),
        );
      return false;
    }
    return true;
  }
}
                         