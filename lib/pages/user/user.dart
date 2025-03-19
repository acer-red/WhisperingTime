import 'package:flutter/material.dart';

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
  List<Grid> _items = [
    
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
                "用户",
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
