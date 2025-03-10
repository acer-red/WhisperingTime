import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:whispering_time/services/http/self.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/Isar/config.dart';
import 'setting.dart';
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
  DateTime crtime = DateTime.now();
  String id = "";
  Delta? _previousFullDelta; // 保存上一次的印迹内容

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
        selection: const TextSelection.collapsed(offset: 0),
      );
      edit.document.changes.listen((change) {
        editChange();
      });
    }
    _previousFullDelta = edit.document.toDelta();
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
            IconButton(
                onPressed: () => dialogExport(), icon: Icon(Icons.share)),
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
                    child: Text(Level.string(level)),
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

            // 富文本工具栏（含图片）
            if (config.isShowTool!)
              QuillSimpleToolbar(
                controller: edit,
                config: QuillSimpleToolbarConfig(
                  customButtons: [
                    // 添加图片
                    QuillToolbarCustomButtonOptions(
                      icon: Icon(Icons.image),
                      onPressed: () => dialogSelectImage(context, edit),
                    ),
                    // 测试按钮
                    QuillToolbarCustomButtonOptions(
                      icon: Icon(Icons.radio_button_checked),
                      onPressed: () {
                        print(getEditOrigin());
                      },
                    )
                  ],
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
                  config: QuillEditorConfig(
                    
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

  // 检测印迹内容的变化
  void editChange() {
    Delta currentDelta = edit.document.toDelta();

    List<String> preList = _previousFullDelta!.operations
        .where((op) =>
            op.isInsert &&
            op.value is Map &&
            (op.value as Map).containsKey('image'))
        .map((op) => (op.value as Map)['image'] as String)
        .toList();

    List<String> currentList = currentDelta.operations
        .where((op) =>
            op.isInsert &&
            op.value is Map &&
            (op.value as Map).containsKey('image'))
        .map((op) => (op.value as Map)['image'] as String)
        .toList();

    if (preList.length > currentList.length) {
      for (String previousImageUrl in preList) {
        if (!currentList.contains(previousImageUrl)) {
          String deletedImageUrl = previousImageUrl;
          _onImageDeleted(deletedImageUrl);
        }
      }
    }
    _previousFullDelta = currentDelta;

    //  **在检测完成后，更新 _previousFullDelta 为当前的印迹状态，以便下次变化时进行比较**
  }

  // 执行删除图片的逻辑
  void _onImageDeleted(String imageUrl) {
    Http().deleteImage(imageUrl.split('/').last);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('图片 $imageUrl 已被删除!')),
    // );
  }

  // 保存印迹
  Future<bool> saveDoc() async {
    checkImage();
    // 创建新印迹
    if (widget.id == null) {
      final ret = await createDoc();
      if (ret.isNotOK) {
        print("创建印迹失败");
        return false;
      }
      setState(() {
        id = ret.id;
      });
      return true;
    }

    // 更新现有印迹
    final ret = await updateDoc();
    if (ret.isNotOK) {
      print("更新印迹失败");
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

    // 印迹内容有变化
    if (!(keepEditText && keepTitleText && keepLevel)) {
      bool ok = await saveDoc();
      if (ok) {
        log.i("保存成功");
        if (mounted) {
          return Navigator.of(context).pop(LastPageDoc(
              state: widget.id == null ? LastPage.create : LastPage.change,
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

    // 印迹内容无变化
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
      // 印迹内容无变化，配置有变化
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
          RequestPutDoc req = RequestPutDoc(crtime: ret.crtime);
          req.config = ret.config;
          final res = await Http(gid: widget.gid, did: widget.id!).putDoc(req);
          if (res.isNotOK) {
            print("更新配置错误");
            break;
          }
        }
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
        print("返回并删除印迹");
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
    RequestPutDoc req = RequestPutDoc();
    if (!keepEditText) {
      print("印迹内容有变化");
      req.plainText = getEditPlainText();
      req.content = getEditOrigin();
    }
    if (!keepTitleText) {
      print("标题有变化");
      req.title = titleEdit.text;
    }
    if (!keepLevel) {
      print("等级有变化");
      req.level = level;
    }
    final res = await Http(gid: widget.gid, did: widget.id!).putDoc(req);
    return res;
  }

  // 打开对话框，导出窗口
  void dialogExport() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Export(ResourceType.doc,
            title: "导出印迹",
            doc: ExportData(
                content: getEditOrigin(),
                title: titleEdit.text,
                plainText: getEditPlainText(),
                level: level,
                crtime: crtime));
      },
    );
  }

  Doc getLatestDoc() {
    return Doc(
      title: titleEdit.text,
      content: getEditOrigin(),
      plainText: getEditPlainText(),
      level: level,
      crtime: crtime,
      uptime: widget.uptime,
      config: config,
      id: id,
    );
  }

  void checkImage() {
    uploadImage();
    deleteImage();
  }

  void uploadImage() async {
    final delta = edit.document.toDelta();
    List<Operation> ops = delta.toList();

    for (int i = 0; i < ops.length; i++) {
      var op = ops[i];
      if (!(op.isInsert && op.value is Map)) {
        continue;
      }
      final map = op.value as Map;
      if (!map.containsKey('image')) {
        continue;
      }

      String base64Image = map['image'].toString();

      IMGType type = IMGType.png;
      if (base64Image.startsWith("data:image/png;base64,")) {
        base64Image = base64Image.replaceFirst("data:image/png;base64,", "");
      } else if (base64Image.startsWith("data:image/jpg;base64,")) {
        base64Image = base64Image.replaceFirst("data:image/jpg;base64,", "");
        type = IMGType.jpg;
      } else {
        continue;
      }
      Uint8List bytes = base64Decode(base64Image);

      ResponsePostImage res =
          await Http().postImage(RequestPostImage(type: type, data: bytes));
      if (res.isNotOK) {
        log.e('创建图片失败');
        return;
      }
      final String newValue =
          "http://${Config.instance.serverAddress}/image/${res.name}";

      ops[i] = Operation.fromJson({
        "insert": {"image": newValue}
      });

      edit.document = Document.fromDelta(
          Delta.fromJson(ops.map((e) => e.toJson()).toList()));
    }
  }

  void deleteImage() async {
    List<String> links = [];
    // 从widget.content中提取图片链接
    final old = Delta.fromJson(jsonDecode(widget.content));
    List<Operation> ops = old.toList();
    for (int i = 0; i < ops.length; i++) {
      var op = ops[i];
      if (!(op.isInsert && op.value is Map)) {
        continue;
      }
      final map = op.value as Map;
      if (!map.containsKey('image')) {
        continue;
      }
      final url = map['image'].toString();
      if (url.startsWith("http")) {
        links.add(url);
      }
    }

    final delta = Delta.fromJson(edit.document.toDelta().toJson());
    List<Operation> newops = delta.toList();
    for (int i = 0; i < newops.length; i++) {
      var op = newops[i];
      if (!(op.isInsert && op.value is Map)) {
        continue;
      }
      final map = op.value as Map;
      if (!map.containsKey('image')) {
        continue;
      }
      final newValue = map['image'].toString();
      if (!newValue.startsWith("http")) {
        continue;
      }
      if (links.contains(newValue)) {
        continue;
      }
      final name = newValue.split('/').last;
      final res = await Http().deleteImage(name);
      if (res.isNotOK) {
        log.e('删除图片失败');
      }
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    pickerLocalImage();
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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

  pickerLocalImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    final String extension = p.extension(image.path).toLowerCase();
    final bytes = await image.readAsBytes();
    // final String data;
    IMGType type = IMGType.png;
    if (extension == '.jpg' || extension == '.jpeg') {
      type = IMGType.jpg;
      // data = "data:image/jpg;base64,${base64Encode(bytes)}";
    } else if (extension == '.png') {
      // data = "data:image/png;base64,${base64Encode(bytes)}";
    } else {
      print('其他文件类型');
      return;
    }
    ResponsePostImage res =
        await Http().postImage(RequestPostImage(type: type, data: bytes));

    // 插入在线链接
    edit.insertImageBlock(
        imageSource:
            "http://${Config.instance.serverAddress}/image/${res.name}");

    // 插入base64
    // edit.insertImageBlock(imageSource:data);

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
