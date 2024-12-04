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
  List<Group> _gitems = [];
  List<Doc> _ditems = [];
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
      appBar: AppBar(title: Text(pageTitleName!)),

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
                                    editLine(_gitems[index]),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.blue,
                                icon: Icons.edit,
                                label: '编辑',
                              ),
                              SlidableAction(
                                onPressed: (context) => removeLine(index),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.red,
                                icon: Icons.delete,
                                label: '删除',
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(item.name),
                            onTap: () {
                              Navigator.pop(context); // 关闭 drawer
                              setDocs(item);
                              setState(() {
                                pageTitleName =
                                    "${widget.themename}-${item.name}";
                              });
                            },
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
                            onPressed: () => submitItem(_gitems[index]),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_rounded),
                            onPressed: () => removeItem(index),
                            // onPressed: () => remove(_gitems[index])),
                          )
                        ]));
            },
          )),
          BottomActionButtons(onAddPressed: () {
            setState(() {
              _gitems.add(Group(name: "", id: "", isSubmitted: false));
            });
          }, onSearchPressed: () {
            for (Group l in _gitems) {
              print(l.name);
            }
          }),
        ]),
      ),

      // 主体内容
      body: SafeArea(
        // 使用 SafeArea 避免内容被遮挡
        child: ListView.builder(
            itemCount: _ditems.length,
            itemBuilder: (context, index) {
              final item = _ditems[index];
              return InkWell(
                // 点击 卡片
                onTap: () => clickCard(gidx, index),
                child: Card(
                  // 阴影大小
                  elevation: 5,
                  // 圆角
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  // 外边距
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }

  clickCard(int gidx, int didx) async {
    Group group = _gitems[gidx];
    Doc doc = _ditems[didx];
    final LastPageDoc ret = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (con) => EEdit(
            gid: group.id,
            gname: group.name,
            title: doc.title,
            content: doc.content,
            id: doc.id,
          ),
        ));
    setState(() {
      if (ret.state == LastPage.delete) {
        _ditems.removeAt(didx);
      } else {
        _ditems[didx].content = ret.content;
        _ditems[didx].title = ret.title;
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

  Future<List<Doc>> getDocs(String gid) async {
    print("获取分组的日志列表");
    return await Http(gid: gid).getDocs();
  }

  setDocs(Group item) async {
    final ret = await getDocs(item.id);

    setState(() {
      if (_ditems.isNotEmpty) {
        _ditems.clear();
      }
      _ditems = ret;
    });
  }

  clickGroupTitle(Group item) {
    setState(() {
      pageTitleName = "${widget.themename}-${item.name}";
    });
    Navigator.pop(context); // 关闭 drawer
  }

  editLine(Group item) {
    setState(() {
      item.isSubmitted = false;
    });
  }

  removeLine(int index) async {
    var onValue = await Http(gid: _gitems[index].id).deleteGroup();
    if (onValue.err == 0) {
      setState(() {
        _gitems.removeAt(index);
      });
    }
  }

  submitItem(Group item) async {
    if (item.id.isEmpty) {
      addItem(item);
    } else {
      modItem(item);
    }
  }

  removeItem(int index) async {
    if (_gitems[index].id == "") {
      setState(() {
        _gitems.removeAt(index);
      });
    }
  }

  addItem(Group item) async {
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

  modItem(Group item) async {
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
  final VoidCallback onSearchPressed;

  const BottomActionButtons({
    Key? key,
    required this.onAddPressed,
    required this.onSearchPressed,
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
        IconButton(
          icon: const Icon(Icons.search), // 使用 const
          onPressed: onSearchPressed,
        ),
      ],
    );
  }
}
