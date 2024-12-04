import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';
import './setting.dart';

class LastPageDoc extends Doc {
  LastPage state;
  LastPageDoc(
      {required this.state,
      required super.title,
      required super.content,
      required super.id});
}

// 事件编辑页面
class EEdit extends StatefulWidget {
  final String gid;
  final String? gname;
  final String? id;
  String title;
  String content;
  EEdit({
    required this.gid,
    this.id,
    this.gname,
    required this.title,
    required this.content,
  });
  @override
  State<EEdit> createState() => _EEdit();
}

class _EEdit extends State<EEdit> with RouteAware {
  TextEditingController edit = TextEditingController();

  @override
  void initState() {
    super.initState();
    edit = TextEditingController(text: widget.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // 标题
        appBar: AppBar(
          // 标题左侧
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => backPage(),
          ),
          // 标题
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => enterSettingPage(),
            )
          ],
        ),
        body: SizedBox.expand(
            child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: TextField(
            controller: edit,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: '或简单，或详尽～',
              border: InputBorder.none,
            ),
          ),
        )));
  }

  void backPage() async {
    if (widget.content == edit.text) {
      print("无变化");

      if (mounted) {
        Navigator.of(context).pop(
            LastPageDoc(state:LastPage.nochange, title: widget.title, content: widget.content, id: widget.id!));
      }
      return;
    }
    await upload();
    if (mounted) {
      Navigator.of(context).pop(LastPageDoc(state:LastPage.change, title: widget.title, content: widget.content, id: widget.id!));
    }
  }

  void enterSettingPage() async {
    final LastPage ret = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Setting(gid: widget.gid, did: widget.id!)));
    switch (ret) {
      case LastPage.delete:
      print("返回并删除文档");
        Navigator.of(context)
            .pop(LastPageDoc(state: ret, title: "", content: "", id: ""));
        break;
      default:
        break;
    }
  }

  Future<Doc> upload() async {
    if (widget.id == "") {
      final ret = await Http(gid: widget.gid)
          .postDoc(RequestPostDoc(content: edit.text, title: widget.title));
      return Doc(content: edit.text, id: ret.id, title: widget.title);
    } else {
      final ret = await Http(gid: widget.gid).putDoc(RequestPutDoc(
          content: edit.text, title: widget.title, id: widget.id!));
      return Doc(content: edit.text, id: ret.id, title: widget.title);
    }
  }
}
