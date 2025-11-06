import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/utils/export.dart';
import 'model.dart';

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
  @override
  void initState() {
    super.initState();
    _textFieldFocusNode = FocusNode();
    _textController.text = widget.group.name;

    // 监听焦点变化，失去焦点时自动保存
    _textFieldFocusNode.addListener(() {
      if (!_textFieldFocusNode.hasFocus) {
        if (_textController.text != widget.group.name) {
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

  /// 重命名分组
  /// 在设置页面修改名称后，同步到服务器并更新本地状态
  void rename(String newName, {bool ishttp = true}) async {
    if (newName.trim().isEmpty) {
      return;
    }

    final groupsModel = context.read<GroupsModel>();
    final tid = groupsModel.tid;
    final id = groupsModel.id;
    if (mounted) {
      groupsModel.setName(newName);
    }

    if (ishttp) {
      final res = await Http(tid: tid, gid: id)
          .putGroup(RequestPutGroup(name: newName));

      if (res.isNotOK) {
        return;
      }
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

                      // onChanged: (value) {
                      //   rename(_textController.text);
                      // },
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
              Row(
                children: [
                  Text("导出"),
                  Spacer(),
                  SizedBox(
                    width: 50,
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down),
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
                        // 添加其他菜单项
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
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
    final length = context.read<GroupsModel>().length;
    final id = context.read<GroupsModel>().id;
    final tid = context.read<GroupsModel>().tid;
    final idx = context.read<GroupsModel>().idx;

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
      // setState(() {
      // });

      context.read<GroupsModel>().removeAt(idx);

      Navigator.of(context).pop();
    }
  }

  /// 按钮：导出当前分组
  /// 位置：在设置中
  void clickExport() {
    final gid = context.read<GroupsModel>().id;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Export(ResourceType.group,
            title: "导出当前分组", tid: widget.tid, gid: gid);
      },
    );
  }
}

/// 定格开关组件
/// 根据分组的定格状态显示不同的开关和说明
class FreezeSwitchTile extends StatefulWidget {
  final Group item;
  final Function(int status, bool isFreezed) onFreezeChanged;

  const FreezeSwitchTile({
    super.key,
    required this.item,
    required this.onFreezeChanged,
  });

  @override
  State<FreezeSwitchTile> createState() => _FreezeSwitchTileState();
}

class _FreezeSwitchTileState extends State<FreezeSwitchTile> {
  late int status;
  late bool isFreezed;

  @override
  void initState() {
    super.initState();
    status = widget.item.getOverTimeStatus();
    isFreezed = !widget.item.isNotEnterOverTime();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: status,
      children: [
        // 未定格，未进入缓冲期
        _buildNotFreezedTile(),
        // 未定格，进入缓冲期
        _buildBufferPeriodTile(),
        // 已定格
        _buildFreezedTile(),
      ],
    );
  }

  Widget _buildNotFreezedTile() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('定格'),
      subtitle: const Text(
        "定格后无法编辑，仅供回顾。7天内可取消。",
        style: TextStyle(fontSize: 12),
      ),
      value: isFreezed,
      onChanged: (bool value) async {
        final groupsModel = Provider.of<GroupsModel>(context, listen: false);
        final tid = groupsModel.tid;
        final id = groupsModel.id;

        final time = Time.getOverDay();
        final res = await Http(tid: tid, gid: id)
            .putGroup(RequestPutGroup(overtime: time));

        if (res.isNotOK) {
          return;
        }

        if (mounted) {
          groupsModel.setOvertime(time);
          setState(() {
            isFreezed = true;
            status = 1;
          });
          widget.onFreezeChanged(status, isFreezed);
        }
      },
    );
  }

  Widget _buildBufferPeriodTile() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('定格'),
      subtitle: Text("进入缓冲期,定格时间:${widget.item.overtime.toString()}"),
      value: isFreezed,
      onChanged: (bool value) async {
        final groupsModel = Provider.of<GroupsModel>(context, listen: false);
        final tid = groupsModel.tid;
        final id = groupsModel.id;

        final time = Time.getForver();
        final res = await Http(tid: tid, gid: id)
            .putGroup(RequestPutGroup(overtime: time));

        if (res.isNotOK) {
          return;
        }

        if (mounted) {
          groupsModel.setOvertime(time);
          setState(() {
            isFreezed = false;
            status = 0;
          });
          widget.onFreezeChanged(status, isFreezed);
        }
      },
    );
  }

  Widget _buildFreezedTile() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('定格'),
      subtitle: Text("已定格于${widget.item.overtime.toString()}"),
      value: true,
      onChanged: null,
    );
  }
}
