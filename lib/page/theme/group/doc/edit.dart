import 'package:flutter/material.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';
import './setting.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

const String defaultTitle = "未命名的标题";

class LastPageDoc extends Doc {
  LastPage state;
  LastPageDoc(
      {required this.state,
      required super.title,
      required super.content,
      required super.level,
      required super.crtime,
      required super.uptime,
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

  final DateTime crtime;
  final DateTime uptime;
  final bool freeze;
  DocEditPage(
      {this.id,
      this.gname,
      required this.gid,
      required this.title,
      required this.content,
      required this.level,
      required this.crtime,
      required this.uptime,
      required this.freeze});
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
  late DateTime crtime;

  @override
  void initState() {
    super.initState();
    edit = TextEditingController(text: widget.content);
    widget.title.isEmpty
        ? titleEdit.text = defaultTitle
        : titleEdit.text = widget.title;
    currentLevel = widget.level;
    crtime = widget.crtime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // 标题
        appBar: AppBar(
          centerTitle: true,

          // 标题左侧的返回按钮
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => backPage(),
          ),

          // 标题
          title: GestureDetector(
            onTap: () {
              setState(() {
                isTitleSubmited = !isTitleSubmited;
              });
            },
            child: TextField(
              style: TextStyle(fontSize: 23),
              textAlign: TextAlign.center, // 添加这行
              controller: titleEdit,
              maxLines: 1,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              onSubmitted: (text) => clickNewTitle(text),
              enabled: !widget.freeze,
              onEditingComplete: () {
                setState(() {
                  isTitleSubmited = false;
                });
              },
            ),
          ),

          // 标题右侧按钮
          actions: <Widget>[
            IconButton(onPressed: () => exportDoc(), icon: Icon(Icons.share)),
            widget.freeze
                ? IconButton(
                    icon: Icon(Icons.settings, color: Colors.grey), // 灰色图标
                    onPressed: null,
                  )
                : IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => enterSettingPage(),
                  ),
          ],
        ),

        // 主体
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 使 Text 组件左右居中
          children: [
            !widget.freeze && _isSelected
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
                    enabled: !widget.freeze,
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
    if (res.isNotOK()) {
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
    if (res.isNotOK()) {
      return;
    }
    setState(() => isTitleSubmited = !isTitleSubmited);
  }

  void backPage() async {
    if (widget.content == edit.text &&
        (titleEdit.text == defaultTitle ||
            titleEdit.text == widget.title) && // 控件中的文字是默认标题或原始标题
        widget.level == currentLevel &&
        widget.crtime == crtime) {
      print("无变化");

      if (mounted) {
        Navigator.of(context).pop(LastPageDoc(
            state: LastPage.nochange,
            title: titleEdit.text,
            content: widget.content,
            level: widget.level,
            crtime: widget.crtime,
            uptime: widget.uptime,
            id: widget.id!));
      }
      return;
    }

    // 有变化，更新文档
    if (widget.id != "") {
      if (mounted) {
        Navigator.of(context).pop(updateDoc());
      }
      return;
    }

    // 没有创建文档
    if (edit.text.isEmpty && titleEdit.text.isEmpty) {
      Navigator.of(context).pop(nocreateDoc(failed: false));
    }

    // 有变化，创建文档
    final ret = await createDoc();
    if (ret.state == LastPage.err) {
      if (mounted) {
        Msg.diy(context, "创建失败");
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop(ret);
    }
  }

  void enterSettingPage() async {
    final LastPageDocSetting ret = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DocSetting(
                gid: widget.gid, did: widget.id!, crtime: widget.crtime)));
    switch (ret.state) {
      case LastPage.change:
        if (ret.crtime != null) {
          setState(() {
            crtime = ret.crtime!;
          });
        }
        break;
      case LastPage.delete:
        print("返回并删除文档");
        Navigator.of(context).pop(LastPageDoc(
            state: ret.state,
            title: "",
            content: "",
            level: 0,
            id: "",
            crtime: DateTime.now(),
            uptime: DateTime.now()));
        break;
      default:
        break;
    }
  }

  LastPageDoc nocreateDoc({bool failed = false}) {
    return LastPageDoc(
      state: failed ? LastPage.err : LastPage.nocreate,
      content: "",
      level: 0,
      title: "",
      crtime: DateTime.now(),
      uptime: DateTime.now(),
      id: "",
    );
  }

  Future<LastPageDoc> createDoc() async {
    final realTitle = titleEdit.text == defaultTitle ? "" : titleEdit.text;
    final req = RequestPostDoc(
        content: edit.text,
        title: realTitle,
        level: currentLevel,
        crtime: crtime);
    final ret = await Http(gid: widget.gid).postDoc(req);
    if (ret.isNotOK()) {
      return nocreateDoc(failed: true);
    }
    return LastPageDoc(
      state: LastPage.create,
      content: edit.text,
      id: ret.id,
      title: realTitle,
      level: currentLevel,
      crtime: req.crtime,
      uptime: crtime,
    );
  }

  Future<LastPageDoc> updateDoc() async {
    // final newCRTime = Time.toTimestampString(crtime);

    final realTitle = titleEdit.text == defaultTitle ? "" : titleEdit.text;
    final req = RequestPutDoc(
        content: edit.text,
        id: widget.id!,
        title: titleEdit.text,
        crtime: crtime);
    final res = await Http(gid: widget.gid).putDoc(req);
    return LastPageDoc(
      state: LastPage.change,
      content: edit.text,
      id: res.id,
      title: realTitle,
      level: currentLevel,
      crtime: crtime,
      uptime: req.uptime,
    );
  }

  void exportDoc() async {
    int ret = await showExportOption();
    switch (ret) {
      case 0:
        exportDesktop();
        break;
      default:
        break;
    }
  }

  Future<void> exportDesktop() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: titleEdit.text,
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    // 用户取消了操作
    if (outputFile == null) {
      return;
    }

    File file = File(outputFile);
    await file.writeAsString(edit.text);
    print("文件已保存：${file.path}");
  }

  Future<int> showExportOption() async {
    int? ret = await showDialog<int>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("导出印迹"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("导出到本地"),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(0);
                    },
                    child: Text("仅文本")),
                divider(),
              ],
            ),
          ),
        );
      },
    );

    return ret ?? -1; // 如果用户没有点击按钮，则默认为 false
  }
}
