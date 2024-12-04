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
class DocEditPage extends StatefulWidget {
  final String gid;
  final String? gname;
  final String? id;
  final String title;
  final String content;
  DocEditPage({
    required this.gid,
    this.id,
    this.gname,
    required this.title,
    required this.content,
  });
  @override
  State<DocEditPage> createState() => _DocEditPage();
}

class _DocEditPage extends State<DocEditPage> with RouteAware {
  TextEditingController edit = TextEditingController();
  TextEditingController titleEdit = TextEditingController();

  bool isTitleSubmited = true;
  @override
  void initState() {
    super.initState();
    edit = TextEditingController(text: widget.content);
    widget.title.isEmpty
        ? titleEdit.text = "未命名的标题"
        : titleEdit.text = widget.title;
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
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                isTitleSubmited
                    ? Row(
                        children: [
                          Text(titleEdit.text),
                          IconButton(
                              onPressed: () => {
                                    setState(() {
                                      isTitleSubmited = !isTitleSubmited;
                                    })
                                  },
                              icon: Icon(Icons.mode_edit_outline)),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 300,
                          child: MouseRegion(
                            onExit: (_) =>
                                setState(() => isTitleSubmited = true),
                            child: TextField(
                              style: TextStyle(height: 20, fontSize: 23),
                              controller: titleEdit,
                              maxLines: 1,
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onSubmitted: (text) => setState(() =>
                                  isTitleSubmited =
                                      !isTitleSubmited), // 或者添加一个"完成"按钮
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
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
    if (widget.content == edit.text && widget.title == titleEdit.text) {
      print("无变化");

      if (mounted) {
        Navigator.of(context).pop(LastPageDoc(
            state: LastPage.nochange,
            title: titleEdit.text,
            content: widget.content,
            id: widget.id!));
      }
      return;
    }
    if (widget.id == "") {
      if (mounted) {
        Navigator.of(context).pop(createDoc());
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(updateDoc());
      }
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

  Future<LastPageDoc> createDoc() async {
    final ret = await Http(gid: widget.gid)
        .postDoc(RequestPostDoc(content: edit.text, title: titleEdit.text));
    return LastPageDoc(
        state: LastPage.create,
        content: edit.text,
        id: ret.id,
        title: titleEdit.text);
  }

  Future<LastPageDoc> updateDoc() async {
    final ret = await Http(gid: widget.gid).putDoc(
        RequestPutDoc(content: edit.text, title: titleEdit.text, id: widget.id!));
    return LastPageDoc(
        state: LastPage.change,
        content: edit.text,
        id: ret.id,
        title: titleEdit.text);
  }
}
