import 'package:flutter/material.dart';
import 'package:whispering_time/page/theme/browser.dart';
import 'package:whispering_time/page/home/drawer.dart';
import 'package:whispering_time/service/isar/font.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/util/ui.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/service/http/base.dart';
import 'package:whispering_time/service/http/official.dart' as official;
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/page/group/manager.dart';

const double iconsize = 25;

class HomePage extends StatefulWidget {
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey iconAddKey = GlobalKey();
  late Future<UserBasicInfo> _userInfoFuture;
  late Future<void> _initFontFuture;
  late Future<List<ThemeItem>> _initThemeFuture;
  bool _fontInitScheduled = false;
  UserBasicInfo userinfo = UserBasicInfo(
      email: "",
      profile:
          Profile(nickname: "", avatar: Avatar(name: "", url: ""))); // 初始化 user
  List<ThemeItem> themes = [];

  Future<UserBasicInfo> init() async {
    final value = await official.Http().userInfo();
    if (value.isNotOK) {
      if (mounted) {
        showErrMsg(context, "服务器连接失败");
        return userinfo;
      }
      return userinfo;
    }

    setState(() {
      userinfo = UserBasicInfo(email: value.email, profile: value.profile);
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
      create: (context) => GroupsManager(),
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
        drawer: HomeDrawer(
          userInfoFuture: _userInfoFuture,
          userinfo: userinfo,
          onUserInfoUpdate: () {
            setState(() {
              _userInfoFuture = init();
            });
          },
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
                              Provider.of<GroupsManager>(context, listen: false)
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
          return const CircleAvatar(
            radius: 15,
            child: Icon(Icons.person, size: 20),
          );
        }

        final avatarUrl = snapshot.data?.profile.avatar.url;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: CircleAvatar(
              radius: 15,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(
                      "${HTTPConfig.indexServerAddress}$avatarUrl",
                    )
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Future<List<ThemeItem>> initTheme() async {
    final list = await Grpc().getthemes();
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
          child: Text('新增主题'),
          onTap: () => dialogAddTheme(),
        ),
        PopupMenuItem(
          value: 3,
          onTap: dialogAddGroup,
          child: Text(
            '新增分组',
          ),
        ),
      ],
    );
  }

  // 窗口: 新增主题
  void dialogAddTheme() async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            autofocus: true,
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

    final res = await Grpc().createTheme(RequestCreateTheme(name: result!));

    if (res.isNotOK) {
      return;
    }

    // 刷新主题列表
    setState(() {
      _initThemeFuture = initTheme();
    });
  }

  // 窗口: 新增分组
  void dialogAddGroup() {
    // 保存包含 Provider 的 context
    final scaffoldContext = scaffoldKey.currentContext;
    if (scaffoldContext == null) {
      return;
    }

    final nameController = TextEditingController();
    String? inputValue;
    int freezeDays = 30;
    int step = 0;

    showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(step == 0 ? "创建分组" : "选择自动定格时间"),
              content: step == 0
                  ? TextField(
                      controller: nameController,
                      autofocus: true,
                      onChanged: (value) {
                        inputValue = value;
                      },
                      decoration: const InputDecoration(hintText: "请输入分组名称"),
                    )
                  : RadioGroup<int>(
                      groupValue: freezeDays,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          freezeDays = value;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("若在选定时间未操作，自动进入定格缓冲期。"),
                          const SizedBox(height: 6),
                          ...[7, 30, 60, 90].map(
                            (days) => RadioListTile<int>(
                              title: Text("$days天"),
                              value: days,
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: <Widget>[
                if (step == 1)
                  TextButton(
                    child: const Text('上一步'),
                    onPressed: () {
                      setState(() {
                        step = 0;
                      });
                    },
                  ),
                TextButton(
                  child: Text(step == 0 ? '下一步' : '确定'),
                  onPressed: () async {
                    if (step == 0) {
                      final name = (inputValue ?? nameController.text).trim();
                      if (name.isEmpty) {
                        showErrMsg(context, "请输入分组名称");
                        return;
                      }
                      inputValue = name;
                      setState(() {
                        step = 1;
                      });
                      return;
                    }

                    final name = (inputValue ?? nameController.text).trim();
                    if (name.isEmpty) {
                      showErrMsg(context, "请输入分组名称");
                      return;
                    }

                    // 使用 scaffoldContext 来访问 Provider
                    if (!mounted) return;

                    final ok = await Provider.of<GroupsManager>(scaffoldContext,
                            listen: false)
                        .add(name, freezeDays: freezeDays);

                    if (!mounted) return;

                    if (!ok) {
                      if (!context.mounted) return;
                      showErrMsg(context, "创建失败");
                      return;
                    }

                    if (!dialogContext.mounted) return;

                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
