// 设置页面
import 'package:flutter/material.dart';
import 'show.dart';
import 'develop_mode.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  List<Widget> pages = [Show(), Devleopmode()];

  List<String> _items = ["显示", "开发者"];
  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    double initialDragPosition = 0;

    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 10, top: 10.0, left: 50, right: 50),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "设置",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
              ],
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
                    return _buildItem(index);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    return Container(
      height: 70,
      padding: EdgeInsets.only(right: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => pages[index]));
        },
        style: ElevatedButton.styleFrom(
          elevation: 0, // 阴影大小
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // 圆角
          ),
          
        ),
        child: Text(
          _items[index],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}


          //
               // 开发者模式
          // TextButton(
          //   style: ButtonStyle(
          //     minimumSize: WidgetStateProperty.all(Size(double.infinity, 60)),
          //   ),
          //   onPressed: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => Devleopmode()));
          //   },
          //   child: Container(
          //     alignment: Alignment.centerLeft,
          //     child: Text(
          //       "开发者模式",
          //       style: TextStyle(
          //         fontSize: 16,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ),
// SizedBox(
//               height: 70,
//               child: GestureDetector(
//                 onHorizontalDragStart: (details) {
//                   initialDragPosition = details.localPosition.dx;
//                 },
//                 onHorizontalDragUpdate: (details) {
//                   final currentPosition = details.localPosition.dx;
//                   final delta = currentPosition - initialDragPosition;
//                   scrollController.jumpTo(scrollController.offset - delta);
//                   initialDragPosition = currentPosition;
//                 },
//                 child: ListView.builder(
//                   controller: scrollController,
//                   itemCount: _items.length,
//                   scrollDirection: Axis.horizontal, // 设置滚动方向为水平
//                   itemBuilder: (context, index) {
//                     return _buildItem(index);
//                   },
//                 ),
//               ),
//             )