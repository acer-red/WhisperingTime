import 'package:flutter/material.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/pages/welcome.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/services/sp/sp.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPage();
}

enum OpenWay {
  dialog,
  page,
}

class Grid {
  String title;
  Widget widget;
  OpenWay ow;
  Grid({required this.title, required this.widget, required this.ow});
}

class _UserPage extends State<UserPage> {
  List<Grid> _items = [];
  final scrollController = ScrollController();

  double initialDragPosition = 0;
  logout() {
    showConfirmationDialog(context, MyDialog(content: "确定退出吗？")).then((value) {
      if (!value) {
        return;
      }
      Config().close();
      SP().setIsAutoLogin(false);
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Welcome(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                "用户",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
              ),
              PopupMenuButton(itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      value: 0,
                      child: Row(spacing: 10, children: [
                        Icon(Icons.exit_to_app),
                        Text("退出"),
                      ]),
                      onTap: () {
                        logout();
                      }),
                ];
              }),
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
