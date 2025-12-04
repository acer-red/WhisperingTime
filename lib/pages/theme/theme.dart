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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 根据实际items数量初始化TabController
    _tabController = TabController(length: widget.titems.length, vsync: this);
  }

  @override
  void didUpdateWidget(ThemePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果items数量发生变化，更新TabController
    if (oldWidget.titems.length != widget.titems.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.titems.length, vsync: this);
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
            onTap: (value) {
              Provider.of<GroupsManager>(context, listen: false)
                  .setThemeID(widget.titems[value].id);
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.titems
                  .map((theme) =>
                      GroupPage(themename: theme.name, tid: theme.id))
                  .toList(),
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
              _tabController.dispose();
              _tabController = TabController(
                length: widget.titems.length,
                vsync: this,
              );
            });
          },
        );
      },
    );
  }
}
