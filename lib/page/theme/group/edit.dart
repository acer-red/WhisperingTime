import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';

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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => backPage(),
          ),
          title: Text(widget.title),
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
        Navigator.of(context).pop(Doc(title: widget.title,content: widget.content,id:widget.id!));
      }

      return;
    }
    final ret = await upload();
    if (mounted) {
      Navigator.of(context).pop(ret);
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
