import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';
import 'setting.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

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

class DocEditPage extends StatefulWidget {
  final String gid;
  final String? gname;
  final String title;

  // 富文本的原始数据
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
  QuillController edit = QuillController.basic();

  DocConfigration config = DocConfigration();
  bool chooseLeveled = false;
  bool _isSelected = true;
  bool isTitleSubmited = true;
  int level = 0;
  DateTime crtime= DateTime.now();
  String id = "";
  bool get keepEditText => widget.content == getEditOrigin();
  bool get keepTitleText => titleEdit.text == widget.title;
  bool get keepLevel => widget.level == level;
  bool get keepCRTime => widget.crtime == crtime;
  bool get keepConfig => widget.config == config;
  bool get hasDocID => widget.id != null;
  bool get hasContent => !(isEditorEmpty() && titleEdit.text.isEmpty);
  bool get isNoCreateDoc =>
      getEditOrigin().isEmpty && titleEdit.text.isEmpty || widget.id!.isEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.content.isNotEmpty) {
      edit = QuillController(
          document: Document.fromJson(jsonDecode(widget.content)),
          selection: const TextSelection.collapsed(offset: 0));
    }

    level = widget.level;
    crtime = widget.crtime;
    config = widget.config;
    titleEdit.text = widget.title;
    if (hasDocID) {
      id = widget.id!;
    }
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
                    icon: Icon(Icons.settings, color: Colors.grey),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !widget.freeze && _isSelected
                ? TextButton(
                    child: Text(Level().string(level)),
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

            // 富文本工具栏（含图片）
            if (config.isShowTool!)
              QuillToolbar.simple(
                controller: edit,
                configurations: QuillSimpleToolbarConfigurations(
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      icon: Icon(Icons.image),
                      onPressed: () => dialogSelectImage(context, edit),
                    )
                  ],
                  // embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                ),
              ),

            // 富文本编辑框
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 30.0, right: 30.0),
                child: QuillEditor(
                  controller: edit,
                  focusNode: FocusScopeNode(),
                  scrollController: ScrollController(),
                  configurations: QuillEditorConfigurations(
                    sharedConfigurations: QuillSharedConfigurations(
                      extraConfigurations: {
                        QuillSharedExtensionsConfigurations.key:
                            QuillSharedExtensionsConfigurations(
                          assetsPrefix: 'assets',
                        ),
                      },
                    ),
                    scrollable: true,
                    expands: false,

                    // 添加图片后，能够显示图片的构建
                    embedBuilders: kIsWeb
                        ? FlutterQuillEmbeds.editorWebBuilders()
                        : FlutterQuillEmbeds.editorBuilders(),
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
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
    if (hasDocID) {
      final res = await Http(gid: widget.gid, did: widget.id!)
          .putDoc(RequestPutDoc(level: index));
      if (res.isNotOK) {
        return;
      }
    }

    setState(() {
      level = index;
      _isSelected = true;
    });
  }

  clickNewTitle(String newTitle) async {
    final res = await Http(gid: widget.gid, did: widget.id!)
        .putDoc(RequestPutDoc(title: newTitle));
    if (res.isNotOK) {
      return;
    }
    setState(() => isTitleSubmited = !isTitleSubmited);
  }

  // 保存文档
  Future<bool> saveDoc() async {
    updateImage();

    // 创建新文档
    if (widget.id == null) {
      final ret = await createDoc();
      if (ret.isNotOK) {
        print("创建文档失败");
        return false;
      }
      setState(() {
        id = ret.id;
      });
      return true;
    }

    // 更新现有文档
    final ret = await updateDoc();
    if (ret.isNotOK) {
      print("更新文档失败");
      return false;
    }

    return true;
  }

// 返回上一级页面
  void backPage() async {
    // 返回时既没有ID，也没有内容
    if (!hasDocID && !hasContent) {
      return Navigator.of(context).pop(nocreateDoc(failed: false));
    }

    // 文档内容有变化
    if (!(keepEditText && keepTitleText && keepLevel)) {
      bool ok = await saveDoc();
      if (ok) {
        log.i("保存成功");
        if (mounted) {
          return Navigator.of(context).pop(LastPageDoc(
              state: widget.id == null ?LastPage.create:LastPage.change,
              title: titleEdit.text,
              content: getEditOrigin(),
              plainText: getEditPlainText(),
              level: level,
              crtime: crtime,
              uptime: widget.uptime,
              config: config,
              id: id));
        }
      } else {
        log.e("保存失败");
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
              id: ""));
        }
      }
    }

    // 文档内容无变化
    if (keepCRTime && keepConfig) {
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
            id: id));
      }
      // 文档内容无变化，配置有变化
    } else {
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
            id: id));
      }
    }
  }

  void enterSettingPage() async {
    final LastPageDocSetting ret = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DocSetting(
                gid: widget.gid,
                did: widget.id,
                crtime: widget.crtime,
                config: config)));
    switch (ret.state) {
      case LastPage.change:
        if (widget.id != null) {
          final req = RequestPutDoc(
              crtime: ret.crtime,
              config: DocConfigration(isShowTool: config.isShowTool));
          final res = await Http(gid: widget.gid, did: widget.id!).putDoc(req);
          if (res.isNotOK) {
            // Navigator.of(context).pop()
            print("更新配置错误");
            break;
          }
        }
        print("crtime ${ret.crtime}");
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

  Future<ResponsePostDoc> createDoc() async {
    final req = RequestPostDoc(
      content: getEditOrigin(),
      plainText: getEditPlainText(),
      title: titleEdit.text,
      level: level,
      crtime: crtime,
      config: config,
    );
    final ret = await Http(gid: widget.gid).postDoc(req);
    return ret;
  }

  Future<ResponsePutDoc> updateDoc() async {
    final req = RequestPutDoc(
      plainText: getEditPlainText(),
      content: getEditOrigin(),
      title: titleEdit.text,
      level: level,
    );

    final res = await Http(gid: widget.gid, did: widget.id!).putDoc(req);
    return res;
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
    await file.writeAsString(getEditPlainText());
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

  void updateImage() async {
    List<Operation> ops = edit.document.toDelta().toList();

    for (Operation op in ops) {
      if (!(op.isInsert && op.value is Embed && op.value.type == 'image')) {
        continue;
      }
      String base64Image = op.value.data;
      String name = UUID.create;
      print("发现需要更替的图片");

      if (base64Image.startsWith("data:image/png;base64,")) {
        base64Image.replaceFirst("data:image/png;base64,", "");
        name += ".png";
      } else if (base64Image.startsWith("data:image/jpg;base64,")) {
        base64Image.replaceFirst("data:image/jpg;base64,", "");
        name += ".jpg";
      } else {
        continue;
      }
      print("图片更替");
      Uint8List bytes = base64Decode(base64Image);

      ResponsePostImage res =
          await Http().postImage(RequestPostImage(name: name, data: bytes));
      if (!res.ok) {
        log.e('创建图片失败');
        return;
      }
      op.value.data = "http://${Settings().getServerAddress()}/image/$name";
      // 现在你可以使用 imageBytes 了
    }
  }

  Future<void> dialogSelectImage(
      BuildContext context, QuillController edit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SingleChildScrollView(
          child: ListBody(children: <Widget>[
            Column(
              children: [
                TextButton.icon(
                  onPressed: () {
                    selectImage(edit);
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.folder_open),
                  label: Text("本地文件"),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.photo_camera),
                  label: Text("相机"),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.language),
                  label: Text("网络"),
                )
              ],
            ),
          ]),
        ));
      },
    );
  }

  selectImage(QuillController edit) async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    final File imageFile = File(image.path);
    final String extension = p.extension(imageFile.path);
    final bytes = await imageFile.readAsBytes();
    final String data;
    if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.JPG' ||
        extension == '.JPEG') {
      data = "data:image/png;base64,${base64Encode(bytes)}";
    } else if (extension == '.png' || extension == '.PNG') {
      data = "data:image/png;base64,${base64Encode(bytes)}";
    } else {
      print('其他文件类型');
      return;
    }

    // 优化点
    // 先插入为base64，保存文档时，修改为url
    edit.insertImageBlock(imageSource: data);

    // Capture a photo.
    // final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    // Pick a video.
    // final XFile? galleryVideo =
    //     await picker.pickVideo(source: ImageSource.gallery);

    // Capture a video.
    // final XFile? cameraVideo =
    //     await picker.pickVideo(source: ImageSource.camera);

    // Pick multiple images.
    // final List<XFile> images = await picker.pickMultiImage();

    // Pick singe image or video.
    // final XFile? media = await picker.pickMedia();

    // Pick multiple images and videos.
    // final List<XFile> medias = await picker.pickMultipleMedia();
  }

  String getEditOrigin() {
    return jsonEncode(edit.document.toDelta().toJson());
  }

  bool isEditorEmpty() {
    String g = jsonEncode(edit.document.toDelta().toJson());
    if (g.isEmpty) {
      return true;
    }
    return g != "[{\"insert\":\"\n\"}]";
  }

  String getEditPlainText() {
    return edit.document.toPlainText();
  }
}
