import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'group/group.dart';
import 'package:whispering_time/http.dart';

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
  List<Theme> _items = [];

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
                    PopupMenuItem<String>(
                      value: 'event_export',
                      enabled: _items.isNotEmpty,
                      child: const Text(
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
                child: Text(
                  '删除',
                  style: TextStyle(color: Colors.red.shade400),
                ),
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
                break;
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
            enabled: true,
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

    final res = await Http(tid: _items[index].id)
        .puttheme(RequestPutTheme(name: result!));

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

    final res = await Http(tid: item.id).deletetheme();

    if (res.isNotOK()) {
      return;
    }
    setState(() {
      _items.remove(item);
    });
  }

  clickExportTheme() async {
    int ret = await showExportOption();
    switch (ret) {
      case 0:
        exportDesktopTXT();
        break;
      default:
        break;
    }
  }

  exportDesktopTXT() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    // 用户取消了操作
    if (selectedDirectory == null) {
      return;
    }

    Directory directory = Directory(selectedDirectory);
    print('选择的文件夹路径：${directory.path}');

    final themes = await Http().getthemes();
    if (themes.isNotOK()) {
      return;
    }
    if (themes.data.isEmpty) {
      return;
    }


    // // 遍历文件列表并写入
    // for (ThemeListData theme in themes.data) {
    //   final ret = await Http(gid: _gitems[gidx].id).getDocs();

    //   if (ret.isNotOK()) {
    //     print(ret);
    //     return;
    //   }

    //   final String fileName = item.title.isEmpty
    //       ? item.crtime.toString()
    //       : "${item.title} - ${Time.string(item.crtime)}" ".txt";
    //   final String filePath = '$selectedDirectory/$fileName';

    //   // 创建并写入文件
    //   File file = File(filePath);
    //   await file.writeAsString(item.content);
    //   print('文件已写入: $filePath');
    // }
  }

  Future<int> showExportOption() async {
    int? ret = await showDialog<int>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("导出"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("导出到本地"),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(0);
                    },
                    child: Text("仅文本")),
                divider(),
              ],
            ),
          ),
        );
      },
    );

    return ret ?? -1; // 如果用户没有点击按钮，则默认为 false
  }
}
