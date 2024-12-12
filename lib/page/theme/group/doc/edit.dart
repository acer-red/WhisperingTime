import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';
import './setting.dart';

const String defaultTitle = "未命名的标题";

class LastPageDoc extends Doc {
  LastPage state;
  LastPageDoc(
      {required this.state,
      required super.title,
      required super.content,
      required super.level,
      required super.crtimeStr,
      required super.uptimeStr,
      required super.id});
}

// 事件编辑页面
class DocEditPage extends StatefulWidget {
  final String gid;
  final String? gname;
  final String title;
  final String content;
  final int level;
  final String? id;

  final String crtimeStr;
  final String uptimeStr;
  DocEditPage({
    required this.gid,
    this.id,
    this.gname,
    required this.title,
    required this.content,
    required this.level,
    required this.crtimeStr,
    required this.uptimeStr,
  });
  @override
  State<DocEditPage> createState() => _DocEditPage();
}

class _DocEditPage extends State<DocEditPage> with RouteAware {
  TextEditingController edit = TextEditingController();
  TextEditingController titleEdit = TextEditingController();
  bool chooseLeveled = false;
  bool _isSelected = true;
  bool isTitleSubmited = true;
  int currentLevel = 0;
  @override
  void initState() {
    super.initState();
    edit = TextEditingController(text: widget.content);
    widget.title.isEmpty
        ? titleEdit.text = defaultTitle
        : titleEdit.text = widget.title;
    currentLevel = widget.level;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // 标题
        appBar: AppBar(
          // 标题左侧的返回按钮
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
                            onExit: (_) => clickNewTitle(titleEdit.text),
                            child: TextField(
                              style: TextStyle(height: 20, fontSize: 23),
                              controller: titleEdit,
                              maxLines: 1,
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              onSubmitted: (text) => clickNewTitle(text),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          // 标题右侧按钮
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => enterSettingPage(),
            )
          ],
        ),

        // 主体
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 使 Text 组件左右居中
          children: [
            _isSelected
                ? TextButton(
                    child: Text(Level().string(widget.level)),
                    onPressed: () => {
                      setState(() {
                        _isSelected = false;
                      })
                    },
                  )
                : ToggleButtons(
                    onPressed: (int index) => clickNewLevel(index),
                    isSelected: [true, false, false, false, false],
                    children: List.generate(
                        Level.l.length, (index) => Level.levelWidget(index)),
                  ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(height: 300),
              child: SizedBox.expand(
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
                ),
              ),
            ),
          ],
        ));
  }

  clickNewLevel(int index) async {
    final res = await Http(gid: widget.gid)
        .putDoc(RequestPutDoc(id: widget.id!, level: index));
    if (res.isNotOk()) {
      return;
    }
    setState(() {
      currentLevel = index;
      _isSelected = true;
    });
  }

  clickNewTitle(String newTitle) async {
    final res = await Http(gid: widget.gid)
        .putDoc(RequestPutDoc(id: widget.id!, title: newTitle));
    if (res.isNotOk()) {
      return;
    }
    setState(() => isTitleSubmited = !isTitleSubmited);
  }

  void backPage() async {
    if (widget.content == edit.text &&
        titleEdit.text == defaultTitle &&
        widget.level == currentLevel) {
      print("无变化");

      if (mounted) {
        Navigator.of(context).pop(LastPageDoc(
            state: LastPage.nochange,
            title: titleEdit.text,
            content: widget.content,
            level: widget.level,
            crtimeStr: widget.crtimeStr,
            uptimeStr: widget.uptimeStr,
            id: widget.id!));
      }
      return;
    }
    if (widget.id == "") {
      if (mounted) {
        Navigator.of(context)
            .pop(edit.text.isEmpty ? nocreateDoc() : createDoc());
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
            builder: (context) =>
                DocSetting(gid: widget.gid, did: widget.id!)));
    switch (ret) {
      case LastPage.delete:
        print("返回并删除文档");
        Navigator.of(context).pop(LastPageDoc(
            state: ret,
            title: "",
            content: "",
            level: 0,
            id: "",
            crtimeStr: "",
            uptimeStr: ""));
        break;
      default:
        break;
    }
  }

  LastPageDoc nocreateDoc() {
    return LastPageDoc(
      state: LastPage.nocreate,
      content: "",
      level: 0,
      title: "",
      crtimeStr: "",
      uptimeStr: "",
      id: "",
    );
  }

  Future<LastPageDoc> createDoc() async {
    final realTitle = titleEdit.text == defaultTitle ? "" : titleEdit.text;
    final req = RequestPostDoc(
        content: edit.text, title: realTitle, level: currentLevel);
    final ret = await Http(gid: widget.gid).postDoc(req);
    return LastPageDoc(
      state: LastPage.create,
      content: edit.text,
      id: ret.id,
      title: realTitle,
      level: currentLevel,
      crtimeStr: req.crtime,
      uptimeStr: "",
    );
  }

  Future<LastPageDoc> updateDoc() async {
    final realTitle = titleEdit.text == defaultTitle ? "" : titleEdit.text;
    final req = RequestPutDoc(content: edit.text, id: widget.id!);
    final res = await Http(gid: widget.gid).putDoc(req);
    return LastPageDoc(
      state: LastPage.change,
      content: edit.text,
      id: res.id,
      title: realTitle,
      level: currentLevel,
      crtimeStr: widget.crtimeStr,
      uptimeStr: req.uptime,
    );
  }
}
