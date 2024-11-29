import 'package:flutter/material.dart';
import 'edit.dart';
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

class ListPage extends StatefulWidget {
  final String? id;
  final String tid;
  final String themename;

  ListPage({required this.themename, required this.tid, this.id});

  @override
  State<StatefulWidget> createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  List<Group> _items = [];
  late String pageTitleName;

  @override
  void initState() {
    super.initState();
    pageTitleName = widget.themename;
    getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitleName)),
      
      drawer: Drawer(
        child: Column(children: [
          Expanded(
              child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 10.0, bottom: 0.0),
                  child: item.isSubmitted
                      ? Slidable(
                          key: ValueKey(item.id), // 每个 ListTile 需要一个唯一的 Key
                          endActionPane: ActionPane(
                            motion: ScrollMotion(), // 滑动动画效果
                            children: [
                              SlidableAction(
                                onPressed: (context) => editLine(_items[index]),
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
                              setState(() {
                                pageTitleName =
                                    "${widget.themename}-${item.name}";
                              });
                            },
                          ))
                      : Row(children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: '组名',
                              ),
                              controller: _items[index]._textEditingController,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () => submitItem(_items[index]),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_rounded),
                            onPressed: () => removeItem(index),
                            // onPressed: () => remove(_items[index])),
                          )
                        ]));
            },
          )),
          BottomActionButtons(onAddPressed: () {
            setState(() {
              _items.add(Group(name: "", id: "", isSubmitted: false));
            });
          }, onSearchPressed: () {
            for (Group l in _items) {
              print(l.name);
            }
          }),
        ]),
      ),
      body: SafeArea(
        // 使用 SafeArea 避免内容被遮挡
        child: Column(
          children: [
            Expanded(
              // 使用 Expanded 占据剩余空间
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EEdit(tid: widget.tid),
                      ),
                    );
                  },
                  child: const Text('来记录心路历程吧！'), // 使用 const
                ),
              ),
            ),
            const SizedBox(height: 40.0), // 使用 SizedBox 添加 padding
          ],
        ),
      ),
    );
  }

  editLine(Group item) {
    setState(() {
      item.isSubmitted = false;
    });
  }

  removeLine(int index) async {
    var onValue = await Http(gid: _items[index].id).deletegroup();
    if (onValue.err == 0) {
      setState(() {
        _items.removeAt(index);
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
    if (_items[index].id == "") {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  addItem(Group item) async {
    print("创建分组");
    final inputName = item._textEditingController.text;
    final res = await Http(tid: widget.tid)
        .postgroup(RequestPostGroup(name: inputName));
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
        .putgroup(RequestPutGroup(name: inputName, id: item.id));
    if (res.err != 0) {
      return;
    }
    setState(() {
      item.name = inputName;
      item.isSubmitted = true;
    });
  }

  getGroupList() async {
    print("获取分组列表");

    final groupList = await Http(tid: widget.tid).getgroup();
    setState(() {
      _items = groupList
          .map((l) => Group(name: l.name, id: l.id, isSubmitted: true))
          .toList();
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
