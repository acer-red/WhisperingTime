import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'doc/edit.dart';
import 'package:whispering_time/http.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Group {
  String name;
  String id;
  bool isSubmitted;
  TextEditingController _textEditingController = TextEditingController();
  Group({required this.name, required this.id, required this.isSubmitted})
      : _textEditingController = TextEditingController(text: name);
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

  int gidx = 0;
  String? pageTitleName;

  @override
  void initState() {
    super.initState();
    pageTitleName = widget.themename;
    getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 页面
      appBar: AppBar(
        title: Text(pageTitleName!),
        // leading: IconButton(
        //   icon: Icon(Icons.menu),
        //   onPressed: () {
        //     Scaffold.of(context).openDrawer();
        //   },
        // ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.settings),
        //     onPressed: () {
        //       Scaffold.of(context).openEndDrawer();
        //     },
        //   ),
        // ],
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

      // 右侧设置
      // endDrawer: Drawer(
      //   child: ListView(
      //     children: [
      //       ListTile(
      //         title: Text("右侧抽屉项 1"),
      //       ),
      //       ListTile(
      //         title: Text("右侧抽屉项 2"),
      //       ),
      //     ],
      //   ),
      // ),

      // 主体内容
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // 分级
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
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
              const SizedBox(height: 20),
              // 日记主题
              Expanded(
                child: ListView.builder(
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
                                ListTile(
                                  title: Text(item.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                // 日记具体内容
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    item.content,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: clickNewEdit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Doc>> getDocs(String gid) async {
    print("获取分组的日志列表");
    return await Http(gid: gid).getDocs();
  }

  setDocs() async {
    final ret = await getDocs(_gitems[gidx].id);
    final curLevel = getSelectLevel();
    setState(() {
      if (_ditems.isNotEmpty) {
        _ditems.clear();
      }
      if (isNoSelectLevel()) {
        print("没选择");
        _ditems = ret;
        return;
      }
      print("当前选择$curLevel");

      for (Doc doc in ret) {
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
          ),
        ));
    setState(() {
      if (ret.state == LastPage.delete) {
        _ditems.removeAt(index);
      } else {
        _ditems[index].content = ret.content;
        _ditems[index].title = ret.title;
      }
    });
  }

  getGroupList() async {
    print("获取分组列表");

    final groupList = await Http(tid: widget.tid).getGroup();
    setState(() {
      _gitems = groupList
          .map((l) => Group(name: l.name, id: l.id, isSubmitted: true))
          .toList();
      if (_gitems.isEmpty) {
        return;
      }
      _ditems.clear();
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
