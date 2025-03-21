import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:whispering_time/pages/theme/theme.dart';
import 'package:whispering_time/pages/setting/setting.dart';
import 'package:whispering_time/pages/feedback/feedback.dart';
import 'package:whispering_time/pages/welcome.dart';
import 'package:whispering_time/pages/font_manager/font_manager.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/services/http/base.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/http/index.dart';

const double iconsize = 25;

class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isEdit = false;
  late Future<UserBasicInfo> _userInfoFuture;
  TextEditingController nicknameController = TextEditingController();
  UserBasicInfo userinfo = UserBasicInfo(
      email: "",
      profile:
          Profile(nickname: "", avatar: Avatar(name: "", url: ""))); // 初始化 user

  Future<UserBasicInfo> init() async {
    final value = await Http().userInfo();
    if (value.isNotOK) {
      if (mounted) {
        showErrMsg(context, "服务器连接失败");
        return userinfo;
      }
      return userinfo;
    }

    setState(() {
      userinfo = UserBasicInfo(email: value.email, profile: value.profile);
      nicknameController.text = userinfo.profile.nickname;
    });
    return userinfo;
  }

  @override
  initState() {
    super.initState();
    _userInfoFuture = init();
  }

  editDone(String nickname) {
    updateNickname(nickname);
    setState(() {
      isEdit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 15, left: 20, right: 15, bottom: 20),
          child: Column(
            spacing: 5,
            children: <Widget>[
              PopupMenuItem(
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
              ),
              PopupMenuItem(
                child: Row(
                  spacing: 10,
                  children: [Icon(Icons.download), Text("导出")],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return Export(ResourceType.theme, title: "导出所有印迹数据");
                    },
                  );
                },
              ),
              PopupMenuItem(
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
              ),
              PopupMenuItem(
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
              ),
              Spacer(),
              PopupMenuItem(
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.exit_to_app),
                      Text('退出'),
                    ],
                  ),
                  onTap: () {
                    logout();
                  }),
            ],
          ),
        ),
      ),
      appBar: AppBar(actions: [
        isEdit
            ? IconButton(
                onPressed: () => editDone(nicknameController.text),
                icon: Icon(Icons.done))
            : IconButton(
                onPressed: () {
                  setState(() {
                    isEdit = true;
                  });
                },
                icon: Icon(Icons.edit)),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => {
            scaffoldKey.currentState!.openEndDrawer(),
          },
        ),
      ]),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 0, top: 0, left: 50, right: 50),
          child: Column(
            spacing: 40,
            children: [
              user(),
              ThemePage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget user() {
    return FutureBuilder<UserBasicInfo>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error loading user info");
        }

        return Column(
          spacing: 20,
          children: [
            avatarIcon(),
            nicknameText(snapshot.data?.profile.nickname ?? ""),
          ],
        );
      },
    );
  }

  Widget nicknameText(String nickname) {
    return isEdit
        ? TextField(
            controller: nicknameController,
            decoration: InputDecoration(),
            onSubmitted: (value) => editDone(value),
          )
        : Text(
            nickname,
            style: TextStyle(letterSpacing: 2.0),
          );
  }

  Widget avatarIcon() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!isEdit) {
            watchAvatar();
          } else {
            updateAvatar();
          }
        },
        child: FutureBuilder<UserBasicInfo>(
          future: _userInfoFuture,
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
              backgroundImage: (avatarUrl != null && !isEdit)
                  ? NetworkImage(
                      "${HTTPConfig.indexServerAddress}$avatarUrl",
                    )
                  : null,
              child: isEdit
                  ? const Icon(
                      Icons.upload,
                    )
                  : avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
            );
          },
        ),
      ),
    );
  }

  logout() {
    showConfirmationDialog(context, MyDialog(content: "确定退出吗？")).then((value) {
      if (!value) {
        return;
      }
      Config().close();
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

  watchAvatar() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.black54,
              child: Center(
                child: FutureBuilder<UserBasicInfo>(
                  future: _userInfoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Icon(
                        Icons.error,
                        size: 100,
                        color: Colors.white,
                      );
                    }

                    final avatarUrl = snapshot.data?.profile.avatar.url;
                    return avatarUrl != null
                        ? Image.network(
                            "${HTTPConfig.indexServerAddress}$avatarUrl",
                            fit: BoxFit.contain,
                          )
                        : const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.white,
                          );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  updateAvatar() async {
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

    RequestPutUserProfile req = RequestPutUserProfile(bytes: bytes, ext: ext);

    Http().userProfile(req).then((value) {
      if (value.isNotOK) {
        if (mounted) {
          showErrMsg(context, "上传失败");
        }
        return;
      }
      if (mounted) {
        showSuccessMsg(context, "上传成功");
      }
      setState(() {
        userinfo.profile.avatar.url = value.url!;
      });
    });
  }

  updateNickname(String value) {
    if (value == userinfo.profile.nickname) {
      return;
    }
    RequestPutUserProfile req = RequestPutUserProfile(nickname: value);

    Http().userProfile(req).then((onValue) {
      if (onValue.isNotOK) {
        if (mounted) {
          showErrMsg(context, "上传失败");
        }
        return;
      }
      if (mounted) {
        showSuccessMsg(context, "上传成功");
      }
      setState(() {
        userinfo.profile.nickname = value;
      });
    });
  }
}
