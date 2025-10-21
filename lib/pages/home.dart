import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:whispering_time/pages/theme/theme.dart';
import 'package:whispering_time/pages/theme/group/group.dart';
import 'package:whispering_time/pages/setting/setting.dart';
import 'package:whispering_time/pages/feedback/feedback.dart';
import 'package:whispering_time/pages/welcome.dart';
import 'package:whispering_time/pages/font_manager/font_manager.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/services/isar/font.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/services/http/base.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/http/index.dart' as http_index;
import 'package:whispering_time/services/http/http.dart' as http;
import 'package:provider/provider.dart';

const double iconsize = 25;

class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey iconAddKey = GlobalKey();
  bool isEdit = false;
  late Future<UserBasicInfo> _userInfoFuture;
  late Future<void> _initFontFuture;
  late Future<List<ThemeItem>> _initThemeFuture;
  bool _fontInitScheduled = false;
  TextEditingController nicknameController = TextEditingController();
  UserBasicInfo userinfo = UserBasicInfo(
      email: "",
      profile:
          Profile(nickname: "", avatar: Avatar(name: "", url: ""))); // 初始化 user
  List<ThemeItem> themes = [];

  Future<UserBasicInfo> init() async {
    final value = await http_index.Http().userInfo();
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
    _initThemeFuture = initTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fontInitScheduled) {
      _initFontFuture = initAppFont();
      _fontInitScheduled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFontFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          log.e(snapshot.error);
          return const Scaffold(
            body: Center(
              child: Text("字体加载失败"),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return body();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget body() {
    return ChangeNotifierProvider(
      create: (context) => GroupsModel(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            centerTitle: true,
            title: appBarTitle(),
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: appBarActions())
            ],
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: appBarAvator(),
            )),
        drawer: Drawer(
          width: 220,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 15, left: 20, right: 15, bottom: 20),
            child: Column(
              spacing: 5,
              children: <Widget>[
                settingAvator(),
                SizedBox(height: 5),
                Divider(
                  height: 1,
                  endIndent: 150,
                  indent: 20,
                ),
                SizedBox(height: 2),
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
        body: SafeArea(
          child: Column(
            spacing: 40,
            children: [
              Expanded(
                child: FutureBuilder<List<ThemeItem>>(
                    future: _initThemeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        log.e(snapshot.error);
                        return const Center(
                          child: Text("主题加载失败"),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        // 在这里设置 themeID，此时 Provider 已经可用
                        final themes = snapshot.data ?? [];
                        if (themes.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              Provider.of<GroupsModel>(context, listen: false)
                                  .setThemeID(themes.first.id);
                            }
                          });
                        }
                        return ThemePage(themes);
                      }
                      return const SizedBox.shrink();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBarActions() {
    return IconButton(
        key: iconAddKey,
        icon: Icon(Icons.add),
        onPressed: () {
          dialogAdd(iconAddKey.currentContext!.findRenderObject() as RenderBox);
        });
  }

  Widget appBarTitle() {
    return Text(getAppName(human: true),
        style: TextStyle(fontFamily: getAppFontFamily(), fontSize: 30));
  }

  Widget appBarAvator() {
    return FutureBuilder<UserBasicInfo>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error loading user info");
        }
        // nicknameText(snapshot.data?.profile.nickname ?? ""),

        return SizedBox(
          width: 30,
          height: 30,
          child: avatarIcon(() {
            scaffoldKey.currentState!.openDrawer();
          }),
        );
      },
    );
  }

  Widget settingAvator() {
    return FutureBuilder<UserBasicInfo>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error loading user info");
        }

        return Row(
          children: [
            SizedBox(
              width: 10,
              height: 60,
            ),
            SizedBox(
              height: 35,
              width: 35,
              child: avatarIcon(() {
                updateAvatar();
              }),
            ),
            SizedBox(width: 20),
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

  Widget avatarIcon(Function onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(),
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
              backgroundImage:
                  (avatarUrl != null && avatarUrl.isNotEmpty && !isEdit)
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

  Future<List<ThemeItem>> initTheme() async {
    final list = await http.Http().getthemes();
    if (list.isNotOK) {
      if (mounted) {
        showErrMsg(context, "服务器连接失败");
      }
      return [];
    }
    if (list.data.isEmpty) {
      // add();
      return [];
    }

    for (int i = 0; i < list.data.length; i++) {
      if (list.data[i].id == "") {
        continue;
      }
      // 如果存在，下一个
      if (themes.any((element) => element.id == list.data[i].id)) {
        continue;
      }

      themes.add(ThemeItem(
        id: list.data[i].id,
        name: list.data[i].name,
      ));
    }
    // 移除这里的 Provider 访问，改为在 FutureBuilder 完成后设置
    return themes;

    // setState(() {
    //   _titems = themes;
    //   _tabController.dispose();
    //   _tabController = TabController(length: _titems.length, vsync: this);
    // });
  }

  void editDone(String nickname) {
    updateNickname(nickname);
    setState(() {
      isEdit = false;
    });
  }

  Future<void> logout() async {
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

  void watchAvatar() {
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

  void updateAvatar() async {
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
      setState(() {
        userinfo.profile.avatar.url = value.url!;
      });
    });
  }

  void updateNickname(String value) {
    if (value == userinfo.profile.nickname) {
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
      setState(() {
        userinfo.profile.nickname = value;
      });
    });
  }

  Future<void> initAppFont() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final serverAddress = Config.fontHubServerAddress;
    final downloadURL =
        "$serverAddress/api/app?name=${getAppName()}&language=$languageCode";
    final font = Font(
        name: "appfont-$languageCode",
        downloadURL: downloadURL,
        fileName: "AppFont-$languageCode",
        fullName: "AppFont-$languageCode");

    final isExist = await font.isExist();
    if (isExist) {
      log.i("应用字体已存在: ${font.name}");
      await font.load();
      return;
    }
    final ok = await font.download();
    if (!ok) {
      throw Exception("应用字体下载失败");
    }
    try {
      await font.upload();
      await font.load();
    } catch (e) {
      log.e("保存应用字体失败,${e.toString()}");
      return;
    }
  }

  String getAppFontFamily() {
    final languageCode = Localizations.localeOf(context).languageCode;
    return "AppFont-$languageCode";
  }

  String getAppName({bool human = false}) {
    final languageCode = Localizations.localeOf(context).languageCode;
    switch (languageCode) {
      case "zh":
        return human ? appNameZhHuman : appNameZh;
      case "en":
        return human ? appNameEnHuman : appNameEn;
      default:
        return appNameEn;
    }
  }

  void dialogAdd(RenderBox button) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect positionRect = RelativeRect.fromLTRB(
      position.dx,
      position.dy + button.size.height,
      position.dx + button.size.width,
      position.dy + button.size.height,
    );

    showMenu(
      context: context,
      position: positionRect,
      items: [
        PopupMenuItem(
          value: 1,
          child: Text('添加主题'),
          onTap: () => dialogAddTheme(),
        ),
        PopupMenuItem(
          value: 3,
          onTap: dialogAddGroup,
          child: Text(
            '添加分组',
          ),
        ),
      ],
    );
  }

  void dialogAddTheme() async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            onChanged: (value) {
              result = value;
            },
            decoration: const InputDecoration(hintText: "创建您的主题"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop(result);
              },
            ),
          ],
        );
      },
    );
    if (result == null) {
      return;
    }
    if (result!.isEmpty) {
      return;
    }

    final res =
        await http.Http().postTheme(http.RequestPostTheme(name: result!));

    if (res.isNotOK) {
      return;
    }

    // 刷新主题列表
    setState(() {
      _initThemeFuture = initTheme();
    });
  }

  /// 窗口: 添加分组
  void dialogAddGroup() {
    // 保存包含 Provider 的 context
    final scaffoldContext = scaffoldKey.currentContext;
    if (scaffoldContext == null) {
      return;
    }

    String? inputValue;
    showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("创建分组"),
          content: TextField(
            onChanged: (value) {
              inputValue = value;
            },
            decoration: const InputDecoration(hintText: "请输入"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                if (inputValue == null || inputValue!.isEmpty) {
                  return;
                }

                // 使用 scaffoldContext 来访问 Provider
                if (mounted) {
                  final ok = await Provider.of<GroupsModel>(scaffoldContext,
                          listen: false)
                      .add(inputValue!);
                  if (!ok) {
                    if (mounted) {
                      showErrMsg(context, "创建失败");
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
