import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:whispering_time/pages/doc/model.dart';
import 'package:whispering_time/pages/group/model.dart';
import 'package:whispering_time/pages/group/manager.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/pages/doc/setting.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:provider/provider.dart';

class EditPage extends StatefulWidget {
  final Doc doc;
  final Group group;
  final Function(Doc) onSave;
  final Function() onDelete;

  const EditPage({
    required this.doc,
    required this.group,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController titleController;
  late QuillController quillController;
  late FocusNode _focusNode;
  late int level;
  late DocConfig config;
  late DateTime createAt;
  bool isLevelSelected = true;
  bool _isEditingTitle = false;
  Timer? _autoSaveTimer;
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    titleController = TextEditingController(text: widget.doc.title);

    // 初始化富文本编辑器
    if (widget.doc.content.isNotEmpty) {
      quillController = QuillController(
        document: Document.fromJson(jsonDecode(widget.doc.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      quillController = QuillController.basic();
    }

    // 监听文档变化，拦截图片插入
    quillController.document.changes.listen(_onDocumentChange);

    level = widget.doc.level;
    config = widget.doc.config;
    createAt = widget.doc.createAt;

    // For brand new docs, jump directly into title editing for clarity.
    _isEditingTitle = widget.doc.id.isEmpty;
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isEditingTitle) {
        save();
      }
    });
  }

  void _touchGroupActivity({bool exitBuffer = true}) {
    if (!mounted) return;
    context
        .read<GroupsManager>()
        .touch(gid: widget.group.id, exitBuffer: exitBuffer);
    widget.group.updateAt = DateTime.now();
    if (exitBuffer && widget.group.isManualBufTime()) {
      widget.group.overAt = null;
    }
  }

  // 监听文档变化，处理图片上传
  void _onDocumentChange(DocChange event) async {
    if (event.source == ChangeSource.local) {
      _startAutoSaveTimer();
    }
    // 获取文档的所有内容
    final delta = quillController.document.toDelta();

    // 遍历查找图片
    int offset = 0;
    for (int i = 0; i < delta.length; i++) {
      final op = delta.elementAt(i);

      if (op.data is Map && (op.data as Map).containsKey('image')) {
        final imageData = op.data as Map;
        final imageSource = imageData['image'] as String;

        // 如果是本地文件路径，则上传
        if (imageSource.startsWith('file://') ||
            (!imageSource.startsWith('http://') &&
                !imageSource.startsWith('https://'))) {
          // 去除 file:// 前缀
          String localPath = imageSource;
          if (localPath.startsWith('file://')) {
            localPath = localPath.substring(7);
          }

          try {
            // 读取图片文件
            final file = File(localPath);
            if (!await file.exists()) {
              log.w('图片文件不存在: $localPath');
              offset += (op.length ?? 1);
              continue;
            }

            final bytes = await file.readAsBytes();

            // 判断图片类型
            IMGType imgType;
            if (localPath.toLowerCase().endsWith('.png')) {
              imgType = IMGType.png;
            } else {
              imgType = IMGType.jpg;
            }

            // 上传图片
            final req = RequestPostImage(type: imgType, data: bytes);
            final res = await Http(gid: widget.group.id).postImage(req);

            if (res.isOK) {
              // 删除旧的图片引用并插入文件名（不是完整URL）
              quillController.document.delete(offset, 1);
              quillController.document
                  .insert(offset, BlockEmbed.image(res.name));

              log.i('图片上传成功，文件名: ${res.name}');
            } else {
              log.e('图片上传失败: ${res.msg}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('图片上传失败: ${res.msg}')),
                );
              }
            }
          } catch (e) {
            log.e('处理图片上传失败: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('图片上传失败: $e')),
              );
            }
          }
        }
      }

      offset += (op.length ?? 1);
    }
  }

  void paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      final text = data.text!;
      final selection = quillController.selection;
      if (!selection.isValid) {
        return;
      }
      quillController.replaceText(
        selection.start,
        selection.end - selection.start,
        text,
        null,
      );
      quillController.updateSelection(
        TextSelection.collapsed(offset: selection.start + text.length),
        ChangeSource.local,
      );
    }
  }

  void _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;

    if (_isEditingTitle) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('保存标题'),
          content: Text('标题已修改，是否保存？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('不保存'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('保存'),
            ),
          ],
        ),
      );

      if (result == true) {
        await save();
      }

      if (result != null) {
        if (!mounted) return;
        setState(() {
          _canPop = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
      return;
    }
    await save();
    if (!mounted) return;
    setState(() {
      _canPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 获取自定义的嵌入构建器，自动拼接图片服务器地址
  List<EmbedBuilder> _getCustomEmbedBuilders() {
    return [
      // 自定义图片构建器
      _CustomImageEmbedBuilder(),
      // 添加其他默认的嵌入构建器（视频等）
      ...(kIsWeb
              ? FlutterQuillEmbeds.editorWebBuilders()
              : FlutterQuillEmbeds.editorBuilders())
          .where((builder) => builder.key != 'image'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: _isEditingTitle
              ? TextField(
                  controller: titleController,
                  autofocus: true,
                  style: Theme.of(context).textTheme.titleLarge,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: '未命名的标题',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) {
                    save();
                    setState(() {
                      _isEditingTitle = false;
                    });
                  },
                )
              : GestureDetector(
                  onTap: () {
                    if (!widget.group.isFreezedOrBuf() ||
                        widget.doc.id.isEmpty) {
                      setState(() {
                        _isEditingTitle = true;
                      });
                    }
                  },
                  child: Text(
                    titleController.text.isEmpty
                        ? '未命名的标题'
                        : titleController.text,
                    style: TextStyle(
                      color: titleController.text.isEmpty ? Colors.grey : null,
                    ),
                  ),
                ),
          actions: [
            if (_isEditingTitle)
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  save();
                  setState(() {
                    _isEditingTitle = false;
                  });
                },
                tooltip: '保存标题',
              )
            else ...[
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'settings') {
                    settings();
                  } else if (value == 'export') {
                    export();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    if (!widget.group.isFreezedOrBuf())
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 20, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('设置'),
                          ],
                        ),
                      ),
                    PopupMenuItem<String>(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('导出'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题和分级选择
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 分级选择按钮
                  TextButton(
                    onPressed: widget.group.isFreezedOrBuf() &&
                            widget.doc.id.isNotEmpty
                        ? null
                        : _showLevelDialog,
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(Level.l[level]),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // 工具栏
              if (config.isShowTool!)
                QuillSimpleToolbar(
                  controller: quillController,
                  config: QuillSimpleToolbarConfig(
                    color: Colors.transparent,
                    toolbarSize: 35,
                    multiRowsDisplay: false,
                    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                  ),
                ),

              // 富文本编辑器 - 使用自适应高度
              Expanded(
                child: Container(
                  decoration: !quillController.document.isEmpty()
                      ? null
                      : BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.keyV,
                          meta: true): paste,
                      const SingleActivator(LogicalKeyboardKey.keyV,
                          control: true): paste,
                    },
                    child: QuillEditor(
                      controller: quillController,
                      focusNode: _focusNode,
                      scrollController: ScrollController(),
                      config: QuillEditorConfig(
                        embedBuilders: _getCustomEmbedBuilders(),
                        scrollable: true,
                        autoFocus: false,
                        expands: false,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示分级选择对话框
  void _showLevelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择分级'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(Level.l.length, (index) {
              return ListTile(
                title: Text(Level.l[index]),
                leading: RadioGroup(
                  groupValue: level,
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        level = value;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Radio<int>(
                    value: index,
                  ),
                ),
                onTap: () {
                  setState(() {
                    level = index;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
        );
      },
    );
  }

  // 保存文档
  Future<void> save() async {
    String content = jsonEncode(quillController.document.toDelta().toJson());
    String plainText = quillController.document.toPlainText();
    bool persisted = false;

    // 如果有ID，更新文档
    if (widget.doc.id.isNotEmpty) {
      RequestPutDoc req = RequestPutDoc();
      bool hasChanges = false;

      if (content != widget.doc.content) {
        req.content = content;
        req.plainText = plainText;
        hasChanges = true;
      }
      if (titleController.text != widget.doc.title) {
        req.title = titleController.text;
        hasChanges = true;
      }
      if (level != widget.doc.level) {
        req.level = level;
        hasChanges = true;
      }

      if (hasChanges) {
        final res =
            await Http(gid: widget.group.id, did: widget.doc.id).putDoc(req);
        if (res.isNotOK) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败')),
            );
          }
          return;
        }
        persisted = true;
        // Update local doc state
        widget.doc.content = content;
        widget.doc.plainText = plainText;
        widget.doc.title = titleController.text;
        widget.doc.level = level;
      }
    } else {
      // 创建新文档
      final req = RequestPostDoc(
        content: content,
        plainText: plainText,
        title: titleController.text,
        level: level,
        createAt: createAt,
        config: config,
      );
      final ret = await Http(gid: widget.group.id).postDoc(req);
      if (ret.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败')),
          );
        }
        return;
      }
      persisted = true;
      widget.doc.id = ret.id;
      // Update local doc state
      widget.doc.content = content;
      widget.doc.plainText = plainText;
      widget.doc.title = titleController.text;
      widget.doc.level = level;
    }

    // 返回更新后的文档
    Doc updatedDoc = Doc(
      id: widget.doc.id,
      title: titleController.text,
      content: content,
      plainText: plainText,
      level: level,
      createAt: createAt,
      updateAt: DateTime.now(),
      config: config,
    );

    if (persisted) {
      _touchGroupActivity();
    }

    widget.onSave(updatedDoc);
  }

  // 打开设置弹窗
  void settings() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DocSettingsDialog(
        gid: widget.group.id,
        did: widget.doc.id.isEmpty ? null : widget.doc.id,
        createAt: createAt,
        config: config,
      ),
    );

    if (result != null) {
      // 如果删除了文档
      if (result['deleted'] == true) {
        _touchGroupActivity();
        widget.onDelete();
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      // 如果有修改
      if (result['changed'] == true) {
        if (widget.doc.id.isNotEmpty) {
          RequestPutDoc req = RequestPutDoc(createAt: result['createAt']);
          req.config = result['config'];
          final res =
              await Http(gid: widget.group.id, did: widget.doc.id).putDoc(req);
          if (res.isNotOK) {
            return;
          }

          _touchGroupActivity();
        }

        setState(() {
          if (result['createAt'] != null) {
            createAt = result['createAt'];
          }
          if (result['config'] != null) {
            config = result['config'];
          }
        });
      }
    }
  }

  // 导出文档
  void export() {
    showDialog(
      context: context,
      builder: (context) => Export(
        ResourceType.doc,
        gid: widget.group.id,
        did: widget.doc.id,
        doc: ExportData(
          content: jsonEncode(quillController.document.toDelta().toJson()),
          title: titleController.text,
          plainText: quillController.document.toPlainText(),
          level: level,
          createAt: createAt,
        ),
      ),
    );
  }
}

class _CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    var imageSource = embedContext.node.value.data as String;

    // 如果不是完整URL（不以http开头），则拼接服务器地址
    if (!imageSource.startsWith('http://') &&
        !imageSource.startsWith('https://')) {
      final serverAddress = Config.instance.serverAddress;
      final uid = Config.instance.uid;
      imageSource = '$serverAddress/image/$uid/$imageSource';
    }

    // 使用默认的图片widget显示
    return Image.network(
      imageSource,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
                SizedBox(height: 8),
                Text('图片加载中...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        );
      },
    );
  }
}
