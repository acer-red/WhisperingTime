import 'package:flutter/material.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/pages/theme/doc/setting.dart';
import '../doc/edit.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/services/isar/config.dart';

class Group {
  String name;
  String id;
  DateTime overtime;
  GroupConfig config;

  Group(
      {required this.name,
      required this.id,
      required this.overtime,
      required this.config});

  // 判断当前时间是否在overtime的之内
  bool isBufTime() {
    DateTime now = DateTime.now();
    return now.isBefore(overtime) &&
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

  bool isFreezedOrBuf() {
    return getOverTimeStatus() != 0;
  }
}

class GroupPage extends StatefulWidget {
  final String? id;
  final String tid;
  final String themename;
  GroupPage({required this.themename, required this.tid, this.id});

  @override
  State<StatefulWidget> createState() => _GroupPage();
}

class _GroupPage extends State<GroupPage> {
  List<Group> _gitems = [
    Group(
        name: "",
        id: "",
        overtime: DateTime.now(),
        config: GroupConfig(
            isAll: false,
            isMulti: false,
            levels: [true, false, false, false, false],
            viewType: 0))
  ];
  List<Doc> _ditems = <Doc>[];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int gidx = 0;
  bool isGrouTitleSubmitted = true;
  DateTime pickedDate = DateTime.now();
  int pageIndex = 0;


  @override
  void initState() {
    super.initState();
    getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // 顶部 页面标题栏
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
              _gitems.isEmpty ? Text("") : Text(_gitems[gidx].name),
              IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  icon: Icon(Icons.arrow_drop_down)),
            ],
          ),

          // 标题右侧的按钮
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: Text('重命名'),
                  onTap: () {
                    dialogRename();
                  },
                ),
                PopupMenuItem(
                  child: Text('导出'),
                  onTap: () {
                    dialogExport();
                  },
                ),
                PopupMenuItem(
                  onTap: () => dialogWidget(ViewSetting(
                    tid: widget.tid,
                    gid: _gitems[gidx].id,
                    viewType: _gitems[gidx].config.viewType,
                    pageIndex: pageIndex,
                    isAll: _gitems[gidx].config.isAll,
                    onAllChooseChanged: (value) {
                      setState(() {
                        _gitems[gidx].config.isAll = value;
                      });
                    },
                    onPageChanged: (value) {
                      setState(() {
                        pageIndex = value;
                      });
                    },
                    onViewTypeChanged: (value) {
                      setState(() {
                        _gitems[gidx].config.viewType = value;
                      });
                    },
                    isSelected: _gitems[gidx].config.levels,
                    isMulti: _gitems[gidx].config.isMulti,
                    onLevelChanged: (value) {
                      setState(() {
                        clickLevel(value);
                      });
                    },
                    onModeChanged: (value) {
                      setState(() {
                        _gitems[gidx].config.isMulti = value;
                      });
                    },
                  )),
                  child: const Text("显式设置"),
                ),
                PopupMenuItem(
                  child: Text('其他设置'),
                  onTap: () {
                    dialogSetting();
                  },
                ),
              ],
            ),
          ]),

      // 左侧 分组列表
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
                icon: const Icon(Icons.add),
                onPressed: () {
                  dialogAddGroup();
                },
              ),
            ],
          ),
        ]),
      ),

      // 右下 悬浮按钮 - 添加印迹
      floatingActionButton: FloatingActionButton(
        onPressed: enterDocBlank,
        child: Icon(Icons.add),
      ),

      // 中间 主体内容
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // 印迹主体
              Expanded(
                child: IndexedStack(
                    index: _gitems[gidx].config.viewType,
                    children: [
                      screenCard(),
                      screenCalendar(),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI: 主体内容-卡片模式
  Widget screenCard() {
    return ListView.builder(
        itemCount: _ditems.length,
        itemBuilder: (context, index) {
          final item = _ditems[index];
          return InkWell(
            onTap: () => enterDoc(index),
            child: Card(
              // 阴影大小
              elevation: 5,
              // 圆角
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              // 外边距
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              // 内容
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
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),

                    // 印迹标题
                    Visibility(
                      visible: item.title.isNotEmpty ||
                          (item.title.isEmpty &&
                              Config.instance.visualNoneTitle),
                      child: ListTile(
                        title: Text(item.title,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    // 印迹具体内容
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        item.plainText.trimRight(),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),

                    // 创建时间
                    Center(
                      child: Text(
                        Time.string(item.crtime),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  // UI: 主体内容-日历模式
  Widget screenCalendar() {
    DateTime currentDate = DateTime.now();

    // 获取当月的天数
    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    // 获取当月的第一天是星期几 (星期一为1，星期天为7)
    int firstWeekdayOfMonth =
        DateTime(currentDate.year, currentDate.month, 1).weekday;

    // 计算需要多少行来显示整个月的日历
    // +1 表示新增一行，用来放星期
    int totalRows = ((daysInMonth + firstWeekdayOfMonth - 1) / 7).ceil();
    int totalitems = totalRows * 7;

    String getWeekString(int index) {
      switch (index) {
        case 0:
          return "周一";
        case 1:
          return "周二";
        case 2:
          return "周三";
        case 3:
          return "周四";
        case 4:
          return "周五";
        case 5:
          return "周六";
        default:
          return "周日";
      }
    }

    chooseDate() async {
      DateTime? d = await Time.datePacker(context);
      if (d == null) {
        return;
      }

      setState(() {
        pickedDate = d;
      });
      getDocs(year: pickedDate.year, month: pickedDate.month);
    }

    Widget dateTitle() {
      return TextButton(
          onPressed: () => chooseDate(),
          child: Text(DateFormat('yyyy MMMM').format(pickedDate)));
    }

    Widget grid(bool istoday, int dayNumber, int i) {
      return GestureDetector(
        onTap: () => enterDoc(i),
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 让 Column 垂直方向大小包裹内容
              crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中对齐
              children: <Widget>[
                Text(
                  "$dayNumber",
                  style: TextStyle(
                      fontSize: 18,
                      color: istoday ? Colors.blue : Colors.black,
                      fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
                ),
                Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget gridNoFlag(bool istoday, int dayNumber) {
      return GestureDetector(
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 让 Column 垂直方向大小包裹内容
              crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中对齐
              children: <Widget>[
                Text(
                  "$dayNumber",
                  style: TextStyle(
                      fontSize: 18,
                      color: istoday ? Colors.blue : Colors.black,
                      fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          children: [
            // 当前日期
            dateTitle(),
            // 星期
            SizedBox(
              height: 60,
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7列，代表一周的7天
                    childAspectRatio: 2.0, // 单元格宽高比
                  ),
                  // 总的单元格数量
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    // 构建 星期
                    return Align(
                        alignment: Alignment.center,
                        child: Text(getWeekString(index)));
                  }),
            ),
            // 数字日期
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7列，代表一周的7天
                  childAspectRatio: 1.0, // 单元格宽高比
                ),
                // 总的单元格数量
                itemCount: totalitems,
                itemBuilder: (context, index) {
                  // 计算当前单元格对应的日期
                  int dayNumber = index - firstWeekdayOfMonth + 2;

                  // 如果dayNumber在有效日期范围内，显示日期；否则显示空单元格
                  if (!(dayNumber > 0 && dayNumber <= daysInMonth)) {
                    return Container(); // 空单元格
                  }
                  bool istoday = dayNumber == DateTime.now().day &&
                      pickedDate.month == DateTime.now().month &&
                      pickedDate.year == DateTime.now().year;

                  for (int i = 0; i < _ditems.length; i++) {
                    if (index - firstWeekdayOfMonth + 2 ==
                        _ditems[i].crtime.day) {
                      return grid(istoday, dayNumber, i);
                    }
                  }
                  return gridNoFlag(istoday, dayNumber);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 弹窗样式设置
  dialogWidget(Widget widget) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }

  /// 窗口: 设置
  dialogSetting() async {
    if (_gitems.isEmpty) {
      return;
    }
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
                    // 未定格，未进入缓冲期
                    SwitchListTile(
                      title: const Text('定格'),
                      subtitle:
                          Text("定格后，本篇分组将无法编辑印迹，无法取消操作，只能回顾。定格后有7天缓冲期，用以取消。"),
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
                    // 未定格，进入缓冲期
                    SwitchListTile(
                      title: const Text('定格'),
                      subtitle: Text("进入缓冲期,定格时间:${item.overtime.toString()}"),
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
                    // 已定格
                    SwitchListTile(
                        title: const Text('定格'),
                        subtitle: Text("已定格于${item.overtime.toString()}"),
                        value: true,
                        onChanged: null),
                  ],
                ),
                divider(),
                ElevatedButton(
                  onPressed: () => clickDeleteGroup(gidx),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.red.shade900),
                    minimumSize: WidgetStateProperty.all(Size(200, 60)),
                  ),
                  child: Text(
                    "删除 ${_gitems[gidx].name}",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// 窗口: 导出
  dialogExport() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Export(ResourceType.group,
            title: "导出当前分组", tid: widget.tid, gid: _gitems[gidx].id);
      },
    );
  }

  /// 窗口: 重命名
  dialogRename() async {
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
            decoration: InputDecoration(hintText: _gitems[gidx].name),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
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

    final res = await Http(tid: widget.tid, gid: _gitems[gidx].id)
        .putGroup(RequestPutGroup(name: result!));

    if (res.isNotOK) {
      return;
    }

    setState(() {
      _gitems[gidx].name = result!;
    });
  }

  /// 窗口: 添加分组
  dialogAddGroup() async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("创建分组"),
          content: TextField(
            onChanged: (value) {
              result = value;
            },
            decoration: const InputDecoration(hintText: "请输入"),
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
      if (_gitems.isEmpty) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
      return;
    }
    if (result!.isEmpty) {
      return;
    }
    final req = RequestPostGroup(name: result!);
    final res = await Http(tid: widget.tid).postGroup(req);

    if (res.isNotOK) {
      return;
    }

    setState(() {
      _gitems.add(Group(
          name: result!,
          id: res.id,
          overtime: req.overtime,
          config: GroupConfig.getDefault()));
      gidx = _gitems.length - 1;
      _ditems.clear();
      for (int i = 0; i < _gitems[gidx].config.levels.length; i++) {
        if (_gitems[gidx].config.levels[i]) {
          _gitems[gidx].config.levels[i] = false;
        }
      }
    });
  }

  /// 点击新增按钮，进入空白印迹的编辑页面
  enterDocBlank() async {
    Group item = _gitems[gidx];

    if (item.isFreezedOrBuf()) {
      Msg.diy(context, "已定格或已进入定格缓冲期，无法编辑");
      return;
    }
    final LastStateDoc ret = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocEditPage(
          gid: item.id,
          title: "",
          content: "",
          level: getSelectLevel(),
          config: DocConfigration(isShowTool: Config.instance.defaultShowTool),
          crtime: DateTime.now(),
          uptime: DateTime.now(),
          freeze: false,
        ),
      ),
    );

    switch (ret.state) {
      case LastState.create:
        if (!isContainSelectLevel(ret.level)) {
          break;
        }
        setState(() {
          _ditems.add(Doc(
              title: ret.title,
              content: ret.content,
              plainText: ret.plainText,
              level: ret.level,
              crtime: ret.crtime,
              uptime: ret.uptime,
              config: ret.config,
              id: ret.id));
        });
        break;
      case LastState.nocreate:
        return;
      default:
        return;
    }
  }

  /// 点击卡片按钮，进入印迹编辑页面
  enterDoc(int index) async {
    Group group = _gitems[gidx];
    Doc doc = _ditems[index];
    final LastStateDoc ret = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (con) => DocEditPage(
            gid: group.id,
            gname: group.name,
            title: doc.title,
            content: doc.content,
            id: doc.id,
            level: doc.level,
            config: doc.config,
            uptime: doc.uptime,
            crtime: doc.crtime,
            freeze: _gitems[gidx].isFreezedOrBuf(),
          ),
        ));
    setState(() {
      switch (ret.state) {
        case LastState.delete:
          _ditems.removeAt(index);
          break;
        case LastState.change:
          if (!isContainSelectLevel(ret.level)) {
            _ditems.removeAt(index);
            break;
          }
          if (doc.content != ret.content) {
            doc.content = ret.content;
            doc.plainText = ret.plainText;
          }
          if (doc.title != ret.title) {
            doc.title = ret.title;
          }
          if (doc.crtime != ret.crtime) {
            _ditems[index].crtime = ret.crtime;
            _ditems[index].crtime = ret.crtime;
            _ditems.sort(compareDocs);
          }
          if (ret.config.isShowTool != doc.config.isShowTool) {
            _ditems[index].config.isShowTool = ret.config.isShowTool;
          }
          break;
        case LastState.changeConfig:
          if (doc.crtime != ret.crtime) {
            _ditems[index].crtime = ret.crtime;
            _ditems[index].crtime = ret.crtime;
            _ditems.sort(compareDocs);
          }
          log.i(ret.config.isShowTool);
          if (ret.config.isShowTool != doc.config.isShowTool) {
            _ditems[index].config.isShowTool = ret.config.isShowTool;
          }
          break;
        default:
          doc.content = ret.content;
          doc.title = ret.title;
          doc.crtime = ret.crtime;

          break;
      }
    });
  }

  /// 点击分组按钮（在分组列表中），切换分组显示
  clickGroupTitle(int index) {
    setState(() {
      gidx = index;
      // groupTitleEdit.text = _gitems[gidx].name;
    });

    Navigator.pop(context); // 关闭 drawer
    getDocs();
  }

  /// 点击删除分组
  clickDeleteGroup(int index) async {
    if (_gitems.length == 1) {
      Msg.diy(context, "无法删除，请保留至少一个项目。");
      return;
    }

    if (!(await showConfirmationDialog(
        context, MyDialog(content: "是否删除？", title: "提示")))) {
      return;
    }

    final ret =
        await Http(tid: widget.tid, gid: _gitems[index].id).deleteGroup();
    if (ret.isNotOK) {
      return;
    }

    if (mounted) {
      setState(() {
        _gitems.removeAt(index);
        gidx = 0;
        getGroupList();
      });
      Navigator.of(context).pop();
    }
  }

  /// 点击分级按钮
  clickLevel(List<bool> value) {
    _gitems[gidx].config.levels = value;

    RequestPutGroup req = RequestPutGroup(
        config: GroupConfigNULL(levels: _gitems[gidx].config.levels));
    Http(tid: widget.tid, gid: _gitems[gidx].id).putGroup(req);

    switch (_gitems[gidx].config.viewType) {
      case 0:
        getDocs();
        break;
      case 1:
        getDocs(year: pickedDate.year, month: pickedDate.month);
        break;
    }
  }

  /// 更新当前分组下的印迹列表
  getDocs({int? year, int? month}) async {
    if (_gitems.isEmpty) {
      return;
    }
    final ret = await Http(gid: _gitems[gidx].id).getDocs(year, month);
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
    DateTime aTime = a.crtime;
    DateTime bTime = b.crtime;
    return aTime.compareTo(bTime);
  }

  bool isNoSelectLevel() {
    for (bool one in _gitems[gidx].config.levels) {
      if (one) {
        return false;
      }
    }
    return true;
  }

  int getSelectLevel() {
    for (int buttonIndex = 0;
        buttonIndex < _gitems[gidx].config.levels.length;
        buttonIndex++) {
      if (_gitems[gidx].config.levels[buttonIndex]) {
        return buttonIndex;
      }
    }
    return 0;
  }

  bool isContainSelectLevel(int i) {
    return _gitems[gidx].config.levels[i];
  }

  Future<bool> setFreezeOverTime(int index) async {
    final time = Time.getOverDay();
    final res = await Http(tid: widget.tid, gid: _gitems[gidx].id)
        .putGroup(RequestPutGroup(overtime: time));

    if (res.isNotOK) {
      return false;
    }
    _gitems[index].overtime = time;
    return true;
  }

  Future<bool> setForverOverTime(int index) async {
    final time = Time.getForver();

    final res = await Http(tid: widget.tid, gid: _gitems[gidx].id)
        .putGroup(RequestPutGroup(overtime: time));

    if (res.isNotOK) {
      return false;
    }
    _gitems[index].overtime = time;
    return true;
  }

  Future<void> getGroupList() async {
    final res = await Http(tid: widget.tid).getGroups();
    if (res.isNotOK) {
      if (mounted) {
        Msg.diy(context, "获取分组失败");
      }
      return;
    }
    if (res.data.isEmpty) {
      dialogAddGroup();
      return;
    }
    setState(() {
      _ditems.clear();
      _gitems = res.data
          .map((l) => Group(
              name: l.name, id: l.id, overtime: l.overtime, config: l.config))
          .toList();
      getDocs();
    });
  }
}

class ViewTypeDropDown extends StatefulWidget {
  final int value;
  final ValueChanged<int> onValueChanged; // 添加回调函数

  const ViewTypeDropDown(
      {super.key, required this.value, required this.onValueChanged});

  @override
  State<StatefulWidget> createState() => _ViewTypeDropDown();
}

class _ViewTypeDropDown extends State<ViewTypeDropDown> {
  late String _selectedValue;
  List<String> viewExplain = ["卡片", "日历"];

  @override
  void initState() {
    super.initState();
    _selectedValue = viewExplain[widget.value];
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text('请选择一个选项'),
      value: _selectedValue,
      onChanged: (String? newValue) {
        setState(() {
          _selectedValue = newValue!;
          widget.onValueChanged(viewExplain.indexOf(_selectedValue));
        });
      },
      items: viewExplain.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class ViewSetting extends StatefulWidget {
  final bool isMulti;
  final bool isAll;
  final List<bool> isSelected;
  final ValueChanged<List<bool>> onLevelChanged;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onViewTypeChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<bool> onAllChooseChanged;
  final int pageIndex;
  final int viewType;
  final String gid;
  final String tid;
  const ViewSetting({
    super.key,
    required this.isMulti,
    required this.isAll,
    required this.isSelected,
    required this.onLevelChanged,
    required this.onModeChanged,
    required this.onViewTypeChanged,
    required this.onAllChooseChanged,
    required this.onPageChanged,
    required this.pageIndex,
    required this.viewType,
    required this.gid,
    required this.tid,
  });

  @override
  State<ViewSetting> createState() => ViewSettingState();
}

class ViewSettingState extends State<ViewSetting> {
  List<bool> _isSelected = [true, false, false, false, false];
  List<bool> _isOldSelected = [true, false, false, false, false];
  bool isMulti = false;
  late bool isAll;
  late int viewType;
  late int pageIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
    isMulti = widget.isMulti;
    isAll = widget.isAll;
    viewType = widget.viewType;
    pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // 根据鼠标拖动的 delta.dx 值来更新 PageView 的滚动位置
        _pageController.position.moveTo(
          _pageController.position.pixels - details.delta.dx,
        );
      },
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
          widget.onPageChanged(index);
        },
        children: [ui("视图选择"), level("分级选择")],
      ),
    );
  }

  Widget ui(String title) {
    return Column(
      children: [
        // 标题
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 主体
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RadioGroup<int>(
                groupValue: viewType,
                onChanged: (int? value) {
                  setState(() {
                    viewType = value!;
                    widget.onViewTypeChanged(viewType);
                  });
                  Http(tid: widget.tid, gid: widget.gid).putGroup(
                      RequestPutGroup(
                          config: GroupConfigNULL(viewType: value)));
                },
                child: const Column(
                  children: [
                    RadioListTile<int>(
                      title: Text('卡片'),
                      value: 0,
                    ),
                    RadioListTile<int>(
                      title: Text('日历'),
                      value: 1,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget level(String title) {
    return Column(
      children: [
        // 标题
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 印迹 分级按钮
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ToggleButtons(
            isSelected: _isSelected,
            children: List.generate(
                Level.l.length, (index) => Level.levelWidget(index)),
            onPressed: (int index) {
              setState(() {
                if (isMulti) {
                  _isSelected[index] = !_isSelected[index];
                } else {
                  _isSelected =
                      List.generate(_isSelected.length, (i) => i == index);
                }
                _isOldSelected = _isSelected;
                widget.onLevelChanged(_isSelected);
              });
              // clickLevel();
            },
          ),
        ),
        // 分级选择
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text('默认/全选'),
                      subtitle: Text(!isAll ? '当前默认' : '当前全选'),
                      value: isAll,
                      onChanged: (bool value) async {
                        setState(() {
                          isAll = value;
                          if (isAll) {
                            isMulti = true;
                            widget.onModeChanged(isMulti);
                            _isSelected =
                                List.generate(_isSelected.length, (i) => true);
                          } else {
                            _isSelected = _isOldSelected;
                          }
                        });
                        widget.onAllChooseChanged(isAll);
                        widget.onLevelChanged(_isSelected);
                        RequestPutGroup req = RequestPutGroup(
                            config: GroupConfigNULL(
                                levels: _isSelected,
                                isMulti: isMulti,
                                isAll: isAll));
                        Http(tid: widget.tid, gid: widget.gid).putGroup(req);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text('单选/多选'),
                      subtitle: Text(
                          !isMulti ? '当前单选，分级选项只能选择一个' : '当前多选，分级选项能够选择多个'),
                      value: isMulti,
                      onChanged: (bool value) async {
                        setState(() {
                          isMulti = value;
                        });
                        RequestPutGroup req = RequestPutGroup(
                            config: GroupConfigNULL(isMulti: isMulti));
                        Http(tid: widget.tid, gid: widget.gid).putGroup(req);
                        widget.onModeChanged(isMulti);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
