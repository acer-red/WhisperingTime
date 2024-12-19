import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'group/group.dart';
import 'package:whispering_time/http.dart';

class Item {
  bool? isPressed;
  String? tid;
  String? themename;
  Item({this.tid, this.themename, this.isPressed});
}

// 主题页面
class ThemePage extends StatefulWidget {
  @override
  State createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  List<Item> _items = [];

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
          _items.add(Item(
              tid: list.data[i].id,
              themename: list.data[i].name,
              isPressed: false));
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
            ConstrainedBox(
              constraints: BoxConstraints(
                
                minHeight: 70,
                maxHeight: 140,
              ),
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
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: _items[index].isPressed!
          ? Column(
              children: [
                Row(
                  children: [
                    Text(_items[index].themename!),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz),
                      onSelected: (String value) {
                        // 处理菜单项点击事件
                        switch (value) {
                          case '重命名':
                            rename(index);
                            break;
                          case '导出':
                            // 执行编辑操作
                            print("导出");
                            break;
                          case '删除':
                            remove(_items[index]);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: '重命名',
                          child: Text('重命名'),
                        ),
                        const PopupMenuItem<String>(
                          value: '导出',
                          child: Text(
                            '导出',
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: '删除',
                          child: Text(
                            '删除',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only( bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupPage(
                                  themename: _items[index].themename!,
                                  tid: _items[index].tid!)));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // 阴影大小
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 圆角
                      ),
                  
                    ),
                    child: Text(
                      "成长印迹",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only( bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupPage(
                                  themename: _items[index].themename!,
                                  tid: _items[index].tid!)));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // 阴影大小
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // 圆角
                      ),
                    ),
                    child: Text(
                      "定格印迹",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            )
          : ElevatedButton(
              onPressed: () {
                setState(() {
                  _items[index].isPressed = true;
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 0, // 阴影大小
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // 圆角
                ),
                padding: EdgeInsets.only(left: 25,right: 25)
              ),
              child: Text(
                _items[index].themename!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
    );
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

    if (res['err'] != 0) {
      return;
    }

    setState(() {
      _items.add(Item(themename: result, isPressed: false));
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
            decoration: InputDecoration(hintText: _items[index].themename!),
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
        name: _items[index].themename!, id: _items[index].tid!));

    if (res['err'] != 0) {
      return;
    }

    setState(() {
      _items[index].themename = result;
    });
  }

  void remove(Item item) async {
    if (item.tid == null) {
      setState(() {
        _items.remove(item);
      });
      return;
    }

    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除", title: "提示")))) {
      return;
    }

    final res = Http(content: item.tid).deletetheme();
    res.then((res) {
      if (res.err != 0) {
        return;
      }
      setState(() {
        _items.remove(item);
      });
    });
  }
}