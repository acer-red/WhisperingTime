import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';
import 'package:whispering_time/pages/home/setting.dart';
import 'package:whispering_time/pages/feedback/feedback.dart';
import 'package:whispering_time/pages/font_manager/font_manager.dart';
import 'package:whispering_time/pages/home/task_manager.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/http/base.dart';
import 'package:whispering_time/services/http/index.dart' as http_index;
import 'package:whispering_time/services/http/http.dart' as http_api;
import 'package:whispering_time/welcome.dart';

const double iconsize = 25;

class HomeDrawer extends StatefulWidget {
  final Future<UserBasicInfo> userInfoFuture;
  final UserBasicInfo userinfo;
  final VoidCallback onUserInfoUpdate;

  const HomeDrawer({
    super.key,
    required this.userInfoFuture,
    required this.userinfo,
    required this.onUserInfoUpdate,
  });

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool isEdit = false;
  late TextEditingController nicknameController;

  @override
  void initState() {
    super.initState();
    nicknameController =
        TextEditingController(text: widget.userinfo.profile.nickname);
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 15, left: 20, right: 15, bottom: 20),
        child: Column(
          spacing: 5,
          children: <Widget>[
            _buildAvatarSection(),
            SizedBox(height: 5),
            Divider(
              height: 1,
              endIndent: 150,
              indent: 20,
            ),
            SizedBox(height: 2),
            _buildSettingsMenuItem(),
            _buildTaskManagerMenuItem(),
            _buildExportMenuItem(),
            _buildConfigBackupMenuItem(),
            _buildFontMenuItem(),
            _buildFeedbackMenuItem(),
            Spacer(),
            _buildLogoutMenuItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return FutureBuilder<UserBasicInfo>(
      future: widget.userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error loading user info");
        }

        return Row(
          children: [
            SizedBox(width: 10, height: 60),
            SizedBox(
              height: 35,
              width: 35,
              child: _buildAvatarIcon(() {
                _updateAvatar();
              }),
            ),
            SizedBox(width: 20),
            _buildNicknameText(snapshot.data?.profile.nickname ?? ""),
          ],
        );
      },
    );
  }

  Widget _buildNicknameText(String nickname) {
    return isEdit
        ? TextField(
            controller: nicknameController,
            decoration: InputDecoration(),
            onSubmitted: (value) => _editDone(value),
          )
        : Text(
            nickname,
            style: TextStyle(letterSpacing: 2.0),
          );
  }

  Widget _buildAvatarIcon(Function onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(),
        child: FutureBuilder<UserBasicInfo>(
          future: widget.userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const CircleAvatar(
                radius: iconsize,
                child: Icon(Icons.person),
              );
            }

            final avatarUrl = snapshot.data?.profile.avatar.url;
            return CircleAvatar(
              radius: iconsize,
              backgroundImage:
                  (avatarUrl != null && avatarUrl.isNotEmpty && !isEdit)
                      ? NetworkImage(
                          "${HTTPConfig.indexServerAddress}$avatarUrl",
                        )
                      : null,
              child: isEdit
                  ? const Icon(Icons.upload)
                  : avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.settings),
          Text("设置"),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingPage(),
          ),
        );
      },
    );
  }

  Widget _buildTaskManagerMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.task_alt),
          Text("任务管理"),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskManagerPage(),
          ),
        );
      },
    );
  }

  Widget _buildExportMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [Icon(Icons.download), Text("导出")],
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Export(ResourceType.theme);
          },
        );
      },
    );
  }

  Widget _buildConfigBackupMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [Icon(Icons.settings_backup_restore), Text("配置备份")],
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return const ConfigBackupDialog();
          },
        );
      },
    );
  }

  Widget _buildFontMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [Icon(Icons.font_download), Text("字体")],
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return FontManager();
          },
        );
      },
    );
  }

  Widget _buildFeedbackMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.chat),
          Text("反馈"),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackPage(),
          ),
        );
      },
    );
  }

  Widget _buildLogoutMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [
          Icon(Icons.exit_to_app),
          Text('退出'),
        ],
      ),
      onTap: () {
        _logout();
      },
    );
  }

  void _editDone(String nickname) {
    _updateNickname(nickname);
    setState(() {
      isEdit = false;
    });
  }

  Future<void> _logout() async {
    showConfirmationDialog(context, MyDialog(content: "确定退出吗？"))
        .then((value) async {
      if (!value) {
        return;
      }
      await Config().close();
      SP().setIsAutoLogin(false);
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Welcome(),
            ));
      }
    });
  }

  void _updateAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    final String ext = path.extension(image.path).toLowerCase();
    final bytes = await image.readAsBytes();
    switch (ext) {
      case '.png':
      case '.jpg':
      case '.jpeg':
        break;
      default:
        showErrMsg(context, "不支持的图片格式: $ext");
        return;
    }

    http_index.RequestPutUserProfile req =
        http_index.RequestPutUserProfile(bytes: bytes, ext: ext);

    http_index.Http().userProfile(req).then((value) {
      if (value.isNotOK) {
        if (mounted) {
          showErrMsg(context, "上传失败");
        }
        return;
      }
      if (mounted) {
        showSuccessMsg(context, "上传成功");
      }
      widget.onUserInfoUpdate();
    });
  }

  void _updateNickname(String value) {
    if (value == widget.userinfo.profile.nickname) {
      return;
    }
    http_index.RequestPutUserProfile req =
        http_index.RequestPutUserProfile(nickname: value);

    http_index.Http().userProfile(req).then((onValue) {
      if (onValue.isNotOK) {
        if (mounted) {
          showErrMsg(context, "上传失败");
        }
        return;
      }
      if (mounted) {
        showSuccessMsg(context, "上传成功");
      }
      widget.onUserInfoUpdate();
    });
  }
}

class ConfigBackupDialog extends StatefulWidget {
  const ConfigBackupDialog({super.key});

  @override
  State<ConfigBackupDialog> createState() => _ConfigBackupDialogState();
}

class _ConfigBackupDialogState extends State<ConfigBackupDialog> {
  List<http_api.XTheme> _themes = [];
  String? _selectedTid;
  String? _selectedGid;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await http_api.Http().getThemesAndDoc();
    if (!mounted) {
      return;
    }
    if (res.isNotOK || res.data.isEmpty) {
      setState(() {
        _loading = false;
        _error = '暂无可备份的分组';
      });
      return;
    }

    setState(() {
      _themes = res.data;
      _selectedTid = _themes.first.tid;
      _selectedGid = _themes.first.groups.isNotEmpty
          ? _themes.first.groups.first.gid
          : null;
      _loading = false;
    });
  }

  List<http_api.XGroup> _groupsForTheme(String? tid) {
    return _themes.firstWhereOrNull((theme) => theme.tid == tid)?.groups ??
        const <http_api.XGroup>[];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('配置备份'),
      content: SizedBox(
        width: 360,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('选择主题'),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedTid,
                        items: _themes
                            .map((theme) => DropdownMenuItem<String>(
                                  value: theme.tid,
                                  child: Text(theme.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedTid = value;
                            final groups = _groupsForTheme(value);
                            _selectedGid =
                                groups.isNotEmpty ? groups.first.gid : null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text('选择分组'),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedGid,
                        items: _groupsForTheme(_selectedTid)
                            .map((group) => DropdownMenuItem<String>(
                                  value: group.gid,
                                  child: Text(group.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedGid = value;
                          });
                        },
                      ),
                    ],
                  ),
      ),
      actions: _loading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: _selectedTid == null || _selectedGid == null
                    ? null
                    : _export,
                child: const Text('备份'),
              ),
            ],
    );
  }

  Future<void> _export() async {
    if (_selectedTid == null || _selectedGid == null) {
      _showSnack('请选择分组');
      return;
    }

    final res = await http_api.Http(tid: _selectedTid, gid: _selectedGid)
        .exportGroupConfig();
    if (!mounted) {
      return;
    }
    if (res.isNotOK) {
      showErrMsg(context, res.msg);
      return;
    }

    showSuccessMsg(context, '配置备份已生成');
    Navigator.of(context).pop();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
