import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'group/group.dart';
import 'package:whispering_time/http.dart';

class Theme {
  String id;
  String name;
  Theme({required this.id, required this.name});
}

// 主题页面
class ThemePage extends StatefulWidget {
  @override
  State createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  List<Theme> _items = [];

  @override
  void initState() {
    super.initState();

    final list = Http().gettheme();
    list.then((list) {
      if (list.data.isEmpty) {
        return;
      }
      for (int i = 0; i < list.data.length; i++) {
        if (list.data[i].id == "") {
          continue;
        }
        setState(() {
          _items.add(Theme(
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
      body: Padding(
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
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz),
                  onSelected: (String value) {
                    // 处理菜单项点击事件
                    switch (value) {
                      case 'event_add_theme':
                        add();
                        break;
                      case 'event_export':
                        // 执行编辑操作
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'event_add_theme',
                      child: Text('添加主题'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'event_export',
                      child: Text(
                        '导出',
                      ),
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
                  itemCount: _items.length,
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
    );
  }

  Widget _buildItem(int index) {
    final GlobalKey buttonKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: ElevatedButton(
        key: buttonKey,
        onPressed: () {
          clickTheme(index);
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
              ),
              PopupMenuItem(value: 2, child: Text('导出')),
              PopupMenuItem(
                value: 3,
                child: Text('删除',style: TextStyle(color: Colors.red.shade400),),
              ),
            ],
          ).then((value) {
            switch (value) {
              case 1:
                rename(index);
                break;
              case 2:
                print("导出");
                // export();
                break;
              case 3:
                delete(_items[index]);
                break;
              default:
                throw ArgumentError("shwoMenu");
            }
            // 处理菜单项选择事件
          });
        },
        style: ElevatedButton.styleFrom(
            elevation: 0, // 阴影大小
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 圆角
            ),
            padding: EdgeInsets.only(left: 25, right: 25)),
        child: Text(
          _items[index].name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void clickTheme(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupPage(
                themename: _items[index].name, tid: _items[index].id)));
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
                Navigator.of(context).pop(result); // 返回结果并关闭对话框
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

    final res = await Http().posttheme(RequestPostTheme(name: result!));

    if (res.isNotOK()) {
      return;
    }

    setState(() {
      _items.add(Theme(name: result!, id: res.id));
    });
  }

  void rename(int index) async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            onChanged: (value) {
              result = value;
            },
            decoration: InputDecoration(hintText: _items[index].name),
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
                Navigator.of(context).pop(result); // 返回结果并关闭对话框
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

    final res = await Http().puttheme(RequestPutTheme(
        name: _items[index].name, id: _items[index].id));

    if (res.isNotOK()) {
      return;
    }

    setState(() {
      _items[index].name = result!;
    });
  }

  void delete(Theme item) async {
    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除", title: "提示")))) {
      return;
    }

    final res = Http(content: item.id).deletetheme();
    res.then((res) {
      if (res.isNotOK()) {
        return;
      }
      setState(() {
        _items.remove(item);
      });
    });
  }
}
