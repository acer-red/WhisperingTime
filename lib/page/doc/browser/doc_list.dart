import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/page/group/model.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/doc/manager.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/page/doc/scene.dart';
import 'package:whispering_time/page/doc/edit.dart';
import 'package:whispering_time/page/doc/setting.dart';
import 'package:whispering_time/page/group/manager.dart';
import 'package:whispering_time/page/doc/browser/card_view.dart';
import 'package:whispering_time/page/doc/browser/calendar_view.dart';
import 'package:whispering_time/page/doc/browser/filter_sheet.dart';

class DocList extends StatefulWidget {
  final Group group;
  final String tid;

  DocList({required this.group, required this.tid});

  @override
  State createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  late DocsManager docsManager;

  DateTime pickedDate = DateTime.now();
  int? expandedIndex; // 当前展开的Card索引
  Set<String> _expandedRanges = {};
  final Map<String, GlobalKey> _monthKeys = {};
  Map<String, bool> _flippedStates = {};

  @override
  void initState() {
    super.initState();
    docsManager = DocsManager(widget.group.id);
    docsManager.addListener(() {
      if (mounted) setState(() {});
    });
    docsManager.fetchDocs(config: widget.group.config);
    log.d(widget.group.toString());
  }

  @override
  void dispose() {
    docsManager.dispose();
    super.dispose();

    // 如果这个group是已经定格的，就输出日志
    if (widget.group.isFreezedOrBuf()) {
      log.d('Group ${widget.group.name} is freezed or buffered');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.group.name), centerTitle: true, actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => navigatorNewDoc()),
        IconButton(
            onPressed: () => playDocPage(), icon: Icon(Icons.play_arrow)),
        IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () => _showBottomMenuOfDocList(context)),
      ]),
      body: widget.group.config.viewType == 1 ? screenCalendar() : screenCard(),
    );
  }

  Widget screenCard() {
    return DocCardList(
      docsManager: docsManager,
      expandedIndex: expandedIndex,
      flippedStates: _flippedStates,
      onToggleExpand: (index) {
        setState(() {
          expandedIndex = index;
        });
      },
      onEdit: (index, item) => _navigateToEditPage(index, item),
      onSetting: (item) => enterSettingDialog(item),
      onFlip: (id, isFlipped) {
        setState(() {
          _flippedStates[id] = isFlipped;
        });
      },
    );
  }

  Widget screenCalendar() {
    return DocCalendarView(
      docsManager: docsManager,
      pickedDate: pickedDate,
      expandedRanges: _expandedRanges,
      monthKeys: _monthKeys,
      onDatePicked: (date) {
        setState(() {
          pickedDate = date;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String keyStr = "${date.year}-${date.month}";
          GlobalKey? key = _monthKeys[keyStr];
          if (key != null && key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      onGapExpanded: (gapId) {
        setState(() {
          _expandedRanges.add(gapId);
        });
      },
      onEdit: (doc) {
        int index = docsManager.items.indexOf(doc);
        if (index != -1) {
          _navigateToEditPage(index, doc);
        }
      },
      onSetting: (doc) => enterSettingDialog(doc),
    );
  }

  void _showBottomMenuOfDocList(BuildContext context) {
    // 记录初始状态
    final initialViewType = widget.group.config.viewType;
    final initialSortType = widget.group.config.sortType;
    final initialLevels = List<bool>.from(widget.group.config.levels);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterBottomSheet(
          initialViewType: widget.group.config.viewType,
          initialSortType: widget.group.config.sortType,
          initialLevels: widget.group.config.levels,
          onChanged: (v, s, l) {
            _updateConfig(
                viewType: v, sortType: s, levels: l, saveToServer: false);
          },
        );
      },
    ).whenComplete(() {
      // 比较是否有变化，如果有则更新
      bool isLevelsChanged =
          !listEquals(initialLevels, widget.group.config.levels);
      if (initialViewType != widget.group.config.viewType ||
          initialSortType != widget.group.config.sortType ||
          isLevelsChanged) {
        _syncConfigToServer();
      }
    });
  }

  void _updateConfig(
      {int? viewType,
      int? sortType,
      List<bool>? levels,
      bool saveToServer = true}) async {
    setState(() {
      if (viewType != null) widget.group.config.viewType = viewType;
      if (sortType != null) widget.group.config.sortType = sortType;
      if (levels != null) widget.group.config.levels = levels;

      // Re-sort or re-filter items
      docsManager.filterAndSort(widget.group.config);
    });

    if (saveToServer) {
      _syncConfigToServer();
    }
  }

  void _syncConfigToServer() async {
    // Save to server
    RequestUpdateGroup req = RequestUpdateGroup();
    req.config = GroupConfigNULL(
      viewType: widget.group.config.viewType,
      sortType: widget.group.config.sortType,
      levels: widget.group.config.levels,
    );
    await Grpc(tid: widget.tid, gid: widget.group.id).putGroup(req);
    if (mounted) {
      final groups = Provider.of<GroupsManager>(context, listen: false);
      groups.updateConfig();
      groups.touch(gid: widget.group.id);
    }
  }

  void playDocPage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                '选择播放模式',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.movie_filter,
                    size: 32, color: Colors.blue),
                title: const Text('流年'),
                subtitle: const Text(
                  '自动上浮，像电影片尾一样播放',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToScene(SceneMode.scroll);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.slideshow, size: 32, color: Colors.orange),
                title: const Text('聚焦'),
                subtitle: const Text(
                  '一文一停，专注于每一篇图文细节',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToScene(SceneMode.focus);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScene(SceneMode mode) {
    const Duration tim = Duration(milliseconds: 800);
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a, b) {
            return ScenePage(
              docs: docsManager.items,
              group: widget.group,
              mode: mode,
            );
          },
          transitionDuration: tim,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ));
  }

  // 创建新文档
  void navigatorNewDoc() {
    Doc newDoc = Doc(
      id: '',
      title: '',
      content: '',
      level: getSelectLevel(),
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      config: DocConfig(isShowTool: Config.instance.defaultShowTool),
    );
    final groupsManager = context.read<GroupsManager>();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
                value: groupsManager,
                child: EditPage(
                  doc: newDoc,
                  group: widget.group,
                  onSave: (updatedDoc) {
                    setState(() {
                      docsManager.insertDoc(updatedDoc,
                          config: widget.group.config);
                    });
                  },
                  onDelete: () {
                    // setState(() {
                    //   docsManager.removeDoc(item);
                    //   expandedIndex = null;
                    // });
                  },
                ),
              )),
    );
  }

  // 打开设置对话框
  void enterSettingDialog(Doc item) async {
    final groupsManager = context.read<GroupsManager>();
    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
            value: groupsManager,
            child: DocSettingsDialog(
                gid: widget.group.id,
                did: item.id,
                config: item.config,
                fromBrowser: true)));
    if (result == null) return;

    if (result['deleted'] == true) {
      expandedIndex = null;
      setState(() {
        docsManager.removeDoc(item);
      });
      return;
    }

    if (result['changed'] == true) {
      setState(() {
        if (result['config'] != null) {
          item.config = result['config'];
        }
      });
    }
  }

  // 跳转到编辑页面
  void _navigateToEditPage(int index, Doc item) {
    final groupsManager = context.read<GroupsManager>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: groupsManager,
          child: EditPage(
            doc: item,
            group: widget.group,
            onSave: (updatedDoc) {
              setState(() {
                // 更新列表中的文档
                Doc oldDoc = docsManager.items[index];
                docsManager.updateDoc(oldDoc, updatedDoc, widget.group.config);
              });
            },
            onDelete: () {
              setState(() {
                docsManager.removeDoc(item);
                expandedIndex = null;
              });
            },
          ),
        ),
      ),
    );
  }

  int getSelectLevel() {
    for (int buttonIndex = 0;
        buttonIndex < widget.group.config.levels.length;
        buttonIndex++) {
      if (widget.group.config.levels[buttonIndex]) {
        return buttonIndex;
      }
    }
    return 0;
  }
}
