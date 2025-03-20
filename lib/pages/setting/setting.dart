import 'package:flutter/material.dart';

import 'package:whispering_time/utils/export.dart';

import 'font_manager.dart';
import 'show.dart';
import 'develop_mode.dart';
import 'feedback/feedback.dart';



class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPage();
}

enum OpenWay {
  dialog,
  page,
}

class Setting {
  String title;
  Widget widget;
  OpenWay ow;
  Setting({required this.title, required this.widget, required this.ow});
}

class _SettingPage extends State<SettingPage> {
  List<Setting> _items = [
    Setting(
      title: "显示",
      widget: Show(),
      ow: OpenWay.page,
    ),
    Setting(
      title: "字体管理",
      widget: FontManager(),
      ow: OpenWay.dialog,
    ),
    Setting(
      title: "数据导出",
      widget: Export(ResourceType.theme, title: "导出所有印迹数据"),
      ow: OpenWay.dialog,
    ),
    Setting(
      title: "反馈",
      widget: FeedbackPage(),
      ow: OpenWay.page,
    ),
    Setting(
      title: "开发者",
      widget: Devleopmode(),
      ow: OpenWay.page,
    ),
  ];
  final scrollController = ScrollController();

  double initialDragPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                "设置",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
              ),
            ],
          ),
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
                return gridGeneral(index);
              },
            ),
          ),
        )
      ],
    );
  }

  Widget gridGeneral(int index) {
    final GlobalKey buttonKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: ElevatedButton(
        key: buttonKey,
        onPressed: () {
          switch (_items[index].ow) {
            case OpenWay.dialog:
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return _items[index].widget;
                },
              );
              break;
            case OpenWay.page:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => _items[index].widget),
              );
              break;
    
          }
        },
        style: ElevatedButton.styleFrom(
            elevation: 0, // 阴影大小
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 圆角
            ),
            padding: EdgeInsets.only(left: 25, right: 25)),
        child: Text(
          _items[index].title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
