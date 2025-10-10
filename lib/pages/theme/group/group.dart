import 'package:flutter/material.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/pages/theme/doc/list.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:whispering_time/utils/ui.dart';

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

  int gidx = 0;
  bool isGrouTitleSubmitted = true;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    getGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _gitems.length,
        itemBuilder: (context, index) {
          final item = _gitems[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DocList(group: _gitems[gidx])));
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(item.name)),
          );
        },
      ),
    );
  }

  /// 窗口: 显示设置
  void dialogWidget(Widget widget) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }

  /// 窗口: 设置
  void dialogSetting() async {
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
  void dialogExport() {
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
  void dialogRename() async {
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
  void dialogAddGroup() async {
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
      for (int i = 0; i < _gitems[gidx].config.levels.length; i++) {
        if (_gitems[gidx].config.levels[i]) {
          _gitems[gidx].config.levels[i] = false;
        }
      }
    });
  }

  /// 按钮：切换分组按钮
  /// 位置：在分组列表中
  // void clickGroupTitle(int index) {
  //   setState(() {
  //     gidx = index;
  //     // groupTitleEdit.text = _gitems[gidx].name;
  //   });

  //   Navigator.pop(context); // 关闭 drawer
  //   getDocs();
  // }

  /// 按钮：删除分组
  /// 位置：在设置中
  void clickDeleteGroup(int index) async {
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

  /// 按钮：分级按钮
  /// 位置：在显示设置中
  // void clickLevel(List<bool> value) {
  //   _gitems[gidx].config.levels = value;

  //   RequestPutGroup req = RequestPutGroup(
  //       config: GroupConfigNULL(levels: _gitems[gidx].config.levels));
  //   Http(tid: widget.tid, gid: _gitems[gidx].id).putGroup(req);

  //   switch (_gitems[gidx].config.viewType) {
  //     case 0:
  //       getDocs();
  //       break;
  //     case 1:
  //       getDocs(year: pickedDate.year, month: pickedDate.month);
  //       break;
  //   }
  // }

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
      _gitems = res.data
          .map((l) => Group(
              name: l.name, id: l.id, overtime: l.overtime, config: l.config))
          .toList();
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
