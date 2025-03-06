import 'package:flutter/material.dart';
import 'package:whispering_time/utils/env.dart';
import 'group/group.dart';
import 'package:whispering_time/services/http.dart';

class Theme {
  String id;
  String name;
  Theme({required this.id, required this.name});
}

class ThemePage extends StatefulWidget {
  @override
  State createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  List<Theme> _titems = [];

  @override
  void initState() {
    super.initState();

    final list = Http().getthemes();
    list.then((list) {
      if (list.data.isEmpty) {
        return;
      }
      for (int i = 0; i < list.data.length; i++) {
        if (list.data[i].id == "") {
          continue;
        }
        setState(() {
          _titems.add(Theme(
            id: list.data[i].id,
            name: list.data[i].name,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    double initialDragPosition = 0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 10, top: 10.0, left: 50, right: 50),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "印迹主题",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_horiz),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 'event_add_theme',
                        child: Text('添加主题'),
                        onTap: () => add(),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 70,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    initialDragPosition = details.localPosition.dx;
                  },
                  onHorizontalDragUpdate: (details) {
                    final currentPosition = details.localPosition.dx;
                    final delta = currentPosition - initialDragPosition;
                    scrollController.jumpTo(scrollController.offset - delta);
                    initialDragPosition = currentPosition;
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _titems.length,
                    scrollDirection: Axis.horizontal, // 设置滚动方向为水平
                    itemBuilder: (context, index) {
                      return _buildItem(index);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final GlobalKey buttonKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: ElevatedButton(
        key: buttonKey,
        onPressed: () {
          enterGroupPage(index);
        },
        onLongPress: () {
          final RenderBox button =
              buttonKey.currentContext!.findRenderObject() as RenderBox;
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
                child: Text('重命名'),
                onTap: () => rename(index),
              ),
              PopupMenuItem(
                value: 3,
                child: Text(
                  '删除',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () => delete(_titems[index]),
              ),
            ],
          );
        },
        style: ElevatedButton.styleFrom(
            elevation: 0, // 阴影大小
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 圆角
            ),
            padding: EdgeInsets.only(left: 25, right: 25)),
        child: Text(
          _titems[index].name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void enterGroupPage(int index) async {
    // final res = await Http(tid: _titems[index].id).getGroups();
    // if (res.isNotOK) {
    //   if (mounted) {
    //     Msg.diy(context, "获取分组失败");
    //   }
    //   return;
    // }

    // if (res.data.isEmpty) {
    //   return;
    // }
    // List<Group> gitems = res.data
    //     .map((l) => Group(
    //         name: l.name, id: l.id, overtime: l.overtime, config: l.config))
    //     .toList();
    // if (mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupPage(
                  themename: _titems[index].name, tid: _titems[index].id)));
    // }
  }

  void add() async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            onChanged: (value) {
              result = value;
            },
            decoration: const InputDecoration(hintText: "请输入主题名"),
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

    final res = await Http().postTheme(RequestPostTheme(name: result!));

    if (res.isNotOK) {
      return;
    }

    setState(() {
      _titems.add(Theme(name: result!, id: res.id));
    });
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
            decoration: InputDecoration(hintText: _titems[index].name),
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

    final res = await Http(tid: _titems[index].id)
        .putTheme(RequestPutTheme(name: result!));

    if (res.isNotOK) {
      return;
    }

    setState(() {
      _titems[index].name = result!;
    });
  }

  void delete(Theme item) async {
    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除", title: "提示")))) {
      return;
    }

    final res = await Http(tid: item.id).deleteTheme();

    if (res.isNotOK) {
      return;
    }
    setState(() {
      _titems.remove(item);
    });
  }
}
