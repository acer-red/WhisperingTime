import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/page/group/manager.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/page/doc/model.dart';

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
  final bool fromBrowser;

  DocSettingsDialog({
    required this.gid,
    required this.did,
    required this.config,
    this.fromBrowser = false,
  });

  @override
  State<DocSettingsDialog> createState() => _DocSettingsDialogState();
}

class _DocSettingsDialogState extends State<DocSettingsDialog> {
  late int displayPriority;
  bool isChanged = false;

  void _touchGroup() {
    if (!mounted) return;
    context.read<GroupsManager>().touch(gid: widget.gid);
  }

  @override
  void initState() {
    super.initState();
    displayPriority = widget.config.displayPriority ?? 0;
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
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text('显示优先'),
              subtitle: Text(_getDisplayPriorityDesc(displayPriority)),
              trailing: DropdownButton<int>(
                value: displayPriority,
                onChanged: (value) => _setDisplayPriority(value),
                items: [
                  DropdownMenuItem(value: 0, child: Text('完整')),
                  DropdownMenuItem(value: 1, child: Text('文字优先')),
                  DropdownMenuItem(value: 2, child: Text('媒体优先')),
                ],
              ),
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
              'config': DocConfig(displayPriority: displayPriority),
            });
          },
          child: Text('确定'),
        ),
      ],
    );
  }

  // 设置显示优先
  void _setDisplayPriority(int? value) async {
    if (value == null) return;
    isChanged = true;
    if (widget.did != null) {
      final res = await Grpc(gid: widget.gid, did: widget.did)
          .putDoc(RequestUpdateDoc(config: DocConfig(displayPriority: value)));
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
      displayPriority = value;
    });
  }

  String _getDisplayPriorityDesc(int priority) {
    switch (priority) {
      case 0:
        return '详细显示印迹，图文混排';
      case 1:
        return '文字为主，图片以缩略图形式';
      case 2:
        return '媒体为主，文字最小化显示';
      default:
        return '';
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
