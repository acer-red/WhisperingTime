import 'package:flutter/material.dart';
import 'package:whispering_time/env.dart';
import 'doc/edit.dart';
import 'package:whispering_time/http.dart';
import 'package:timelines/timelines.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class Group {
  String name;
  String id;
  DateTime overtime;

  Group({required this.name, required this.id, required this.overtime});

  // 判断当前时间是否在overtime的之内
  bool isBufTime() {
    DateTime now = DateTime.now();
    return now.isAfter(overtime) &&
        now.isBefore(overtime.add(Time.getOverTime()));
  }

  // 判断当前时间是否在overtime之后
  bool isEnterOverTime() {
    return DateTime.now().isAfter(overtime);
  }

  // 判断当前时间是否在overtime之前
  bool isNotEnterOverTime() {
    DateTime oneDayBefore = overtime.subtract(Time.getOverTime());
    return DateTime.now().isBefore(oneDayBefore);
  }

  int getOverTimeStatus() {
    // 顺序不能修改
    if (isNotEnterOverTime()) {
      return 0;
    }
    if (isBufTime()) {
      return 1;
    }
    return 2;
  }

  bool isFreezed() {
    return getOverTimeStatus() != 0;
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
  int viewType = 0;
  bool isGrouTitleSubmitted = true;

  TextEditingController groupTitleEdit = TextEditingController();

  @override
  void initState() {
    super.initState();
    getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // 页面标题栏
      appBar: AppBar(
        // 标题左侧的按钮
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        // 标题
        title: MouseRegion(
          onExit: (_) => submitEditGroup(_gitems[gidx]),
          child: TextField(
            style: TextStyle(fontSize: 23),
            textAlign: TextAlign.center, // 添加这行
            controller: groupTitleEdit,
            maxLines: 1,
            autofocus: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            onSubmitted: (text) => submitEditGroup(_gitems[gidx]),
            onEditingComplete: () {
              setState(() {
                submitEditGroup(_gitems[gidx]);
              });
            },
          ),
        ),

        // 标题右侧的按钮
        actions: [
          // 打开分组列表
          IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(Icons.format_list_bulleted)),

          // 切换分组视图
          IconButton(
              onPressed: () => {
                    setState(() {
                      viewType++;
                      if (viewExplain.length == viewType) {
                        viewType = 0;
                      }
                    })
                  },
              icon: Icon(Icons.view_carousel_outlined)),
          IconButton(onPressed: () => exportGroup(), icon: Icon(Icons.share)),
          // 打开分组设置
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  final Group item = _gitems[gidx];
                  int status = item.getOverTimeStatus();
                  bool isFreezed = item.isNotEnterOverTime() ? false : true;

                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          IndexedStack(
                            index: status,
                            children: [
                              SwitchListTile(
                                title: const Text('定格'),
                                subtitle: Text(
                                    "定格后，本篇分组将无法编辑印迹，无法取消操作，只能回顾。定格后有1天缓冲期，用以取消。"),
                                value: isFreezed,
                                onChanged: (bool value) async {
                                  bool ok = await setFreezeOverTime(gidx);
                                  if (!ok) {
                                    return;
                                  }
                                  if (mounted) {
                                    setState(() {
                                      (context as Element).markNeedsBuild();

                                      isFreezed = true;
                                      status = 1;
                                    });
                                  }
                                },
                              ),
                              SwitchListTile(
                                title: const Text('定格'),
                                subtitle: Text(
                                    "进入缓冲期,定格时间:${item.overtime.toString()}"),
                                value: isFreezed,
                                onChanged: (bool value) async {
                                  bool ok = await setForverOverTime(gidx);
                                  if (!ok) {
                                    return;
                                  }
                                  if (mounted) {
                                    setState(() {
                                      (context as Element).markNeedsBuild();
                                      isFreezed = false;
                                      status = 0;
                                    });
                                  }
                                },
                              ),
                              SwitchListTile(
                                  title: const Text('定格'),
                                  subtitle:
                                      Text("已定格于${item.overtime.toString()}"),
                                  value: true,
                                  onChanged: null),
                            ],
                          ),
                          divider(),
                          ElevatedButton(
                            onPressed: () => deleteLineGroup(gidx),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Colors.red.shade900), // 设置红色背景
                              minimumSize: WidgetStateProperty.all(
                                  Size(200, 60)), // 设置按钮大小为 200x60
                            ),
                            child: Text(
                              "删除 ${_gitems[gidx].name}",
                              style: TextStyle(
                                  color: Color(Colors.white.value),
                                  fontSize: 17),
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('关闭'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              )
            },
          ),
        ],
      ),

      // 右下角悬浮按钮
      floatingActionButton: FloatingActionButton(
        onPressed: clickNewEdit,
        child: const Icon(Icons.add),
      ),

      // 左侧抽屉 分组列表
      drawer: Drawer(
        child: Column(children: [
          // 分组列表内容
          Expanded(
              child: ListView.builder(
            itemCount: _gitems.length,
            itemBuilder: (context, index) {
              final item = _gitems[index];
              return Padding(
                  padding: EdgeInsets.only(
                      left: 0.0, right: 00.0, top: 10.0, bottom: 0.0),
                  child: ListTile(
                    title: Text(item.name),
                    onTap: () => clickGroupTitle(index),
                  ));
            },
          )),
          // 底部按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.add), // 使用 const
                onPressed: () {
                  setState(() {
                    _gitems.add(
                        Group(name: "", id: "", overtime: Time.getNextDay()));
                  });
                },
              ),
            ],
          ),
        ]),
      ),
      // 主体内容
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // 印迹 分级按钮
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      _isSelected[index] = !_isSelected[index];

                      // for (int buttonIndex = 0;
                      //     buttonIndex < _isSelected.length;
                      //     buttonIndex++) {
                      //   _isSelected[buttonIndex] =
                      //       buttonIndex == index ? true : false;
                      // }
                    });
                    setDocs();
                  },
                  isSelected: _isSelected,
                  children: List.generate(
                      Level.l.length, (index) => Level.levelWidget(index)),
                ),
              ),

              // 印迹主体
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
                                  Center(
                                    child: Text(
                                      Level.l[item.level],
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(
                                              Colors.grey.shade600.value)),
                                    ),
                                  ),

                                  // 印迹标题
                                  Visibility(
                                    visible: item.title.isNotEmpty ||
                                        (item.title.isEmpty &&
                                            !Settings().getVisualNoneTitle()),
                                    child: ListTile(
                                      title: Text(item.title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),

                                  // 印迹具体内容
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

                  // 时间轴模式
                  Timeline.tileBuilder(
                    builder: TimelineTileBuilder.fromStyle(
                      contentsAlign: ContentsAlign.alternating,
                      contentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: TextButton(
                          child: Text('Timeline Event $index'),
                          onPressed: () => {print('Timeline Event $index')},
                        ),
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
    setState(() {
      if (_ditems.isNotEmpty) {
        _ditems.clear();
      }
      if (isNoSelectLevel()) {
        _ditems.clear();
        return;
      }

      for (Doc doc in ret.data) {
        if (isContainSelectLevel(doc.level)) {
          _ditems.add(doc);
        }
      }
      _ditems.sort(compareDocs);
    });
  }

  int compareDocs(Doc a, Doc b) {
    DateTime aTime = a.crtime ?? DateTime.fromMillisecondsSinceEpoch(0);
    DateTime bTime = b.crtime ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aTime.compareTo(bTime);
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

  bool isContainSelectLevel(int i) {
    return _isSelected[i];
  }

  clickNewEdit() async {
    Group item = _gitems[gidx];
    if (item.isFreezed()) {
      return;
    }
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
          freeze: false,
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
            freeze: _gitems[gidx].isFreezed(),
          ),
        ));
    setState(() {
      switch (ret.state) {
        case LastPage.delete:
          _ditems.removeAt(index);
          break;
        case LastPage.change:
          if (!isContainSelectLevel(ret.level)) {
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
            _ditems[index].crtimeStr = ret.crtimeStr;
            _ditems[index].crtime = Time.datetime(ret.crtimeStr);
            _ditems.sort(compareDocs);
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

  Future<bool> setFreezeOverTime(int index) async {
    Group item = _gitems[index];
    final req = RequestPutGroup(id: item.id, overtime: Time.getNextDay());
    final res = await Http(tid: widget.tid).putGroup(req);

    if (res.err == 0) {
      _gitems[index].overtime = req.overtime!;
      return true;
    }
    return false;
  }

  Future<bool> setForverOverTime(int index) async {
    Group item = _gitems[index];
    final req = RequestPutGroup(id: item.id, overtime: Time.getForver());
    final res = await Http(tid: widget.tid).putGroup(req);

    if (res.err == 0) {
      _gitems[index].overtime = req.overtime!;
      return true;
    }
    return false;
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
          .map((l) => Group(name: l.name, id: l.id, overtime: l.overtime))
          .toList();

      groupTitleEdit.text = res.data[gidx].name;
    });
    setDocs();
  }

  // 左侧抽屉菜单 - 分组列表 - 点击分组
  clickGroupTitle(int index) {
    setState(() {
      gidx = index;
      groupTitleEdit.text = _gitems[gidx].name;
    });

    Navigator.pop(context); // 关闭 drawer
    setDocs();
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
      groupTitleEdit.text = widget.themename;
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

  addGroup(Group item) async {
    print("创建分组");
    final inputName = groupTitleEdit.text;
    final res = await Http(tid: widget.tid)
        .postGroup(RequestPostGroup(name: inputName));
    if (res.err != 0) {
      return;
    }
    setState(() {
      item.name = inputName;
      item.id = res.id;
    });
  }

  modGroup(Group item) async {
    final inputName = groupTitleEdit.text;
    final stateName = item.name;
    if (inputName == stateName) {
      return;
    }
    if (inputName == "") {
      return;
    }
    print("修改分组");

    final res = await Http(tid: widget.tid)
        .putGroup(RequestPutGroup(name: inputName, id: item.id));
    if (res.err != 0) {
      return;
    }
    setState(() {
      _gitems[gidx].name = inputName;
    });
  }

  void exportGroup() async {
    int ret = await showExportOption();
    switch (ret) {
      case 0:
        exportDesktopTXT();
        break;
      default:
        break;
    }
  }

  Future<void> exportDesktopTXT() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    // 用户取消了操作
    if (selectedDirectory == null) {
      return;
    }

    Directory directory = Directory(selectedDirectory);
    print('选择的文件夹路径：${directory.path}');

    final ret = await Http(gid: _gitems[gidx].id).getDocs();

    if (ret.err != 0) {
      print(ret);
      return;
    }
    // 遍历文件列表并写入
    for (Doc item in ret.data) {
      final String fileName = item.title.isEmpty
          ? item.crtime.toString()
          : "${item.title} - ${Time.string(item.crtime!)}" ".txt";
      final String filePath = '$selectedDirectory/$fileName';

      // 创建并写入文件
      File file = File(filePath);
      await file.writeAsString(item.content);
      print('文件已写入: $filePath');
    }
  }

  Future<int> showExportOption() async {
    int? ret = await showDialog<int>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("导出${_gitems[gidx].name}"),
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
