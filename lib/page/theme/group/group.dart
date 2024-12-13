import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'doc/edit.dart';
import 'package:whispering_time/http.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:timelines/timelines.dart';
class Group {
  String name;
  String id;
  bool isSubmitted;
  TextEditingController _textEditingController = TextEditingController();
  Group({required this.name, required this.id, required this.isSubmitted})
      : _textEditingController = TextEditingController(text: name);
}

class LineChartPainter extends CustomPainter {
  final List<double> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xScale = size.width / (data.length - 1);
    final yScale = size.height / (data.reduce(max) - data.reduce(min));

    path.moveTo(0, size.height - (data[0] - data.reduce(min)) * yScale);
    for (int i = 1; i < data.length; i++) {
      path.lineTo(
          i * xScale, size.height - (data[i] - data.reduce(min)) * yScale);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// 组、事件列表页面
class GroupPage extends StatefulWidget {
  final String? id;
  final String tid;
  final String themename;

  GroupPage({required this.themename, required this.tid, this.id});

  @override
  State<StatefulWidget> createState() => _GroupPage();
}

class _GroupPage extends State<GroupPage> {
  List<Group> _gitems = <Group>[];
  List<Doc> _ditems = <Doc>[];
  List<bool> _isSelected = [
    true,
    false,
    false,
    false,
    false
  ]; // 两个按钮，初始状态第一个被选中
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> viewExplain = ["卡片", "时间轴", "日历"];
  int gidx = 0;
  String? pageTitleName;
  int viewType = 0;
  int currentLevel = 0;

  @override
  void initState() {
    super.initState();
    pageTitleName = widget.themename;
    getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // 页面标题
      appBar: AppBar(
        // 标题左侧的按钮
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // 标题
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pageTitleName!),
            IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: Icon(Icons.arrow_drop_down))
          ],
        ),

        // 标题右侧的按钮
        actions: [
          TextButton(
              onPressed: () => {
                    setState(() {
                      viewType++;
                      if (viewExplain.length == viewType) {
                        viewType = 0;
                      }
                    })
                  },
              child: Text(viewExplain[viewType]))
        ],
      ),

      // 悬浮按钮
      floatingActionButton: FloatingActionButton(
        onPressed: clickNewEdit,
        child: const Icon(Icons.add),
      ),

      // 左侧分组列表
      drawer: Drawer(
        child: Column(children: [
          Expanded(
              child: ListView.builder(
            itemCount: _gitems.length,
            itemBuilder: (context, index) {
              final item = _gitems[index];
              return Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 10.0, bottom: 0.0),
                  child: item.isSubmitted
                      // 显示标题
                      ? Slidable(
                          key: ValueKey(item.id), // 每个 ListTile 需要一个唯一的 Key
                          endActionPane: ActionPane(
                            motion: ScrollMotion(), // 滑动动画效果
                            children: [
                              SlidableAction(
                                onPressed: (context) =>
                                    editLineGroup(_gitems[index]),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.blue,
                                icon: Icons.edit,
                                label: '编辑',
                              ),
                              SlidableAction(
                                onPressed: (context) => deleteLineGroup(index),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.red,
                                icon: Icons.delete,
                                label: '删除',
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(item.name),
                            onTap: () => clickGroupTitle(index),
                          ))
                      // 显示标题的编辑框
                      : Row(children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: '组名',
                              ),
                              controller: _gitems[index]._textEditingController,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () => submitEditGroup(_gitems[index]),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_rounded),
                            onPressed: () => cancelEditGroup(index),
                          )
                        ]));
            },
          )),
          BottomActionButtons(onAddPressed: () {
            setState(() {
              _gitems.add(Group(name: "", id: "", isSubmitted: false));
            });
          }),
        ]),
      ),

      // 主体内容
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // 日记 分级按钮
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      currentLevel = index;
                      for (int buttonIndex = 0;
                          buttonIndex < _isSelected.length;
                          buttonIndex++) {
                        _isSelected[buttonIndex] =
                            buttonIndex == index ? true : false;
                      }
                    });
                    setDocs();
                  },
                  isSelected: _isSelected,
                  children: List.generate(
                      Level.l.length, (index) => Level.levelWidget(index)),
                ),
              ),

              // 日记主体
              Expanded(
                child: IndexedStack(index: viewType, children: [
                  // 卡片模式
                  ListView.builder(
                      itemCount: _ditems.length,
                      itemBuilder: (context, index) {
                        final item = _ditems[index];
                        return InkWell(
                          // 点击 卡片
                          onTap: () => clickCard(index),
                          child: Card(
                            // 阴影大小
                            elevation: 5,
                            // 圆角
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            // 外边距
                            margin: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            child: Padding(
                              padding: EdgeInsets.all(16.0), // 内边距
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // 确保Card包裹内容
                                // 内容左对齐
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // 日记标题
                                  Visibility(
                                    visible: item.title.isNotEmpty ||
                                        (item.title.isEmpty &&
                                            !Setting().isVisualNoneTitle),
                                    child: ListTile(
                                      title: Text(item.title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),

                                  // 日记具体内容
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      item.content,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      item.getCreateTime(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(
                                              Colors.grey.shade600.value)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  Timeline.tileBuilder(
                    builder: TimelineTileBuilder.fromStyle(
                      contentsAlign: ContentsAlign.alternating,
                      contentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Timeline Event $index'),
                      ),
                      itemCount: 5,
                    ),
                  ),
                  // 线性模式
                  // CustomPaint(
                  //   size: Size(300, 200),
                  //   painter: LineChartPainter([10, 25, 15, 30, 5]),
                  // ),
                  Text("日历模式"),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  setDocs() async {
    final ret = await Http(gid: _gitems[gidx].id).getDocs();
    final curLevel = getSelectLevel();
    setState(() {
      if (_ditems.isNotEmpty) {
        _ditems.clear();
      }
      if (isNoSelectLevel()) {
        _ditems = ret.data;
        return;
      }

      for (Doc doc in ret.data) {
        if (doc.level == curLevel) {
          _ditems.add(doc);
        }
      }
    });
  }

  bool isNoSelectLevel() {
    for (bool one in _isSelected) {
      if (one) {
        return false;
      }
    }
    return true;
  }

  int getSelectLevel() {
    for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
      if (_isSelected[buttonIndex]) {
        return buttonIndex;
      }
    }
    return 0;
  }

  clickNewEdit() async {
    Group item = _gitems[gidx];
    final LastPageDoc ret = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocEditPage(
          gid: item.id,
          id: "",
          title: "",
          content: "",
          level: getSelectLevel(),
          crtimeStr: "",
          uptimeStr: "",
        ),
      ),
    );

    switch (ret.state) {
      case LastPage.create:
        setState(() {
          _ditems.add(Doc(
              title: ret.title,
              content: ret.content,
              level: ret.level,
              crtimeStr: ret.crtimeStr,
              uptimeStr: ret.uptimeStr,
              id: ret.id));
        });
        break;
      case LastPage.nocreate:
        return;
      default:
        return;
    }
  }

  clickCard(int index) async {
    Group group = _gitems[gidx];
    Doc doc = _ditems[index];
    final LastPageDoc ret = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (con) => DocEditPage(
            gid: group.id,
            gname: group.name,
            title: doc.title,
            content: doc.content,
            id: doc.id,
            level: doc.level,
            uptimeStr: doc.uptimeStr,
            crtimeStr: doc.crtimeStr,
          ),
        ));
    setState(() {
      switch (ret.state) {
        case LastPage.delete:
          _ditems.removeAt(index);
          break;
        case LastPage.change:
          if (currentLevel != ret.level) {
            _ditems.removeAt(index);
            break;
          }
          if (doc.content != ret.content) {
            doc.content = ret.content;
          }
          if (doc.title != ret.title) {
            doc.title = ret.title;
          }
          if (doc.crtimeStr != ret.crtimeStr) {
            doc.crtimeStr = ret.crtimeStr;
          }
          break;
        default:
          doc.content = ret.content;
          doc.title = ret.title;
          doc.crtimeStr = ret.crtimeStr;

          break;
      }
    });
  }

  getGroupList() async {
    print("获取分组列表");

    final res = await Http(tid: widget.tid).getGroup();
    setState(() {
      _ditems.clear();

      if (res.data.isEmpty) {
        return;
      }
      _gitems = res.data
          .map((l) => Group(name: l.name, id: l.id, isSubmitted: true))
          .toList();

      pageTitleName = "${widget.themename}-${res.data[gidx].name}";
    });
  }

  // 左侧抽屉菜单 - 分组列表 - 点击分组
  clickGroupTitle(int index) {
    setState(() {
      gidx = index;
      pageTitleName = "${widget.themename}-${_gitems[gidx].name}";
    });

    Navigator.pop(context); // 关闭 drawer
    setDocs();
  }

  // 左侧抽屉菜单 - 分组列表 - 编辑按钮
  editLineGroup(Group item) {
    setState(() {
      item.isSubmitted = false;
    });
  }

  // 左侧抽屉菜单 - 分组列表 - 删除按钮
  deleteLineGroup(int index) async {
    var onValue = await Http(gid: _gitems[index].id).deleteGroup();
    if (onValue.err == 0) {
      setState(() {
        _gitems.removeAt(index);
      });
    }

    // 如果删除的分组不是当前选择的分组
    if (gidx != index) {
      return;
    }
    setState(() {
      pageTitleName = widget.themename;
      _ditems.clear();
    });
  }

  // 左侧抽屉菜单 - 添加分组 - 提交按钮
  submitEditGroup(Group item) async {
    if (item.id.isEmpty) {
      addGroup(item);
    } else {
      modGroup(item);
    }
  }

  // 左侧抽屉菜单 - 添加分组 - 取消按钮
  cancelEditGroup(int index) async {
    if (_gitems[index].id == "") {
      setState(() {
        _gitems.removeAt(index);
      });
    }
  }

  addGroup(Group item) async {
    print("创建分组");
    final inputName = item._textEditingController.text;
    final res = await Http(tid: widget.tid)
        .postGroup(RequestPostGroup(name: inputName));
    if (res.err != 0) {
      return;
    }
    setState(() {
      item.name = inputName;
      item.id = res.id;
      item.isSubmitted = true;
    });
  }

  modGroup(Group item) async {
    print("修改分组");
    final inputName = item._textEditingController.text;
    final stateName = item.name;
    if (inputName == stateName) {
      setState(() {
        item.isSubmitted = false;
      });
    }
    if (inputName == "") {
      return;
    }
    final res = await Http(tid: widget.tid)
        .putGroup(RequestPutGroup(name: inputName, id: item.id));
    if (res.err != 0) {
      return;
    }
    setState(() {
      item.name = inputName;
      item.isSubmitted = true;
    });
  }
}

// 提取成独立的 Widget
class BottomActionButtons extends StatelessWidget {
  final VoidCallback onAddPressed;

  const BottomActionButtons({
    Key? key,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.add), // 使用 const
          onPressed: onAddPressed,
        ),
      ],
    );
  }
}
