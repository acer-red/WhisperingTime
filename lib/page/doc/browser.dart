import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whispering_time/page/doc/setting.dart';
import 'package:whispering_time/page/doc/scene.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/util/ui.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:whispering_time/util/picker_wheel.dart';
import 'package:whispering_time/page/group/model.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/doc/manager.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/page/group/manager.dart';
import 'package:whispering_time/page/doc/edit.dart';
import 'package:whispering_time/util/secure.dart';
import 'package:http/http.dart' as http;
import 'package:whispering_time/page/doc/time_display.dart';

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

  // 底部信息栏
  Widget _buildCardFooter(Doc item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.bookmark_border, size: 14, color: Colors.grey.shade500),
            SizedBox(width: 4),
            Text(
              Level.l[item.level],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        TimeDisplay(time: item.createAt),
      ],
    );
  }

  // 卡片: 预览模式
  Widget _buildPreviewCard(int index, Doc item) {
    return InkWell(
      onTap: () => toggleExpand(index),
      borderRadius: BorderRadius.circular(15.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 标题行
            if (item.title.isNotEmpty || Config.instance.visualNoneTitle) ...[
              Text(
                item.title.isEmpty ? '未命名' : item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
            ],

            // 印迹具体内容
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _buildRichText(item.content, limitLines: true),
            ),

            SizedBox(height: 12),

            // 底部信息
            _buildCardFooter(item),
          ],
        ),
      ),
    );
  }

  // 卡片: 展开模式
  Widget _buildExpandedCard(int index, Doc item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 顶部区域：标题与操作栏
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (item.title.isNotEmpty ||
                        Config.instance.visualNoneTitle)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                        child: Text(
                          item.title.isEmpty ? '未命名' : item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            height: 1.2,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(Icons.edit_outlined,
                      () => _navigateToEditPage(index, item), '编辑'),
                  _buildActionButton(Icons.settings_outlined,
                      () => enterSettingDialog(item), '设置'),
                  _buildActionButton(
                      Icons.expand_less, () => toggleExpand(null), '收缩'),
                ],
              ),
            ],
          ),
        ),

        // 分割线
        Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
            color: Colors.grey.withValues(alpha: 0.2)),

        // 完整内容
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: _buildRichText(item.content),
        ),

        // 底部信息
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _buildCardFooter(item),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback onPressed, String tooltip) {
    return IconButton(
      icon: Icon(icon, size: 22, color: Colors.grey.shade700),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 40, height: 40),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRichText(String content, {bool limitLines = false}) {
    if (content.isEmpty) return SizedBox.shrink();
    final Document doc;

    try {
      doc = Document.fromJson(jsonDecode(content));
    } catch (e) {
      return Text(content);
    }

    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final double fontSize = baseStyle?.fontSize ?? 14;
    final double heightFactor = baseStyle?.height ?? 1.2;
    final double? maxHeight = limitLines
        ? fontSize * heightFactor * 3 - 8 // approximate three lines
        : null;

    final editor = QuillEditor(
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
        scrollable: limitLines,
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        enableInteractiveSelection: !limitLines,
      ),
    );

    if (maxHeight != null) {
      return SizedBox(
        height: maxHeight,
        child: AbsorbPointer(
          absorbing: true, // let taps fall through to the card to expand
          child: ClipRect(child: editor),
        ),
      );
    }
    return editor;
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
    // 使用allFetchedDocs来计算日期范围，确保所有文档（包括被筛选掉的）都能显示其月份
    if (docsManager.allFetchedDocs.isEmpty) {
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

    DateTime minDate = docsManager.allFetchedDocs.first.createAt;
    DateTime maxDate = docsManager.allFetchedDocs.first.createAt;
    for (var doc in docsManager.allFetchedDocs) {
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
      bool hasDocs = docsManager.allFetchedDocs.any((d) =>
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

        List<Doc> dayDocs = [];
        for (var d in docsManager.items) {
          if (d.createAt.year == date.year &&
              d.createAt.month == date.month &&
              d.createAt.day == dayNumber) {
            dayDocs.add(d);
          }
        }

        bool istoday = dayNumber == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;

        if (dayDocs.isNotEmpty) {
          return _grid(istoday, dayNumber, dayDocs);
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

  void _showDocsBubble(BuildContext context, List<Doc> docs) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    OverlayEntry? entry;

    // 气泡配置
    final double bubbleWidth = 240.0;
    final double itemHeight = 52.0;
    final double headerHeight = 40.0;
    final double maxBubbleHeight = 280.0;
    final double tailHeight = 10.0;

    // 计算内容高度
    final double contentHeight = headerHeight + (docs.length * itemHeight);
    final double bubbleHeight =
        contentHeight.clamp(headerHeight + itemHeight, maxBubbleHeight) +
            tailHeight;

    // 计算位置
    final double centerX = offset.dx + size.width / 2;
    double left = centerX - bubbleWidth / 2;
    double top = offset.dy - bubbleHeight - 4; // 4px 间距

    // 边界检查，防止气泡超出屏幕左右边界
    final double screenWidth = MediaQuery.of(context).size.width;
    if (left < 10) left = 10;
    if (left + bubbleWidth > screenWidth - 10) {
      left = screenWidth - bubbleWidth - 10;
    }

    // 箭头相对于气泡左侧的偏移量
    final double arrowOffset = centerX - left;

    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 遮罩层，点击关闭
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                entry?.remove();
              },
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          // 气泡主体
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment(
                        (arrowOffset - bubbleWidth / 2) / (bubbleWidth / 2),
                        1.0),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: bubbleWidth,
                  height: bubbleHeight,
                  child: CustomPaint(
                    painter: _BubblePainter(
                      color: Colors.white,
                      arrowOffset: arrowOffset,
                      tailHeight: tailHeight,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                      shadowBlur: 16,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: tailHeight),
                      child: Column(
                        children: [
                          // 标题栏
                          Container(
                            height: headerHeight,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color:
                                          Colors.grey.withValues(alpha: 0.1))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_edu,
                                    size: 16,
                                    color: Theme.of(context).primaryColor),
                                SizedBox(width: 6),
                                Text(
                                  "${docs.length} 篇日记",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 列表
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.only(
                                  top: 4, bottom: 4, left: 4, right: 4),
                              itemCount: docs.length,
                              separatorBuilder: (c, i) => Divider(
                                height: 1,
                                indent: 48,
                                endIndent: 16,
                                color: Colors.grey.withValues(alpha: 0.05),
                              ),
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                String title = doc.title;
                                if (title.isEmpty) {
                                  try {
                                    final document = Document.fromJson(
                                        jsonDecode(doc.content));
                                    title = document
                                        .toPlainText()
                                        .trim()
                                        .split('\n')
                                        .first;
                                    if (title.length > 12) {
                                      title = '${title.substring(0, 12)}...';
                                    }
                                  } catch (e) {
                                    title = "无标题";
                                  }
                                }
                                if (title.isEmpty) title = "无标题";

                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    entry?.remove();
                                    int globalIndex =
                                        docsManager.items.indexOf(doc);
                                    if (globalIndex != -1) {
                                      _navigateToEditPage(globalIndex, doc);
                                    }
                                  },
                                  child: Container(
                                    height: itemHeight - 8, // 减去padding
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                DateFormat('HH:mm')
                                                    .format(doc.createAt),
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right,
                                            size: 16,
                                            color: Colors.grey.shade300),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(entry);
  }

  Widget _grid(bool istoday, int dayNumber, List<Doc> dayDocs) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () => _showDocsBubble(context, dayDocs),
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
    });
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

    if (imageSource.startsWith('file:')) {
      return _EncryptedImage(fileId: imageSource.substring(5));
    }

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

class _EncryptedImage extends StatefulWidget {
  final String fileId;

  const _EncryptedImage({required this.fileId});

  @override
  State<_EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends State<_EncryptedImage> {
  late Future<Uint8List> _future;
  final Storage _storage = Storage();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Uint8List> _load() async {
    final presign = await Grpc().presignDownloadFile(widget.fileId);
    if (!presign.isOK ||
        presign.downloadUrl == null ||
        presign.encryptedKey == null) {
      throw Exception(presign.msg.isEmpty ? '无法获取文件' : presign.msg);
    }

    final resp = await http.get(Uri.parse(presign.downloadUrl!));
    if (resp.statusCode >= 400) {
      throw Exception('下载失败: HTTP ${resp.statusCode}');
    }

    return _storage.envelopeDecrypt(
      cipherText: Uint8List.fromList(resp.bodyBytes),
      encryptedKey: presign.encryptedKey!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                const SizedBox(height: 4),
                Text('图片加载失败',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return const SizedBox.shrink();
        }
        return Image.memory(data, fit: BoxFit.contain);
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

class _BubblePainter extends CustomPainter {
  final Color color;
  final double arrowOffset;
  final double tailHeight;
  final Color shadowColor;
  final double shadowBlur;

  _BubblePainter({
    required this.color,
    required this.arrowOffset,
    required this.tailHeight,
    required this.shadowColor,
    required this.shadowBlur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - tailHeight);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)))
      ..moveTo(rect.left + arrowOffset - 8, rect.bottom)
      ..lineTo(rect.left + arrowOffset, rect.bottom + tailHeight)
      ..lineTo(rect.left + arrowOffset + 8, rect.bottom)
      ..close();

    canvas.drawShadow(path, shadowColor, shadowBlur, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
