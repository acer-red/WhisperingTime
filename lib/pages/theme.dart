import 'package:flutter/material.dart';
import 'package:whispering_time/pages/group/group.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/pages/group/model.dart';

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
            tabs: widget.titems.map((theme) => Tab(text: theme.name)).toList(),
            onTap: (value) {
              Provider.of<GroupsModel>(context, listen: false)
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

  void rename(int index) async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            enabled: true,
            onChanged: (value) {
              result = value;
            },
            decoration: InputDecoration(hintText: widget.titems[index].name),
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

    final res = await Http(tid: widget.titems[index].id)
        .putTheme(RequestPutTheme(name: result!));

    if (res.isNotOK) {
      return;
    }

    setState(() {
      widget.titems[index].name = result!;
      _tabController.dispose();
      _tabController = TabController(
          length: widget.titems.length, vsync: this, initialIndex: index);
    });
  }

  void delete(ThemeItem item) async {
    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除？", title: "提示")))) {
      return;
    }

    final res = await Http(tid: item.id).deleteTheme();

    if (res.isNotOK) {
      return;
    }
    setState(() {
      widget.titems.remove(item);
      _tabController.dispose();
      _tabController = TabController(length: widget.titems.length, vsync: this);
    });
  }
}
