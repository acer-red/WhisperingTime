import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:whispering_time/page/home/setting.dart';
import 'package:whispering_time/page/feedback/feedback.dart';
import 'package:whispering_time/page/font_manager/font_manager.dart';
import 'package:whispering_time/page/home/config_management.dart';
import 'package:whispering_time/page/home/appbar.dart';
import 'package:whispering_time/page/home/task_manager.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/service/sp/sp.dart';
import 'package:whispering_time/util/ui.dart';
import 'package:whispering_time/util/export.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/service/http/base.dart';
import 'package:whispering_time/service/http/official.dart' as official;
import 'package:whispering_time/welcome.dart';
import 'package:whispering_time/util/secure.dart';

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
            _buildConfigManagementMenuItem(),
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
        children: [Icon(Icons.download), Text("内容导出")],
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

  Widget _buildConfigManagementMenuItem() {
    return PopupMenuItem(
      child: Row(
        spacing: 10,
        children: [Icon(Icons.settings_backup_restore), Text("配置管理")],
      ),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return const ConfigManagementDialog();
          },
        ).then((needRefresh) {
          if (needRefresh == true && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          }
        });
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
    return ListTile(
      leading: const Icon(Icons.feedback),
      title: const Text('反馈'),
      onTap: () async {
        Navigator.of(context).pop(); // close drawer
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
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text('退出'),
      onTap: () async {
        Navigator.of(context).pop(); // close drawer
        await _logout();
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
    await Config().close();
    await Storage().deleteCookie();
    SP().setIsAutoLogin(false);

    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Welcome(),
        ));
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

    official.RequestUpdateUserProfile req =
        official.RequestUpdateUserProfile(bytes: bytes, ext: ext);

    official.Http().userProfile(req).then((value) {
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
    official.RequestUpdateUserProfile req =
        official.RequestUpdateUserProfile(nickname: value);

    official.Http().userProfile(req).then((onValue) {
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
