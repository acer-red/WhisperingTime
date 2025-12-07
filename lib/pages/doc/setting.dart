import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/pages/group/manager.dart';
import 'package:whispering_time/services/grpc/grpc.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/pages/doc/model.dart';

class LastStateDocSetting {
  LastState state;
  DateTime? createAt;
  DocConfig? config;
  LastStateDocSetting({required this.state, this.config, this.createAt});
}

class DocSettingsDialog extends StatefulWidget {
  final String gid;
  final String? did;
  final DocConfig config;
  final DateTime createAt;

  DocSettingsDialog({
    required this.gid,
    required this.did,
    required this.createAt,
    required this.config,
  });

  @override
  State<DocSettingsDialog> createState() => _DocSettingsDialogState();
}

class _DocSettingsDialogState extends State<DocSettingsDialog> {
  late bool isShowTool;
  late DateTime createAt;
  bool isChanged = false;

  void _touchGroup() {
    if (!mounted) return;
    context.read<GroupsManager>().touch(gid: widget.gid);
  }

  @override
  void initState() {
    super.initState();
    isShowTool = widget.config.isShowTool ?? false;
    createAt = widget.createAt;
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
                onPressed: () => _setCreateTime(),
                child: Text(
                  Time.string(createAt),
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
                    Navigator.of(this.context).pop({
                      'changed': false,
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
              'createAt': createAt,
              'config': DocConfig(isShowTool: isShowTool),
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
      final res = await Grpc(gid: widget.gid, did: widget.did)
          .putDoc(RequestUpdateDoc(config: DocConfig(isShowTool: value)));
      if (res.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('设置失败')),
          );
        }
        return;
      }

      _touchGroup();
    }

    setState(() {
      isShowTool = value;
    });
  }

  // 设置创建时间
  void _setCreateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: createAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );

    pickedDate ??= createAt;

    if (!mounted) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(createAt),
    );

    DateTime newCreateAt;
    if (pickedTime == null) {
      newCreateAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        createAt.hour,
        createAt.minute,
        0,
      );
    } else {
      newCreateAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        0,
      );
    }

    if (createAt == newCreateAt) {
      return;
    }

    isChanged = true;

    setState(() {
      createAt = newCreateAt;
    });

    // 如果文档已保存，立即更新到服务器
    if (widget.did != null) {
      final res = await Grpc(gid: widget.gid, did: widget.did)
          .putDoc(RequestUpdateDoc(createAt: newCreateAt));
      if (res.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('时间设置失败')),
          );
        }
        return;
      }

      _touchGroup();
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

    final res = await Grpc(gid: widget.gid, did: widget.did).deleteDoc();
    if (!mounted) return false;

    if (res.isNotOK) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败')),
      );
      return false;
    }

    _touchGroup();
    return true;
  }
}
