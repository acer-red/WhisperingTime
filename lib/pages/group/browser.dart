import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/pages/doc/browser.dart';

import 'manager.dart';
import 'settings.dart';

class GroupPage extends StatefulWidget {
  final String? id;
  final String tid;
  final String themename;
  GroupPage({required this.themename, required this.tid, this.id});

  @override
  State<StatefulWidget> createState() => _GroupPage();
}

class _GroupPage extends State<GroupPage> with AutomaticKeepAliveClientMixin {
  int gidx = 0;
  bool isGrouTitleSubmitted = true;
  int pageIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GroupsManager>().fetchForTheme(widget.tid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: context.watch<GroupsManager>().getLength(widget.tid),
        itemBuilder: (context, index) {
          final items = context.watch<GroupsManager>().getItems(widget.tid);
          if (index >= items.length) return SizedBox();

          final item = items[index];
          final name = item.name;

          return Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onLongPress: () {
                context.read<GroupsManager>().setIndex(index);
                final i = items[index];
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext modalContext) {
                    // 使用 ChangeNotifierProvider.value 而不是 Provider.value
                    return ChangeNotifierProvider.value(
                      value: context.read<GroupsManager>(),
                      child: GroupSettings(
                        group: i,
                        tid: widget.tid,
                      ),
                    );
                  },
                );
              },
              // 水波纹颜色 - 使用主题色的半透明版本，更加协调
              splashColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              // 高亮颜色 - 使用更柔和的透明度
              highlightColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              // 悬停颜色 - 增加桌面端的体验
              hoverColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // 设置当前选中的索引
                context.read<GroupsManager>().setIndex(index);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DocList(group: item, tid: widget.tid)));
              },
              child: Container(alignment: Alignment.center, child: Text(name)),
            ),
          );
        },
      ),
    );
  }

  void dialogWidget(Widget widget) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }
}
