import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';

// 事件编辑页面
class EEdit extends StatefulWidget {
  final String gid;
  final String? gname;
  final String? docid;
  String title;
  EEdit({
    required this.gid,
    this.docid,
    this.gname,
    required this.title,
  });
  @override
  State<EEdit> createState() => _EEdit();
}

class _EEdit extends State<EEdit> with RouteAware {
  TextEditingController edit = TextEditingController();
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
    print("echo");
    final ret = await upload();
    if (mounted) {
      Navigator.of(context).pop(ret);
    }
  }

  Future<Doc> upload() async {
    final ret = await Http(gid: widget.gid).postDoc(RequestPostDoc(content: edit.text,title: widget.title));
    return Doc(content: edit.text,id: ret.id,title: widget.title);
  }
}
