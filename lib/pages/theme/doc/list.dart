import 'package:flutter/material.dart';
import 'package:whispering_time/pages/theme/doc/edit.dart';
import 'package:whispering_time/pages/theme/doc/setting.dart';
import 'package:whispering_time/pages/theme/group/group.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/pages/theme/doc/setting.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/utils/time.dart';

class DocList extends StatefulWidget {
  Group group;

  DocList({required this.group});

  @override
  State createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  List<Doc> items = <Doc>[];
  DateTime pickedDate = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body:screenCard(),
    );
  }

    // UI: 主体内容-卡片模式
  Widget screenCard() {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
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

                  for (int i = 0; i < items.length; i++) {
                    if (index - firstWeekdayOfMonth + 2 ==
                        items[i].crtime.day) {
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

  /// 页面：空白印迹编辑页面
  void enterDocBlank() async {
    Group item =widget.group;

    // if (item.isFreezedOrBuf()) {
    //   Msg.diy(context, "已定格或已进入定格缓冲期，无法编辑");
    //   return;
    // }
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
          items.add(Doc(
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

  /// 页面：印迹编辑页面
  void enterDoc(int index) async {
    Group group =widget.group;
    Doc doc = items[index];
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
            freeze:widget.group.isFreezedOrBuf(),
          ),
        ));
    setState(() {
      log.i("状态变更: ${ret.state}");
      switch (ret.state) {
        case LastState.delete:
          items.removeAt(index);
          break;
        case LastState.change:
          if (!isContainSelectLevel(ret.level)) {
            items.removeAt(index);
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
            items[index].crtime = ret.crtime;
            items[index].crtime = ret.crtime;
            items.sort(compareDocs);
          }
          if (ret.config.isShowTool != doc.config.isShowTool) {
            items[index].config.isShowTool = ret.config.isShowTool;
          }
          if (doc.level != ret.level) {
            doc.level = ret.level;
          }
          break;
        case LastState.changeConfig:
          if (doc.crtime != ret.crtime) {
            items[index].crtime = ret.crtime;
            items[index].crtime = ret.crtime;
            items.sort(compareDocs);
          }
          log.i(ret.config.isShowTool);
          if (ret.config.isShowTool != doc.config.isShowTool) {
            items[index].config.isShowTool = ret.config.isShowTool;
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
  /// 功能：更新当前分组下的印迹列表
  void getDocs({int? year, int? month}) async {
    final ret = await Http(gid:widget.group.id).getDocs(year, month);
    setState(() {
      if (items.isNotEmpty) {
        items.clear();
      }
      if (isNoSelectLevel()) {
        items.clear();
        return;
      }

      for (Doc doc in ret.data) {
        if (isContainSelectLevel(doc.level)) {
          items.add(doc);
        }
      }
      items.sort(compareDocs);
    });
  }

  int compareDocs(Doc a, Doc b) {
    DateTime aTime = a.crtime;
    DateTime bTime = b.crtime;
    return aTime.compareTo(bTime);
  }

  bool isNoSelectLevel() {
    for (bool one in widget.group.config.levels) {
      if (one) {
        return false;
      }
    }
    return true;
  }

  int getSelectLevel() {
    for (int buttonIndex = 0;
        buttonIndex <widget.group.config.levels.length;
        buttonIndex++) {
      if (widget.group.config.levels[buttonIndex]) {
        return buttonIndex;
      }
    }
    return 0;
  }

  bool isContainSelectLevel(int i) {
    return widget.group.config.levels[i];
  }




}