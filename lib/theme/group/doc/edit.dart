import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:whispering_time/http.dart';
import 'package:whispering_time/env.dart';
import 'setting.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
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
  // controller
  TextEditingController titleEdit = TextEditingController();
  QuillController edit = QuillController.basic();

  DocConfigration config = DocConfigration();
  bool chooseLeveled = false;
  bool _isSelected = true;
  bool isTitleSubmited = true;
  int level = 0;
  late DateTime crtime;
  bool get keepEditText => widget.content == getEditOrigin();
  bool get keepTitleText => titleEdit.text == widget.title;
  bool get keepLevel => widget.level == level;
  bool get keepCRTime => widget.crtime == crtime;
  bool get keepConfig => widget.config == config;
  bool get noCreateDoc =>
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

            // 富文本
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 30.0, right: 30.0),
                child: QuillEditor(
                  controller: edit,
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  configurations: QuillEditorConfigurations(
                    // sharedConfigurations: QuillSharedConfigurations(
                    //   extraConfigurations: {
                    //     QuillSharedExtensionsConfigurations.key:
                    //         QuillSharedExtensionsConfigurations(
                    //       assetsPrefix: '666', // Defaults to `assets`
                    //     ),
                    //   },
                    // ),
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
    if (!noCreateDoc) {
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

  void backPage() async {
    if (keepEditText &&
        (keepTitleText) && // 控件中的文字是默认标题或原始标题
        keepLevel) {
      if (keepCRTime && keepConfig) {
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
    }

    // 有变化，更新文档
    if (widget.id!.isNotEmpty) {
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
    if (noCreateDoc) {
      Navigator.of(context).pop(nocreateDoc(failed: false));
    }

    // 有变化，创建文档
    final ret = await createDoc();
    if (ret.state.isErr) {
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
      level: level,
      crtime: crtime,
      config: config,
    );
    final ret = await Http(gid: widget.gid).postDoc(req);
    if (ret.isNotOK) {
      return nocreateDoc(failed: true);
    }
    return LastPageDoc(
      state: LastPage.create,
      content: getEditOrigin(),
      plainText: getEditPlainText(),
      id: ret.id,
      title: titleEdit.text,
      level: level,
      crtime: req.crtime,
      uptime: crtime,
      config: config,
    );
  }

  Future<LastPageDoc> updateDoc(RequestPutDoc req) async {
    final res = await Http(gid: widget.gid, did: widget.id!).putDoc(req);
    if (res.isNotOK) {
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
      level: level,
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

  // void updateImage() {
  //   List<Operation> ops = edit.document.toDelta().toList();

  //   for (Operation op in ops) {
  //     if (!(op.isInsert && op.value is Embed && op.value.type == 'image')) {
  //       continue;
  //     }
  //     String base64Image = op.value.data;
  //     Uint8List imageBytes = base64Decode(base64Image);
  //     // 现在你可以使用 imageBytes 了
  //   }
  // }

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
    // ... 使用 imageFile 显示图片
    final String extension = p.extension(imageFile.path);
    String name = UUID.create;
    final bytes = await imageFile.readAsBytes();

    if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.JPG' ||
        extension == '.JPEG') {
      name += ".jpg";
      print("图片类型jpg");
    } else if (extension == '.png' || extension == '.PNG') {
      name += ".png";
      print("图片类型png");
    } else {
      print('其他文件类型');
      return;
    }
    ResponsePostImage res =
        await Http().postImage(RequestPostImage(name: name, data: bytes));
    if (!res.ok) {
      log.e('创建图片失败');
      return;
    }

    // 地址使用
    // [{"insert":{"image":"dataUrl"}}]",
    edit.insertImageBlock(
        imageSource: "http://${Settings().getServerAddress()}/image/$name");

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

  String getEditPlainText() {
    return edit.document.toPlainText();
  }
}
