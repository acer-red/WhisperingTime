import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/group/model.dart';
import 'package:whispering_time/page/group/manager.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/page/doc/edit_embed.dart';
import 'package:whispering_time/util/export.dart';
import 'package:whispering_time/util/secure.dart';
import 'package:whispering_time/page/doc/setting.dart';
import 'package:whispering_time/util/env.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

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
  Future<bool>? _creatingDoc;

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

    // Default to non-editing title state even for brand new docs; user can tap to edit.
    _isEditingTitle = false;
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

  // 检查正文是否包含有效内容（文本或图片等嵌入）
  bool _hasMeaningfulContent() {
    if (quillController.document.toPlainText().trim().isNotEmpty) {
      return true;
    }

    final delta = quillController.document.toDelta();
    for (final op in delta.toList()) {
      final data = op.data;
      if (data is Map &&
          (data.containsKey('image') || data.containsKey('video'))) {
        return true;
      }
    }

    return false;
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

      if (op.data is Map &&
          ((op.data as Map).containsKey('image') ||
              (op.data as Map).containsKey('video'))) {
        final imageData = op.data as Map;
        final source = imageData['image'] ?? imageData['video'];
        if (source is! String) {
          offset += (op.length ?? 1);
          continue;
        }
        final String imageSource = source;

        // 新文档首次插入媒体时，先创建文档以获取 did，避免上传报错
        if (widget.doc.id.isEmpty) {
          final created = await _ensureDocCreated(force: true);
          if (!created) {
            offset += (op.length ?? 1);
            continue;
          }
        }

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

            final storage = Storage();
            final envelope = await storage.envelopeEncrypt(bytes);
            final metaJson = jsonEncode({
              'filename': p.basename(localPath),
              'mime': imgType == IMGType.png ? 'image/png' : 'image/jpeg',
              'size': envelope.cipherText.length,
            });
            final encryptedMeta = await storage.encryptWithDataKey(
                envelope.dataKey, utf8.encode(metaJson));

            if (!mounted) return;

            final themeId = context.read<GroupsManager>().tid;
            final presign = await Grpc(
                    tid: themeId, gid: widget.group.id, did: widget.doc.id)
                .presignUploadFile(
              filename: p.basename(localPath),
              mime: imgType == IMGType.png ? 'image/png' : 'image/jpeg',
              size: envelope.cipherText.length,
              encryptedKey: envelope.encryptedKey,
              encryptedMetadata: encryptedMeta,
            );

            if (!mounted) return;

            if (!presign.isOK || presign.uploadUrl == null) {
              log.e('获取上传URL失败: ${presign.msg}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('图片上传失败: ${presign.msg}')),
                );
              }
              offset += (op.length ?? 1);
              continue;
            }

            final putResp = await http.put(
              Uri.parse(presign.uploadUrl!),
              headers: {
                'Content-Type':
                    imgType == IMGType.png ? 'image/png' : 'image/jpeg'
              },
              body: envelope.cipherText,
            );

            if (!mounted) return;

            if (putResp.statusCode >= 400) {
              log.e('上传图片失败: HTTP ${putResp.statusCode}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('图片上传失败: HTTP ${putResp.statusCode}')),
                );
              }
              offset += (op.length ?? 1);
              continue;
            }

            final fileId = presign.fileId ?? '';
            quillController.document.delete(offset, 1);
            quillController.document
                .insert(offset, BlockEmbed.image('file:$fileId'));

            log.i('图片上传成功，fileId: $fileId');
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
      CustomImageEmbedBuilder(),
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
                    dialogSettings();
                  } else if (value == 'export') {
                    dialogExport();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
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
                    onPressed: widget.doc.id.isEmpty
                        ? _showLevelDialog
                        : (widget.group.isFreezedOrBuf()
                            ? null
                            : _showLevelDialog),
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
    final oldFileIds = _extractFileIds(widget.doc.content);
    final newFileIds = _extractFileIds(content);
    final removedFileIds = oldFileIds.difference(newFileIds);
    bool persisted = false;
    final bool hasMeaningfulContent = _hasMeaningfulContent();

    // 新文档：若有标题或内容则先创建获取 did
    if (widget.doc.id.isEmpty &&
        (titleController.text.trim().isNotEmpty || hasMeaningfulContent)) {
      final created = await _ensureDocCreated(force: true, content: content);
      if (!created) return;
    }

    // 如果有ID，更新文档
    if (widget.doc.id.isNotEmpty) {
      RequestUpdateDoc req = RequestUpdateDoc();
      bool hasChanges = false;

      if (content != widget.doc.content) {
        hasChanges = true;
      }
      if (titleController.text != widget.doc.title) {
        hasChanges = true;
      }
      if (level != widget.doc.level) {
        hasChanges = true;
      }

      if (hasChanges) {
        // 必须同时更新所有加密字段，因为putDoc会生成新的密钥
        req.content = content;
        req.title = titleController.text;
        req.level = level;

        final res =
            await Grpc(gid: widget.group.id, did: widget.doc.id).putDoc(req);
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
        widget.doc.title = titleController.text;
        widget.doc.level = level;
      }
    } else {
      // 无标题且无内容，不落库，仅更新本地
      if (!hasMeaningfulContent && titleController.text.trim().isEmpty) {
        widget.doc.title = titleController.text;
        widget.doc.level = level;
        widget.doc.content = content;
      }
    }

    if (!persisted) {
      return;
    }

    await _deleteRemovedFiles(removedFileIds);

    // 返回更新后的文档
    Doc updatedDoc = Doc(
      id: widget.doc.id,
      title: titleController.text,
      content: content,
      level: level,
      createAt: createAt,
      updateAt: DateTime.now(),
      config: config,
    );

    _touchGroupActivity();
    widget.onSave(updatedDoc);
  }

  Future<bool> _ensureDocCreated({bool force = false, String? content}) async {
    if (widget.doc.id.isNotEmpty) return true;
    if (_creatingDoc != null) return await _creatingDoc!;

    final hasContent = _hasMeaningfulContent();
    final hasTitle = titleController.text.trim().isNotEmpty;
    if (!force && !hasContent && !hasTitle) return false;

    final completer = Completer<bool>();
    _creatingDoc = completer.future;

    final docContent =
        content ?? jsonEncode(quillController.document.toDelta().toJson());
    final req = RequestCreateDoc(
      content: docContent,
      title: titleController.text,
      level: level,
      createAt: createAt,
      config: config,
    );

    try {
      final ret = await Grpc(gid: widget.group.id).createDoc(req);
      if (ret.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败: ${ret.msg}')),
          );
        }
        completer.complete(false);
        return false;
      }

      widget.doc.id = ret.id;
      widget.doc.content = docContent;
      widget.doc.title = titleController.text;
      widget.doc.level = level;

      final updatedDoc = Doc(
        id: widget.doc.id,
        title: titleController.text,
        content: docContent,
        level: level,
        createAt: createAt,
        updateAt: DateTime.now(),
        config: config,
      );

      _touchGroupActivity();
      widget.onSave(updatedDoc);
      completer.complete(true);
      return true;
    } catch (e) {
      completer.complete(false);
      rethrow;
    } finally {
      _creatingDoc = null;
    }
  }

  Set<String> _extractFileIds(String contentJson) {
    if (contentJson.isEmpty) return {};
    try {
      final data = jsonDecode(contentJson);
      if (data is! List) return {};
      final ids = <String>{};
      for (final op in data) {
        if (op is Map && op['insert'] is Map) {
          final insertMap = op['insert'] as Map;
          if (insertMap['image'] is String) {
            final src = insertMap['image'] as String;
            if (src.startsWith('file:')) {
              ids.add(src.substring(5));
            }
          }
        }
      }
      return ids;
    } catch (_) {
      return {};
    }
  }

  Future<void> _deleteRemovedFiles(Set<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      try {
        await Grpc(gid: widget.group.id, did: widget.doc.id).deleteFile(id);
      } catch (_) {
        // best effort; ignore
      }
    }
  }

  // 弹窗: 设置
  void dialogSettings() async {
    final groupsManager = context.read<GroupsManager>();

    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
              value: groupsManager,
              child: DocSettingsDialog(
                gid: widget.group.id,
                did: widget.doc.id.isEmpty ? null : widget.doc.id,
                createAt: createAt,
                config: config,
              ),
            ));

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
          RequestUpdateDoc req = RequestUpdateDoc(createAt: result['createAt']);
          req.config = result['config'];
          final res =
              await Grpc(gid: widget.group.id, did: widget.doc.id).putDoc(req);
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

  // 弹窗: 导出
  void dialogExport() {
    showDialog(
      context: context,
      builder: (context) => Export(
        ResourceType.doc,
        gid: widget.group.id,
        did: widget.doc.id,
        doc: ExportData(
          content: jsonEncode(quillController.document.toDelta().toJson()),
          title: titleController.text,
          level: level,
          createAt: createAt,
        ),
      ),
    );
  }
}
