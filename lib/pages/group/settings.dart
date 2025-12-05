import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/utils/time.dart';
import 'model.dart';
import 'manager.dart';

class GroupSettings extends StatefulWidget {
  final Group group;
  final String tid;
  GroupSettings({
    required this.group,
    required this.tid,
  });

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  late final FocusNode _textFieldFocusNode;
  final TextEditingController _textController = TextEditingController();
  String _lastSyncedName = '';

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode = FocusNode();
    _lastSyncedName = widget.group.name;
    _textController.text = widget.group.name;

    // 监听焦点变化，失去焦点时自动保存
    _textFieldFocusNode.addListener(() {
      if (!_textFieldFocusNode.hasFocus) {
        if (_textController.text != _lastSyncedName) {
          rename(_textController.text);
        }
      }
    });
  }

  @override
  void dispose() {
    // 在销毁前，如果名称有变化，确保同步到服务器
    if (_textController.text != _lastSyncedName) {
      rename(_textController.text);
    }
    _textFieldFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// 重命名分组
  /// 在设置页面修改名称后，同步到服务器并更新本地状态
  void rename(String newName, {bool ishttp = true}) async {
    if (newName.trim().isEmpty) {
      return;
    }

    final groups = context.read<GroupsManager>();
    final tid = groups.tid;
    final id = groups.id;
    if (mounted) {
      groups.setName(newName);
    }

    if (ishttp) {
      final res = await Http(tid: tid, gid: id)
          .putGroup(RequestPutGroup(name: newName));

      if (res.isNotOK) {
        return;
      }
      groups.touch();
      // 同步成功后，更新最后同步的名称
      _lastSyncedName = newName;
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
              Center(
                child: Container(
                  width: 80,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 重命名部分
              Row(
                children: [
                  Text('重命名', style: TextStyle(fontSize: 16)),
                  Spacer(),
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
              SizedBox(height: 16),

              // 定格部分
              FreezeSwitchTile(
                item: widget.group,
                onFreezeChanged: (newStatus, newIsFreezed) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),

              Spacer(),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => clickExportData(),
                    icon: Icon(Icons.download),
                    label: Text("导出"),
                  ),
                  Spacer(),
                  TextButton.icon(
                    onPressed: () => clickDeleteGroup(),
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

  /// 按钮：删除分组
  /// 位置：在设置中
  void clickDeleteGroup() async {
    final length = context.read<GroupsManager>().length;
    final id = context.read<GroupsManager>().id;
    final tid = context.read<GroupsManager>().tid;
    final idx = context.read<GroupsManager>().idx;

    if (length == 1) {
      Msg.diy(context, "无法删除，请保留至少一个项目。");
      return;
    }

    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除？", title: "提示")))) {
      return;
    }

    final ret = await Http(tid: tid, gid: id).deleteGroup();
    if (ret.isNotOK) {
      return;
    }

    if (mounted) {
      context.read<GroupsManager>().removeAt(idx);
      Navigator.of(context).pop();
    }
  }

  /// 按钮：导出当前分组的印迹
  void clickExportData() {
    final gid = context.read<GroupsManager>().id;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Export(ResourceType.group, tid: widget.tid, gid: gid);
      },
    );
  }

  /// 按钮：导出当前分组的配置
  void clickExportConfig() {
    Http(tid: widget.tid, gid: widget.group.id)
        .exportGroupConfig()
        .then((configData) {});
  }
}

/// 定格开关组件
/// 根据分组的定格状态显示不同的开关和说明
class FreezeSwitchTile extends StatefulWidget {
  final Group item;
  final void Function(int status, bool isFreezed) onFreezeChanged;
  const FreezeSwitchTile(
      {super.key, required this.item, required this.onFreezeChanged});

  @override
  State<FreezeSwitchTile> createState() => _FreezeSwitchTileState();
}

class _FreezeSwitchTileState extends State<FreezeSwitchTile> {
  late int status;
  late bool isManual;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  void didUpdateWidget(covariant FreezeSwitchTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item ||
        oldWidget.item.overAt != widget.item.overAt ||
        oldWidget.item.updateAt != widget.item.updateAt) {
      setState(_refreshStatus);
    }
  }

  void _refreshStatus() {
    status = widget.item.getoverAtStatus();
    isManual = widget.item.isManualBufTime() || widget.item.isManualFreezed();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: status,
      children: [
        _buildNotFreezedTile(),
        _buildBufferPeriodTile(),
        _buildFreezedTile(),
      ],
    );
  }

  Future<void> _handleToggle(bool value) async {
    final prevStatus = status;
    final prevManual = isManual;
    final groups = Provider.of<GroupsManager>(context, listen: false);
    final tid = groups.tid;
    final id = groups.id;
    final time = value ? Time.getOverDay() : Time.getForver();

    setState(() {
      _isProcessing = true;
      status = value ? 1 : (widget.item.isAutoBufTime() ? 1 : 0);
      isManual = value;
    });

    final res =
        await Http(tid: tid, gid: id).putGroup(RequestPutGroup(overAt: time));

    if (res.isNotOK || !mounted) {
      setState(() {
        status = prevStatus;
        isManual = prevManual;
        _isProcessing = false;
      });
      return;
    }

    groups.setoverAt(time);
    groups.touch(exitBuffer: false);
    setState(() {
      status = value ? 1 : (widget.item.isAutoBufTime() ? 1 : 0);
      isManual = value;
      _isProcessing = false;
    });
    widget.onFreezeChanged(status, status != 0);
  }

  Widget _buildNotFreezedTile() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('定格'),
      subtitle: const Text(
        "定格后无法编辑，仅供回顾。7天内可取消。",
        style: TextStyle(fontSize: 12),
      ),
      value: isManual,
      onChanged: _isProcessing ? null : (bool value) => _handleToggle(value),
    );
  }

  Widget _buildBufferPeriodTile() {
    final isAuto = widget.item.isAutoBufTime() && !isManual;
    final subtitle = isAuto
        ? "进入7天定格缓冲期,缓冲期内若无任何更新动作，则定格此分组"
        : "已进入缓冲期,定格时间:${widget.item.overAt?.toString() ?? ''}";
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('定格'),
      subtitle: Text(subtitle),
      value: isManual,
      onChanged: _isProcessing ? null : (bool value) => _handleToggle(value),
    );
  }

  Widget _buildFreezedTile() {
    final isAuto = !isManual;
    final frozenTime = isAuto
        ? widget.item.updateAt
            .add(Duration(days: widget.item.config.autoFreezeDays))
        : widget.item.overAt;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('定格'),
      subtitle: Text("已定格于${frozenTime.toString()}"),
      value: true,
      onChanged: null,
    );
  }
}
