import 'package:flutter/material.dart';
import 'edit.dart';
import 'package:whispering_time/http.dart';

// 事件列表页面
class LPData {}

class ListPage extends StatefulWidget {
  final String? id;
  final String tid;
  final String titlename;

  ListPage({required this.titlename, required this.tid, this.id});

  @override
  State<StatefulWidget> createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titlename)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: getGroupList(),
        ),
      ),
      body: Column(children: [
        Spacer(),
        Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EEdit(
                              tid: widget.tid,
                            )));
              },
              child: Text('来记录心路历程吧！')),
        ),
        Padding(padding: EdgeInsets.only(bottom: 40.0))
      ]),
    );
  }

  getGroupList() {
    var g = <Widget>[];
    var ret = Http(tid: widget.tid).getgroup();
    ret.then((list)=>{
     for (GroupListData l in list) {
      g.add(
        ListTile(
          // leading: Icon(Icons.message),
          title: Text(l.name),
          onTap: () {
            // 处理点击事件
            Navigator.pop(context); // 关闭 drawer
          },
        ),
      )
     }
    });
   
    return g;
  }
}
