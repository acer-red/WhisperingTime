import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whispering_time/pages/doc/setting.dart';
import 'package:whispering_time/pages/doc/scene.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/services/grpc/grpc.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:whispering_time/utils/picker_wheel.dart';
import 'package:whispering_time/pages/group/model.dart';
import 'package:whispering_time/pages/doc/model.dart';
import 'package:whispering_time/pages/doc/manager.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/pages/group/manager.dart';
import 'package:whispering_time/pages/doc/edit.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.group.name), centerTitle: true, actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => createNewDoc()),
        IconButton(
            onPressed: () => playDocPage(), icon: Icon(Icons.play_arrow)),
        IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () => _showBottomMenuOfDocList(context)),
      ]),
      body: widget.group.config.viewType == 1 ? screenCalendar() : screenCard(),
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
        return _FilterBottomSheet(
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
    RequestPutGroup req = RequestPutGroup();
    req.config = GroupConfigNULL(
      viewType: widget.group.config.viewType,
      sortType: widget.group.config.sortType,
      levels: widget.group.config.levels,
      isMulti: widget.group.config.isMulti,
      isAll: widget.group.config.isAll,
    );
    await Http(tid: widget.tid, gid: widget.group.id).putGroup(req);
    if (mounted) {
      final groups = Provider.of<GroupsManager>(context, listen: false);
      groups.updateConfig();
      groups.touch(gid: widget.group.id);
    }
  }

  void playDocPage() {
    const Duration tim = Duration(milliseconds: 800);
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a, b) {
            return ScenePage(
              docs: docsManager.items,
              group: widget.group,
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
  void createNewDoc() {
    Doc newDoc = Doc(
      id: '',
      title: '',
      content: '',
      plainText: '',
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
                      docsManager.insertDoc(updatedDoc);
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

  // UI: 主体内容-卡片模式
  Widget screenCard() {
    return ListView.builder(
        itemCount: docsManager.items.length,
        itemBuilder: (context, index) {
          final item = docsManager.items[index];
          final isExpanded = expandedIndex == index;
          log.d(item.toJson());

          return GestureDetector(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: isExpanded
                  ? _buildExpandedCard(index, item)
                  : _buildPreviewCard(index, item),
            ),
          );
        });
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
                createAt: item.createAt,
                config: item.config)));
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
        if (result['createAt'] != null) {
          item.createAt = result['createAt'];
        }
        if (result['config'] != null) {
          item.config = result['config'];
        }
      });
    }
  }

  // 构建预览模式的卡片
  Widget _buildPreviewCard(int index, Doc item) {
    return InkWell(
      onTap: () => toggleExpand(index),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Visibility(
                    visible: item.title.isNotEmpty ||
                        (item.title.isEmpty && Config.instance.visualNoneTitle),
                    child: Text(
                      item.title.isEmpty ? '未命名' : item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // 印迹具体内容
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                item.plainText.trimRight(),
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 创建时间
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Level.l[item.level],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(" · ",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text(
                    Time.string(item.createAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 构建展开模式的卡片
  Widget _buildExpandedCard(int index, Doc item) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 标题和顶部按钮栏
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (item.title.isNotEmpty ||
                  (item.title.isEmpty && Config.instance.visualNoneTitle))
                Expanded(
                  child: Text(
                    item.title.isEmpty ? '未命名' : item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              else
                Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.settings, size: 20),
                    onPressed: () => enterSettingDialog(item),
                    tooltip: '设置',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () => _navigateToEditPage(index, item),
                    tooltip: '编辑',
                  ),
                  IconButton(
                    icon: Icon(Icons.expand_less, size: 20),
                    onPressed: () => toggleExpand(null),
                    tooltip: '收缩',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),

          // 完整内容
          _buildQuillViewer(item),

          SizedBox(height: 16),

          // 创建时间
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Level.l[item.level],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(" · ",
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(
                  Time.string(item.createAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuillViewer(Doc item) {
    if (item.content.isEmpty) return SizedBox.shrink();
    try {
      final doc = Document.fromJson(jsonDecode(item.content));
      return QuillEditor(
        controller: QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true),
        focusNode: FocusNode(),
        scrollController: ScrollController(),
        config: QuillEditorConfig(
          embedBuilders: [
            _CustomImageEmbedBuilder(),
            ...(kIsWeb
                    ? FlutterQuillEmbeds.editorWebBuilders()
                    : FlutterQuillEmbeds.editorBuilders())
                .where((builder) => builder.key != 'image'),
          ],
          scrollable: false,
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          enableInteractiveSelection: true,
        ),
      );
    } catch (e) {
      return Text(item.plainText);
    }
  }

  // 切换展开状态
  void toggleExpand(int? index) {
    setState(() {
      expandedIndex = index;
    });
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

  // UI: 主体内容-日历模式
  Widget screenCalendar() {
    if (docsManager.items.isEmpty) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              _buildWeekHeaderWithPadding(),
              _buildMonthRow(DateTime.now()),
            ],
          ),
        ),
      );
    }

    DateTime minDate = docsManager.items.first.createAt;
    DateTime maxDate = docsManager.items.first.createAt;
    for (var doc in docsManager.items) {
      if (doc.createAt.isBefore(minDate)) minDate = doc.createAt;
      if (doc.createAt.isAfter(maxDate)) maxDate = doc.createAt;
    }

    if (pickedDate.isBefore(minDate)) minDate = pickedDate;
    if (pickedDate.isAfter(maxDate)) maxDate = pickedDate;

    minDate = DateTime(minDate.year, minDate.month);
    maxDate = DateTime(maxDate.year, maxDate.month);

    List<Widget> children = [];
    children.add(_buildWeekHeaderWithPadding());

    List<DateTime> gapMonths = [];

    void flushGap() {
      if (gapMonths.isEmpty) return;
      String gapId =
          "${gapMonths.first.millisecondsSinceEpoch}-${gapMonths.last.millisecondsSinceEpoch}";
      if (_expandedRanges.contains(gapId)) {
        for (var date in gapMonths) {
          children.add(_buildMonthRow(date));
        }
      } else {
        children.add(_buildGapButton(gapId, gapMonths));
      }
      gapMonths.clear();
    }

    DateTime current = minDate;
    while (current.isBefore(maxDate) ||
        current.year == maxDate.year && current.month == maxDate.month) {
      bool hasDocs = docsManager.items.any((d) =>
          d.createAt.year == current.year && d.createAt.month == current.month);
      bool isPicked =
          current.year == pickedDate.year && current.month == pickedDate.month;

      if (hasDocs || isPicked) {
        flushGap();
        String keyStr = "${current.year}-${current.month}";
        GlobalKey key = _monthKeys.putIfAbsent(keyStr, () => GlobalKey());
        children.add(_buildMonthRow(current, key: key));
      } else {
        gapMonths.add(current);
      }

      current = DateTime(current.year, current.month + 1);
    }
    flushGap();

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width,
        child: ListView(
          padding: EdgeInsets.only(right: 12),
          children: children,
        ),
      ),
    );
  }

  void _chooseDate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: _DatePickerDialog(
            docsManager: docsManager,
            initialDate: pickedDate,
            onConfirm: (DateTime date) {
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
          ),
        );
      },
    );
  }

  Widget _buildWeekHeaderWithPadding() {
    return Row(
      children: [
        SizedBox(width: 44),
        Expanded(child: _buildWeekHeader()),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return SizedBox(
      height: 30,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 2.0,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            return Align(
                alignment: Alignment.center,
                child: Text(_getWeekString(index),
                    style: TextStyle(fontSize: 12)));
          }),
    );
  }

  Widget _buildMonthRow(DateTime date, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: _buildMonthSideHeader(date),
          ),
          Expanded(child: _buildMonthGrid(date)),
        ],
      ),
    );
  }

  Widget _buildMonthSideHeader(DateTime date) {
    return InkWell(
      onTap: _chooseDate,
      child: Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('MM').format(date),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown),
            ),
            Text(
              DateFormat('yyyy').format(date),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGapButton(String gapId, List<DateTime> months) {
    return TextButton(
      onPressed: () {
        setState(() {
          _expandedRanges.add(gapId);
        });
      },
      child: Icon(Icons.more_horiz),
    );
  }

  Widget _buildMonthGrid(DateTime date) {
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    int firstWeekdayOfMonth = DateTime(date.year, date.month, 1).weekday;
    int totalRows = ((daysInMonth + firstWeekdayOfMonth - 1) / 7).ceil();
    int totalitems = totalRows * 7;

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
      ),
      itemCount: totalitems,
      itemBuilder: (context, index) {
        int dayNumber = index - firstWeekdayOfMonth + 2;
        if (!(dayNumber > 0 && dayNumber <= daysInMonth)) {
          return Container();
        }

        int docIndex = -1;
        for (int i = 0; i < docsManager.items.length; i++) {
          var d = docsManager.items[i];
          if (d.createAt.year == date.year &&
              d.createAt.month == date.month &&
              d.createAt.day == dayNumber) {
            docIndex = i;
            break;
          }
        }

        bool istoday = dayNumber == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;

        if (docIndex != -1) {
          return _grid(istoday, dayNumber, docIndex);
        } else {
          return _gridNoFlag(istoday, dayNumber);
        }
      },
    );
  }

  String _getWeekString(int index) {
    switch (index) {
      case 0:
        return "周一";
      case 1:
        return "周二";
      case 2:
        return "周三";
      case 3:
        return "周四";
      case 4:
        return "周五";
      case 5:
        return "周六";
      default:
        return "周日";
    }
  }

  Widget _grid(bool istoday, int dayNumber, int i) {
    return GestureDetector(
      onTap: () => _navigateToEditPage(i, docsManager.items[i]),
      child: Align(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "$dayNumber",
                style: TextStyle(
                    fontSize: 18,
                    color: istoday ? Colors.blue : Colors.black,
                    fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
              ),
              Icon(
                Icons.star_rounded,
                size: 10,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridNoFlag(bool istoday, int dayNumber) {
    return GestureDetector(
      child: Align(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "$dayNumber",
                style: TextStyle(
                    fontSize: 18,
                    color: istoday ? Colors.blue : Colors.grey,
                    fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
              ),
              Icon(
                Icons.star_rounded,
                size: 10,
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 功能：更新当前分组下的印迹列表
  void getDocs({int? year, int? month}) async {
    docsManager.fetchDocs(
        year: year, month: month, config: widget.group.config);
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

class _FilterBottomSheet extends StatefulWidget {
  final int initialViewType;
  final int initialSortType;
  final List<bool> initialLevels;
  final Function(int, int, List<bool>) onChanged;

  const _FilterBottomSheet({
    required this.initialViewType,
    required this.initialSortType,
    required this.initialLevels,
    required this.onChanged,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late int viewType;
  late int sortType;
  late List<bool> levels;

  @override
  void initState() {
    super.initState();
    viewType = widget.initialViewType;
    sortType = widget.initialSortType;
    levels = List.from(widget.initialLevels);
  }

  void _updateState(VoidCallback fn) {
    setState(fn);
    widget.onChanged(viewType, sortType, levels);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          ShortGreyLine(),
          SizedBox(height: 10),
          // View Mode
          ListTile(
            title: Text('显示模式'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text('卡片'),
                  selected: viewType == 0,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => viewType = 0);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('日历'),
                  selected: viewType == 1,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => viewType = 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Sort Mode
          ListTile(
            title: Text('排序模式'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text('创建时间'),
                  selected: sortType == 0,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => sortType = 0);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('更新时间'),
                  selected: sortType == 1,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => sortType = 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Level Selection
          ExpansionTile(
            title: Text('分级筛选'),
            children: List.generate(Level.l.length, (index) {
              return CheckboxListTile(
                title: Text(Level.l[index]),
                value: levels[index],
                onChanged: (bool? value) {
                  if (value != null) {
                    _updateState(() => levels[index] = value);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    var imageSource = embedContext.node.value.data as String;

    // 如果不是完整URL（不以http开头），则拼接服务器地址
    if (!imageSource.startsWith('http://') &&
        !imageSource.startsWith('https://')) {
      final serverAddress = Config.instance.serverAddress;
      final uid = Config.instance.uid;
      imageSource = '$serverAddress/image/$uid/$imageSource';
    }

    // 使用默认的图片widget显示
    return Image.network(
      imageSource,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
                SizedBox(height: 8),
                Text('图片加载中...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        );
      },
    );
  }
}

class _DatePickerDialog extends StatefulWidget {
  final DocsManager docsManager;
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;

  const _DatePickerDialog({
    required this.docsManager,
    required this.initialDate,
    required this.onConfirm,
  });

  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late int selectedYear;
  late int selectedMonth;
  late List<int> years;
  late List<int> months;
  late FixedExtentScrollController yearController;
  late FixedExtentScrollController monthController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;

    years = widget.docsManager.getAvailableYears();
    if (years.isEmpty) {
      years = [DateTime.now().year];
    }
    if (!years.contains(selectedYear)) {
      selectedYear = years.first;
    }

    _updateMonths();

    yearController = FixedExtentScrollController(
        initialItem:
            years.contains(selectedYear) ? years.indexOf(selectedYear) : 0);
    monthController = FixedExtentScrollController(
        initialItem:
            months.contains(selectedMonth) ? months.indexOf(selectedMonth) : 0);
  }

  void _updateMonths() {
    List<String> monthStrs = widget.docsManager.getAvailableMonth(selectedYear);
    months = monthStrs.map((e) => int.parse(e)).toList();
    if (months.isEmpty) {
      months = [1];
    }
    if (!months.contains(selectedMonth)) {
      selectedMonth = months.first;
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  widget.onConfirm(DateTime(selectedYear, selectedMonth));
                  Navigator.pop(context);
                },
                child: Text('确定'),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                YearPickerWheel(
                  selectedYear: selectedYear,
                  years: years,
                  controller: yearController,
                  onYearChanged: (year) {
                    setState(() {
                      selectedYear = year;
                      _updateMonths();
                      // Reset month controller if needed or jump to new index
                      if (months.contains(selectedMonth)) {
                        monthController
                            .jumpToItem(months.indexOf(selectedMonth));
                      } else {
                        monthController.jumpToItem(0);
                      }
                    });
                  },
                ),
                MonthPickerWheel(
                  selectedMonth: selectedMonth,
                  months: months,
                  controller: monthController,
                  onMonthChanged: (month) {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
