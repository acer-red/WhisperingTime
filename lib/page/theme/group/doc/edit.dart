import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';
import './setting.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

const String defaultTitle = "未命名的标题";

class LastPageDoc extends Doc {
  LastPage state;
  LastPageDoc(
      {required this.state,
      required super.title,
      required super.content,
      required super.plainText,
      required super.level,
      required super.crtime,
      required super.uptime,
      required super.config,
      required super.id});
}

// 事件编辑页面
class DocEditPage extends StatefulWidget {
  final String gid;
  final String? gname;
  final String title;
  final String content;
  final int level;
  final DocConfigration config;
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
      required this.config,
      required this.crtime,
      required this.uptime,
      required this.freeze});
  @override
  State<DocEditPage> createState() => _DocEditPage();
}

class _DocEditPage extends State<DocEditPage> with RouteAware {
  TextEditingController titleEdit = TextEditingController();
  quill.QuillController edit = quill.QuillController.basic();

  DocConfigration config = DocConfigration();
  bool chooseLeveled = false;
  bool _isSelected = true;
  bool isTitleSubmited = true;
  int currentLevel = 0;
  late DateTime crtime;

  @override
  void initState() {
    super.initState();

    edit = quill.QuillController(
        document: quill.Document.fromJson(jsonDecode(widget.content)),
        selection: const TextSelection.collapsed(offset: 0));
    currentLevel = widget.level;
    crtime = widget.crtime;
    config = widget.config;
    titleEdit.text = widget.title;
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
              autofocus: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.title.isEmpty ? defaultTitle : widget.title,
                hintStyle: TextStyle(color: Colors.grey),
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
            //           hintText: '或简单，或详尽～',

            // 富文本的工具栏
            if (config.isShowTool!) quill.QuillToolbar.simple(controller: edit),

            // 富文本
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 30.0, right: 30.0),
                child: quill.QuillEditor(
                  controller: edit,
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  configurations: quill.QuillEditorConfigurations(
                    scrollable: true,
                    expands: false,
                    customStyles: quill.DefaultStyles(
                      paragraph: quill.DefaultTextBlockStyle(
                          TextStyle(
                              fontSize: 16, height: 1.4, color: Colors.black),
                          HorizontalSpacing(0, 0),
                          // 10像素底部间距，0像素顶部间距
                          VerticalSpacing(10, 0),
                          VerticalSpacing(0, 0),
                          null),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  clickNewLevel(int index) async {
    final res = await Http(gid: widget.gid, did: widget.id!)
        .putDoc(RequestPutDoc(level: index));
    if (res.isNotOK()) {
      return;
    }
    setState(() {
      currentLevel = index;
      _isSelected = true;
    });
  }

  clickNewTitle(String newTitle) async {
    final res = await Http(gid: widget.gid, did: widget.id!)
        .putDoc(RequestPutDoc(title: newTitle));
    if (res.isNotOK()) {
      return;
    }
    setState(() => isTitleSubmited = !isTitleSubmited);
  }

  void backPage() async {
    if (widget.content == getEditOrigin() &&
        (titleEdit.text == widget.title) && // 控件中的文字是默认标题或原始标题
        widget.level == currentLevel) {
      if (widget.crtime != crtime || widget.config != config) {
        print("文档内容无变化,配置有变化");
        if (mounted) {
          return Navigator.of(context).pop(LastPageDoc(
              state: LastPage.changeConfig,
              title: titleEdit.text,
              content: widget.content,
              plainText: getEditPlainText(),
              level: widget.level,
              crtime: crtime,
              uptime: widget.uptime,
              config: config,
              id: widget.id!));
        }
      }
      print("文档内容无变化");
      if (mounted) {
        return Navigator.of(context).pop(LastPageDoc(
            state: LastPage.nochange,
            title: titleEdit.text,
            content: widget.content,
            plainText: getEditPlainText(),
            level: widget.level,
            crtime: crtime,
            uptime: widget.uptime,
            config: config,
            id: widget.id!));
      }
    }

    // 有变化，更新文档
    if (widget.id != "") {
      final req = RequestPutDoc(
        plainText: getEditPlainText(),
        content: getEditOrigin(),
        title: titleEdit.text,
      );

      if (mounted) {
        Navigator.of(context).pop(updateDoc(req));
      }
      return;
    }

    // 没有创建文档
    if (getEditOrigin().isEmpty && titleEdit.text.isEmpty) {
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
                gid: widget.gid,
                did: widget.id!,
                crtime: widget.crtime,
                config: config)));
    switch (ret.state) {
      case LastPage.change:
        setState(() {
          if (ret.crtime != null) {
            crtime = ret.crtime!;
          }
          if (ret.config != null) {
            config = ret.config!;
          }
        });
        break;
      case LastPage.delete:
        print("返回并删除文档");
        Navigator.of(context).pop(LastPageDoc(
            state: ret.state,
            title: "",
            plainText: "",
            content: "",
            level: 0,
            id: "",
            crtime: DateTime.now(),
            uptime: DateTime.now(),
            config: config));
        break;
      default:
        break;
    }
  }

  LastPageDoc nocreateDoc({bool failed = false}) {
    return LastPageDoc(
      state: failed ? LastPage.err : LastPage.nocreate,
      content: "",
      plainText: "",
      level: 0,
      title: "",
      crtime: DateTime.now(),
      uptime: DateTime.now(),
      config: config,
      id: "",
    );
  }

  Future<LastPageDoc> createDoc() async {
    final req = RequestPostDoc(
      content: getEditOrigin(),
      plainText: getEditPlainText(),
      title: titleEdit.text,
      level: currentLevel,
      crtime: crtime,
      config: config,
    );
    final ret = await Http(gid: widget.gid).postDoc(req);
    if (ret.isNotOK()) {
      return nocreateDoc(failed: true);
    }
    return LastPageDoc(
      state: LastPage.create,
      content: getEditOrigin(),
      plainText: getEditPlainText(),
      id: ret.id,
      title: titleEdit.text,
      level: currentLevel,
      crtime: req.crtime,
      uptime: crtime,
      config: config,
    );
  }

  Future<LastPageDoc> updateDoc(RequestPutDoc req) async {
    final res = await Http(gid: widget.gid, did: widget.id!).putDoc(req);
    if (res.isNotOK()) {
      return LastPageDoc(
        state: LastPage.nochange,
        content: widget.content,
        plainText: getEditPlainText(),
        id: widget.id!,
        title: widget.title,
        level: widget.level,
        crtime: widget.crtime,
        uptime: widget.uptime,
        config: config,
      );
    }
    return LastPageDoc(
      state: LastPage.change,
      content: getEditOrigin(),
      plainText: getEditPlainText(),
      id: widget.id!,
      title: titleEdit.text,
      level: currentLevel,
      crtime: crtime,
      uptime: req.uptime,
      config: config,
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
    await file.writeAsString(getEditOrigin());
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

  String getEditOrigin() {
    return jsonEncode(edit.document.toDelta().toJson());
  }

  String getEditPlainText() {
    return edit.document.toPlainText();
  }
}
