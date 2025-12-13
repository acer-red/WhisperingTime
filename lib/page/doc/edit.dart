import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/doc/zk_model.dart';
import 'package:whispering_time/page/group/model.dart';
import 'package:whispering_time/page/group/manager.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:whispering_time/service/scale/scale_service.dart';
import 'package:whispering_time/service/scale/scale_service_grpc.dart';
import 'package:whispering_time/page/doc/edit_embed.dart';
import 'package:whispering_time/page/doc/edit_page_body.dart';
import 'package:whispering_time/util/export.dart';
import 'package:whispering_time/util/secure.dart';
import 'package:whispering_time/util/time.dart';
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

class _DocDrawerExpansionTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _DocDrawerExpansionTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(leadingIcon),
      title: Text(title),
      subtitle: Text(subtitle),
      children: children,
    );
  }
}

class _EditPageState extends State<EditPage> {
  late TextEditingController titleController;
  late QuillController quillController;
  late TextEditingController _markdownController;
  late FocusNode _focusNode;
  late int level;
  late DocConfig config;
  late DateTime createAt;
  late final DocumentModel _documentModel;
  late final ScaleService _scaleService;
  bool _isEditingTitle = false;
  Timer? _autoSaveTimer;
  bool _canPop = false;
  Future<bool>? _creatingDoc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showScalePanel = true;
  bool _showImageTextPanel = true;

  ImageTextLayout _imageTextLayout = ImageTextLayout.mixed;
  TextFormat _textFormat = TextFormat.richText;

  bool get _canEditDocSettings {
    if (widget.doc.id.isEmpty) return true;
    return !widget.group.isFreezedOrBuf();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    titleController = TextEditingController(text: widget.doc.title);

    _scaleService = ScaleServiceGrpc();

    // ZKA payload: scales-only JSON list (preferred), with backward-compatible parsing.
    final decoded = ZkDocPayload.tryDecodeJson(widget.doc.content);
    final scales = ZkDocPayload.extractScales(decoded);
    _documentModel = DocumentModel(scales: scales);

    // 富文本不再参与持久化（仅保留 UI，不保存到服务器）
    quillController = QuillController.basic();

    // Markdown editor controller (stores plain text; can be synced with quill)
    _markdownController = TextEditingController(
      text: quillController.document.toPlainText().trimRight(),
    );

    // 监听文档变化，拦截图片插入
    quillController.document.changes.listen(_onDocumentChange);

    level = widget.doc.level;
    config = widget.doc.config;
    createAt = widget.doc.createAt;

    // Default to non-editing title state even for brand new docs; user can tap to edit.
    _isEditingTitle = false;
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    _markdownController.dispose();
    _focusNode.dispose();
    _documentModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        key: _scaffoldKey,
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
              IconButton(
                tooltip: '菜单',
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ],
        ),
        endDrawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // 关键UI: 文档抽屉
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          '文档',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _DocDrawerExpansionTile(
                        leadingIcon: Icons.layers_outlined,
                        title: '分级',
                        subtitle: Level.l[level],
                        children: [
                          RadioGroup<int>(
                            groupValue: level,
                            onChanged: (v) {
                              if (!_canEditDocSettings) return;
                              if (v == null) return;
                              setState(() {
                                level = v;
                              });
                            },
                            child: Column(
                              children: List.generate(
                                Level.l.length,
                                (index) => RadioListTile<int>(
                                  value: index,
                                  title: Text(Level.l[index]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('创建时间'),
                        trailing: Text(
                          Time.string(createAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        enabled: _canEditDocSettings,
                        onTap: _canEditDocSettings ? _pickCreateTime : null,
                      ),

                      const Divider(height: 1),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          '模块',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.straighten),
                        value: _showScalePanel,
                        onChanged: (v) {
                          setState(() {
                            _showScalePanel = v;
                          });
                        },
                        title: const Text('刻度面板'),
                        subtitle: const Text('显示/隐藏刻度面板'),
                      ),
                      // 图文面板
                      SwitchListTile(
                        secondary: const Icon(Icons.image_outlined),
                        value: _showImageTextPanel,
                        onChanged: (v) {
                          setState(() {
                            _showImageTextPanel = v;
                          });
                        },
                        title: const Text(
                          '图文面板',
                        ),
                        subtitle: const Text('显示/隐藏图文面板'),
                      ),
                      if (_showImageTextPanel) ...[
                        // 图文排版
                        _DocDrawerExpansionTile(
                          leadingIcon: Icons.view_quilt_outlined,
                          title: '图文排版',
                          subtitle: _imageTextLayout == ImageTextLayout.mixed
                              ? '混排'
                              : '分割',
                          children: [
                            RadioGroup<ImageTextLayout>(
                              groupValue: _imageTextLayout,
                              onChanged: (v) {
                                if (v == null) return;
                                _setImageTextLayout(v);
                              },
                              child: Column(
                                children: const [
                                  RadioListTile<ImageTextLayout>(
                                    value: ImageTextLayout.mixed,
                                    title: Text('混排'),
                                    subtitle: Text('公众号文章，邮件等'),
                                  ),
                                  RadioListTile<ImageTextLayout>(
                                    value: ImageTextLayout.separated,
                                    title: Text('分割'),
                                    subtitle: Text('朋友圈、微博等'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_imageTextLayout == ImageTextLayout.mixed) ...[
                          _DocDrawerExpansionTile(
                            leadingIcon: Icons.text_fields,
                            title: '文本格式',
                            subtitle: _textFormat == TextFormat.richText
                                ? '富文本'
                                : 'Markdown',
                            children: [
                              RadioGroup<TextFormat>(
                                groupValue: _textFormat,
                                onChanged: (v) {
                                  if (v == null) return;
                                  _setTextFormat(v);
                                },
                                child: Column(
                                  children: const [
                                    RadioListTile<TextFormat>(
                                      value: TextFormat.richText,
                                      title: Text('富文本'),
                                      subtitle: Text('支持图片、格式、工具栏'),
                                    ),
                                    RadioListTile<TextFormat>(
                                      value: TextFormat.markdown,
                                      title: Text('Markdown'),
                                      subtitle: Text('纯文本输入，适合快速记录'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            secondary: const Icon(Icons.build),
                            title: const Text('显示工具栏'),
                            subtitle: const Text('含图片上传'),
                            value: config.isShowTool ?? false,
                            onChanged: (_canEditDocSettings &&
                                    _textFormat == TextFormat.richText)
                                ? (value) => _setShowToolbar(value)
                                : null,
                          ),
                        ],
                      ],
                      const Divider(height: 1),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          '其他',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.download_outlined),
                        title: Text('导出'),
                        trailing: Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          Navigator.of(context).maybePop();
                          dialogExport();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    '删除页面',
                    style: TextStyle(color: Colors.red),
                  ),
                  enabled: _canEditDocSettings,
                  onTap: _canEditDocSettings ? _deleteFromDrawer : null,
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 面板
              Expanded(
                child: ChangeNotifierProvider.value(
                  value: _documentModel,
                  child: EditPageBody(
                    quillController: quillController,
                    focusNode: _focusNode,
                    showToolbar: _imageTextLayout == ImageTextLayout.mixed &&
                        _textFormat == TextFormat.richText &&
                        (config.isShowTool ?? false),
                    onPaste: paste,
                    embedBuilders: _getCustomEmbedBuilders(),
                    scaleService: _scaleService,
                    showScalePanel: _showScalePanel,
                    showImageTextPanel: _showImageTextPanel,
                    imageTextLayout: _imageTextLayout,
                    textFormat: _textFormat,
                    markdownController: _markdownController,
                    onImageTextLayoutChanged: _setImageTextLayout,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    if (_documentModel.scales.isNotEmpty) {
      return true;
    }
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

  void _setImageTextLayout(ImageTextLayout next) {
    if (_imageTextLayout == next) return;
    setState(() {
      _imageTextLayout = next;
    });
  }

  void _setTextFormat(TextFormat next) {
    if (_textFormat == next) return;

    // Sync content between editors so switching format reflects latest edits.
    if (next == TextFormat.markdown) {
      _markdownController.text =
          quillController.document.toPlainText().trimRight();
    } else {
      final text = _markdownController.text;
      final currentLen = quillController.document.length;
      if (currentLen > 0) {
        quillController.replaceText(0, currentLen, text, null);
      } else {
        quillController.document.insert(0, text);
      }
      quillController.updateSelection(
        TextSelection.collapsed(offset: quillController.document.length),
        ChangeSource.local,
      );
    }

    setState(() {
      _textFormat = next;
    });
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

  // 显示分级选择对话框

  // 保存文档
  Future<void> save() async {
    // Persist scales only: JSON string of scale instances (no rich text, no version field).
    final content = jsonEncode(
      _documentModel.scales.map((s) => s.toJson()).toList(growable: false),
    );
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

    // Rich text is not persisted anymore, so skip rich-based file cleanup.

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

    final docContent = content ??
        jsonEncode(
          ZkDocPayload.build(
            rich: quillController.document.toDelta().toJson(),
            scales: _documentModel.scales,
          ),
        );
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

  Future<void> _setShowToolbar(bool value) async {
    setState(() {
      config.isShowTool = value;
    });

    if (widget.doc.id.isEmpty) return;

    final res = await Grpc(gid: widget.group.id, did: widget.doc.id)
        .putDoc(RequestUpdateDoc(config: DocConfig(isShowTool: value)));
    if (res.isNotOK) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置失败')),
      );
      return;
    }

    _touchGroupActivity();
  }

  Future<void> _pickCreateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: createAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );

    pickedDate ??= createAt;

    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(createAt),
    );

    final DateTime newCreateAt;
    if (pickedTime == null) {
      newCreateAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        createAt.hour,
        createAt.minute,
        0,
      );
    } else {
      newCreateAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        0,
      );
    }

    if (createAt == newCreateAt) return;

    setState(() {
      createAt = newCreateAt;
    });

    if (widget.doc.id.isEmpty) return;

    final res = await Grpc(gid: widget.group.id, did: widget.doc.id)
        .putDoc(RequestUpdateDoc(createAt: newCreateAt));
    if (res.isNotOK) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('时间设置失败')),
      );
      return;
    }

    _touchGroupActivity();
  }

  Future<void> _deleteFromDrawer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这篇文档吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (widget.doc.id.isNotEmpty) {
      final res =
          await Grpc(gid: widget.group.id, did: widget.doc.id).deleteDoc();
      if (!mounted) return;
      if (res.isNotOK) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败')),
        );
        return;
      }

      _touchGroupActivity();
    }

    widget.onDelete();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
