import 'package:flutter/material.dart';
import 'edit.dart';

// 事件列表页面
class LPData {}

class ListPage extends StatefulWidget {
  final String? id;
  final String themeid;
  final String titlename;

  ListPage({required this.titlename, required this.themeid, this.id});

  @override
  State<StatefulWidget> createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titlename)),
      body: Column(children: [
        Spacer(),
        Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EEdit(themeid: widget.themeid,)));
              },
              child: Text('来记录心路历程吧！')),
        ),
        Padding(padding: EdgeInsets.only(bottom: 40.0))
      ]),
    );
  }
}
