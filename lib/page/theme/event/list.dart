import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'edit.dart';

// 事件列表页面
class Data {
  final String name;
  final String? id;
  Data({required this.name, this.id});
}

class ListPage extends StatefulWidget {
  final Data title;
  ListPage(this.title);

  @override
  State<StatefulWidget> createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title.name)),
      body: Column(children: [
        Spacer(),
        Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EEdit(docid: Uuid().v4())));
              },
              child: Text('来记录心路历程吧！')),
        ),
        Padding(padding: EdgeInsets.only(bottom: 40.0))
      ]),
    );
  }
}
