import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/pages/doc/list.dart';
import 'package:whispering_time/services/http/http.dart';
import 'model.dart';
import 'settings.dart';

class GroupPage extends StatefulWidget {
  final String? id;
  final String tid;
  final String themename;
  GroupPage({required this.themename, required this.tid, this.id});

  @override
  State<StatefulWidget> createState() => _GroupPage();
}

// 使用 AutomaticKeepAliveClientMixin 保持页面状态
// 这样在 TabBarView 中切换 Tab 时，页面不会被销毁和重建，从而避免数据重新加载
class _GroupPage extends State<GroupPage> with AutomaticKeepAliveClientMixin {
  int gidx = 0;
  bool isGrouTitleSubmitted = true;
  int pageIndex = 0;

  // 重写 wantKeepAlive 属性，返回 true 表示需要保持页面状态
  // 当此属性为 true 时，页面在离开视图后不会被销毁
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 使用 AutomaticKeepAliveClientMixin 时，必须在 build 方法开头调用 super.build(context)
    // 这样才能让页面保持机制正常工作
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: context.watch<GroupsModel>().length,
        itemBuilder: (context, index) {
          final items = context.watch<GroupsModel>().items;
          if (index >= items.length) return SizedBox();

          final item = items[index];
          final name = item.name;

          return Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onLongPress: () {
                context.read<GroupsModel>().setIndex(index);
                final i = items[index];
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext modalContext) {
                    // 使用 ChangeNotifierProvider.value 而不是 Provider.value
                    return ChangeNotifierProvider.value(
                      value: context.read<GroupsModel>(),
                      child: GroupSettings(
                        group: i,
                        tid: widget.tid,
                      ),
                    );
                  },
                );
              },
              // 水波纹颜色 - 使用主题色的半透明版本，更加协调
              splashColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              // 高亮颜色 - 使用更柔和的透明度
              highlightColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              // 悬停颜色 - 增加桌面端的体验
              hoverColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // 设置当前选中的索引
                context.read<GroupsModel>().setIndex(index);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DocList(group: item, tid: widget.tid)));
              },
              child: Container(alignment: Alignment.center, child: Text(name)),
            ),
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
