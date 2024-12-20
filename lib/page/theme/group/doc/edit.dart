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
  final bool freeze;
  DocEditPage(
      {this.id,
      this.gname,
      required this.gid,
      required this.title,
      required this.content,
      required this.level,
      required this.crtimeStr,
      required this.uptimeStr,
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
    crtime = Time.datetime(widget.crtimeStr);
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
        widget.crtimeStr == Time.toTimestampString(crtime)) {
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
    final LastPageDocSetting ret = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DocSetting(
                gid: widget.gid,
                did: widget.id!,
                crtimeStr: widget.crtimeStr)));
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
    final newCRTime = Time.toTimestampString(crtime);

    final realTitle = titleEdit.text == defaultTitle ? "" : titleEdit.text;
    final req = RequestPostDoc(
        content: edit.text,
        title: realTitle,
        level: currentLevel,
        crtime: newCRTime);
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
    final newCRTime = Time.toTimestampString(crtime);

    final realTitle = titleEdit.text == defaultTitle ? "" : titleEdit.text;
    final req = RequestPutDoc(
        content: edit.text,
        id: widget.id!,
        title: titleEdit.text,
        crtime: newCRTime);
    final res = await Http(gid: widget.gid).putDoc(req);
    return LastPageDoc(
      state: LastPage.change,
      content: edit.text,
      id: res.id,
      title: realTitle,
      level: currentLevel,
      crtimeStr: newCRTime,
      uptimeStr: req.uptime,
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
