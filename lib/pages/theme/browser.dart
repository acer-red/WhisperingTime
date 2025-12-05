import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:whispering_time/pages/group/browser.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/pages/group/manager.dart';
import 'settings.dart';

class ThemeItem {
  String id;
  String name;
  ThemeItem({required this.id, required this.name});
}

class ThemePage extends StatefulWidget {
  final List<ThemeItem> titems;

  const ThemePage(this.titems, {super.key});

  @override
  State createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _lastWheelEvent = DateTime.fromMillisecondsSinceEpoch(0);
  static const _wheelThrottle = Duration(milliseconds: 220);
  bool _controllerDisposed = false;

  @override
  void dispose() {
    _disposeTabController();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 根据实际items数量初始化TabController
    _tabController = _createTabController(widget.titems.length);
  }

  @override
  void didUpdateWidget(ThemePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果items数量发生变化，更新TabController
    if (oldWidget.titems.length != widget.titems.length &&
        widget.titems.isNotEmpty) {
      final initialIndex = _tabController.index.clamp(
        0,
        widget.titems.isEmpty ? 0 : widget.titems.length - 1,
      );
      _disposeTabController();
      _tabController = _createTabController(widget.titems.length,
          initialIndex: initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.titems.isNotEmpty) ...[
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start, // 左侧对齐
            padding: EdgeInsets.zero, // 去除整体左侧间距
            indicator: UnderlineTabIndicator(
              borderRadius: BorderRadius.circular(3), // 添加圆角
              borderSide: BorderSide(
                width: 3.0,
                color: Theme.of(context).primaryColor,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 8),
            ),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            dividerHeight: 0,
            tabs: widget.titems
                .asMap()
                .entries
                .map((entry) => Tab(
                      child: GestureDetector(
                        onLongPress: () {
                          showThemeSettings(entry.key);
                        },
                        child: Text(entry.value.name),
                      ),
                    ))
                .toList(),
          ),
          Expanded(
            child: Listener(
              onPointerSignal: _handlePointerSignal,
              child: ScrollConfiguration(
                // Allow mouse drag to switch tabs
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: widget.titems
                      .map((theme) =>
                          GroupPage(themename: theme.name, tid: theme.id))
                      .toList(),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  void showThemeSettings(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return ThemeSettings(
          theme: widget.titems[index],
          onRenamed: (newName) {
            setState(() {
              widget.titems[index].name = newName;
            });
          },
          onDeleted: () {
            setState(() {
              widget.titems.removeAt(index);
              final newIndex = _tabController.index.clamp(
                0,
                widget.titems.isEmpty ? 0 : widget.titems.length - 1,
              );
              if (widget.titems.isNotEmpty) {
                _disposeTabController();
                _tabController = _createTabController(
                  widget.titems.length,
                  initialIndex: newIndex,
                );
              }
            });
          },
        );
      },
    );
  }

  TabController _createTabController(int length, {int initialIndex = 0}) {
    final controller = TabController(
      length: length,
      vsync: this,
      initialIndex: initialIndex,
    );
    controller.addListener(_onTabChanged);
    _controllerDisposed = false;
    return controller;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || widget.titems.length < 2) return;
    final now = DateTime.now();
    if (now.difference(_lastWheelEvent) < _wheelThrottle) return;

    _lastWheelEvent = now;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;

    if (delta > 0) {
      _goToIndex(_tabController.index + 1);
    } else if (delta < 0) {
      _goToIndex(_tabController.index - 1);
    }
  }

  void _goToIndex(int index) {
    if (index < 0 || index >= widget.titems.length) return;
    _tabController.animateTo(index);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging || widget.titems.isEmpty) return;
    Provider.of<GroupsManager>(context, listen: false)
        .setThemeID(widget.titems[_tabController.index].id);
  }

  void _disposeTabController() {
    if (_controllerDisposed) return;
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _controllerDisposed = true;
  }
}
