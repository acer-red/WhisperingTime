import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';

import 'package:whispering_time/page/doc/zk_model.dart';
import 'package:whispering_time/page/doc/scale_template_creator_dialog.dart';
import 'package:whispering_time/service/scale/scale_service.dart';

enum ImageTextLayout {
  mixed,
  separated,
}

enum TextFormat {
  richText,
  markdown,
}

class EditPageBody extends StatefulWidget {
  final QuillController quillController;
  final FocusNode focusNode;
  final bool showToolbar;
  final VoidCallback onPaste;
  final List<EmbedBuilder> embedBuilders;
  final ScaleService scaleService;
  final bool showScalePanel;
  final bool showImageTextPanel;
  final ImageTextLayout imageTextLayout;
  final TextFormat textFormat;
  final TextEditingController markdownController;
  final ValueChanged<ImageTextLayout>? onImageTextLayoutChanged;

  const EditPageBody({
    super.key,
    required this.quillController,
    required this.focusNode,
    required this.showToolbar,
    required this.onPaste,
    required this.embedBuilders,
    required this.scaleService,
    this.showScalePanel = true,
    this.showImageTextPanel = true,
    this.imageTextLayout = ImageTextLayout.mixed,
    this.textFormat = TextFormat.richText,
    required this.markdownController,
    this.onImageTextLayoutChanged,
  });

  @override
  State<EditPageBody> createState() => _EditPageBodyState();
}

class _EditPageBodyState extends State<EditPageBody> {
  bool _isImageTextEditorEmpty = true;
  bool _isScaleEditMode = false;

  bool _hasTappedImageTextPanel = false;
  bool _showImageTextLayoutSelector = false;

  bool _computeIsEditorEmpty(Document doc) {
    final plain = doc.toPlainText().trim();
    final hasEmbed = doc
        .toDelta()
        .toList()
        .any((op) => op.data is Map<String, dynamic> || op.data is Map);
    return plain.isEmpty && !hasEmbed;
  }

  bool _computeIsMarkdownEmpty(String text) {
    return text.trim().isEmpty;
  }

  void _onEditorChanged() {
    final next = widget.textFormat == TextFormat.markdown
        ? _computeIsMarkdownEmpty(widget.markdownController.text)
        : _computeIsEditorEmpty(widget.quillController.document);
    if (next != _isImageTextEditorEmpty) {
      setState(() {
        _isImageTextEditorEmpty = next;
      });
    }
  }

  Widget _buildCenteredAddButton({
    required ThemeData theme,
    required VoidCallback onPressed,
    String? label,
  }) {
    final cs = theme.colorScheme;
    final color = cs.onSurfaceVariant.withValues(alpha: 0.55);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressed,
            iconSize: 44,
            icon: Icon(Icons.add, color: color),
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isImageTextEditorEmpty = widget.textFormat == TextFormat.markdown
        ? _computeIsMarkdownEmpty(widget.markdownController.text)
        : _computeIsEditorEmpty(widget.quillController.document);
    widget.quillController.addListener(_onEditorChanged);
    widget.markdownController.addListener(_onEditorChanged);
  }

  @override
  void dispose() {
    widget.quillController.removeListener(_onEditorChanged);
    widget.markdownController.removeListener(_onEditorChanged);
    super.dispose();
  }

  Future<void> _openTemplatePicker() async {
    final model = context.read<DocumentModel>();

    final selected = await showDialog<ScaleTemplatePlain>(
      context: context,
      builder: (ctx) {
        var templatesFuture = _loadTemplatesPlain();

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> refresh() async {
              setState(() {
                templatesFuture = _loadTemplatesPlain();
              });
            }

            return AlertDialog(
              title: const Text('添加刻度'),
              content: SizedBox(
                width: 360,
                height: 360,
                child: FutureBuilder<List<ScaleTemplatePlain>>(
                  future: templatesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data ?? const <ScaleTemplatePlain>[];

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final t = items[i];
                        final unitPart = (t.hasUnit && t.unit.trim().isNotEmpty)
                            ? ' · 单位: ${t.unit.trim()}'
                            : '';
                        return ListTile(
                          title: Text(t.title.isEmpty ? '(未命名)' : t.title),
                          subtitle: Text(
                            "记录方式: ${t.interactionMode == ScaleInteractionMode.selection ? '选项选择' : '手动填写'} · "
                            "数据格式: ${t.dataType == ScaleDataType.text ? '文字' : '数值'}$unitPart",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: '编辑',
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () async {
                                  final updated =
                                      await showDialog<ScaleTemplatePlain>(
                                    context: ctx,
                                    builder: (dCtx) =>
                                        ScaleTemplateCreatorDialog(
                                      scaleService: widget.scaleService,
                                      initialTemplate: t,
                                    ),
                                  );
                                  if (updated != null) {
                                    await refresh();
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: '删除',
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: ctx,
                                    builder: (cCtx) => AlertDialog(
                                      title: const Text('删除刻度模板'),
                                      content: Text(
                                        '确定删除“${t.title.isEmpty ? '(未命名)' : t.title}”？',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(cCtx).pop(false),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(cCtx).pop(true),
                                          child: const Text('删除'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed != true) return;

                                  await widget.scaleService
                                      .deleteScaleTemplate(id: t.id);
                                  await refresh();
                                },
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(ctx).pop(t),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _openCreateTemplate();
                  },
                  child: const Text('新建模板'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      model.addScaleFromTemplate(selected);
    }
  }

  Future<List<ScaleTemplatePlain>> _loadTemplatesPlain() async {
    final encrypted = await widget.scaleService.listScaleTemplates();
    final plain = <ScaleTemplatePlain>[];
    for (final record in encrypted) {
      final meta =
          await widget.scaleService.decryptMetadata(record.encryptedMetadata);
      plain.add(ScaleTemplatePlain.fromMetadata(id: record.id, metadata: meta));
    }
    return plain;
  }

  Future<void> _openCreateTemplate() async {
    final created = await showDialog<ScaleTemplatePlain>(
      context: context,
      builder: (ctx) => ScaleTemplateCreatorDialog(
        scaleService: widget.scaleService,
      ),
    );

    if (!mounted) return;
    if (created != null) {
      context.read<DocumentModel>().addScaleFromTemplate(created);
    }
  }

  Widget _buildScalePanel(ThemeData theme) {
    final cs = theme.colorScheme;
    final panelRadius = BorderRadius.circular(12);

    return Consumer<DocumentModel>(
      builder: (context, model, _) {
        if (model.scales.isEmpty) {
          return _DashedBorder(
            color: cs.outline.withValues(alpha: 0.9),
            radius: 12,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: panelRadius,
              ),
              padding: const EdgeInsets.all(12),
              child: _buildCenteredAddButton(
                theme: theme,
                onPressed: _openTemplatePicker,
                label: '添加刻度',
              ),
            ),
          );
        }

        if (!_isScaleEditMode) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _isScaleEditMode = true;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 24,
                  runSpacing: 8,
                  children: model.scales.map((s) {
                    final unitText = (s.hasUnit ? s.unit : '').trim();
                    final displayTitle = s.title.isEmpty ? '(未命名)' : s.title;
                    final displayValue = s.currentValue?.isEmpty ?? true
                        ? '未填写'
                        : s.currentValue!;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          displayValue,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (unitText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            unitText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }

        return _DashedBorder(
          color: cs.outline.withValues(alpha: 0.9),
          radius: 12,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: panelRadius,
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: model.scales.length,
                    itemBuilder: (context, index) {
                      final s = model.scales[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == model.scales.length - 1 ? 0 : 12,
                        ),
                        child: _ScaleInstanceTile(
                          title: s.title,
                          interactionMode: s.interactionMode,
                          dataType: s.dataType,
                          options: s.options,
                          unit: s.hasUnit ? s.unit : null,
                          value: s.currentValue,
                          onChanged: (v) => model.setScaleValue(index, v),
                          onRemove: () => model.removeScaleAt(index),
                          textColor: cs.onSurface,
                          isEditing: true,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _openTemplatePicker,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('添加'),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurfaceVariant,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: model.scales.every((s) {
                        if (s.interactionMode != ScaleInteractionMode.input) {
                          return true;
                        }
                        return (s.currentValue?.trim().isNotEmpty ?? false);
                      })
                          ? () {
                              setState(() {
                                _isScaleEditMode = false;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('完成'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageTextPanel(ThemeData theme) {
    final cs = theme.colorScheme;
    final panelRadius = BorderRadius.circular(12);

    Widget buildLayoutSelector() {
      final hint = cs.onSurfaceVariant.withValues(alpha: 0.75);

      Widget tile({
        required ImageTextLayout value,
        required IconData icon,
        required String title,
        required String desc,
      }) {
        final titleColor = cs.onSurface;
        final iconColor = cs.onSurfaceVariant;
        final descColor = hint;

        return InkWell(
          onTap: () {
            setState(() {
              _showImageTextLayoutSelector = false;
            });
            widget.onImageTextLayoutChanged?.call(value);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: iconColor),
                const SizedBox(width: 16),
                SizedBox(
                  width: 160,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: descColor,
                          height: 1.2,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tile(
              value: ImageTextLayout.mixed,
              icon: Icons.view_quilt_outlined,
              title: '图文混排',
              desc: '公众号文章、邮件等',
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: cs.outlineVariant.withValues(alpha: 0.45),
            ),
            tile(
              value: ImageTextLayout.separated,
              icon: Icons.view_column_outlined,
              title: '图文分隔',
              desc: '朋友圈、微博等',
            ),
          ],
        ),
      );
    }

    if (_isImageTextEditorEmpty && !_hasTappedImageTextPanel) {
      return _DashedBorder(
        color: cs.outline.withValues(alpha: 0.9),
        radius: 12,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: panelRadius,
          ),
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _hasTappedImageTextPanel = true;
                _showImageTextLayoutSelector = true;
              });
            },
            child: _buildCenteredAddButton(
              theme: theme,
              onPressed: () {
                setState(() {
                  _hasTappedImageTextPanel = true;
                  _showImageTextLayoutSelector = true;
                });
              },
              label: '添加图文',
            ),
          ),
        ),
      );
    }

    if (_showImageTextLayoutSelector) {
      return _DashedBorder(
        color: cs.outline.withValues(alpha: 0.9),
        radius: 12,
        child: Material(
          color: cs.surfaceContainerHighest,
          borderRadius: panelRadius,
          clipBehavior: Clip.hardEdge,
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minHeight: 260),
            child: buildLayoutSelector(),
          ),
        ),
      );
    }

    Widget editorBody;
    if (widget.imageTextLayout == ImageTextLayout.separated) {
      editorBody = Center(
        child: Text(
          '分割模式（开发中）',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      );
    } else if (widget.textFormat == TextFormat.markdown) {
      editorBody = Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: widget.markdownController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          if (_isImageTextEditorEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '在这里开始输入…\n支持 Markdown 纯文本',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      editorBody = Stack(
        children: [
          Positioned.fill(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(
                  LogicalKeyboardKey.keyV,
                  meta: true,
                ): widget.onPaste,
                const SingleActivator(
                  LogicalKeyboardKey.keyV,
                  control: true,
                ): widget.onPaste,
              },
              child: QuillEditor(
                controller: widget.quillController,
                focusNode: widget.focusNode,
                scrollController: ScrollController(),
                config: QuillEditorConfig(
                  embedBuilders: widget.embedBuilders,
                  scrollable: true,
                  autoFocus: false,
                  expands: true,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),
          if (_isImageTextEditorEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '在这里开始输入…\n支持粘贴、图片等',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return _DashedBorder(
      color: cs.outline.withValues(alpha: 0.9),
      radius: 12,
      child: ClipRRect(
        borderRadius: panelRadius,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: panelRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showToolbar)
                QuillSimpleToolbar(
                  controller: widget.quillController,
                  config: QuillSimpleToolbarConfig(
                    color: cs.surface,
                    toolbarSize: 35,
                    multiRowsDisplay: false,
                    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                  ),
                ),
              Expanded(child: editorBody),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final children = <Widget>[];
    if (widget.showScalePanel) {
      children.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: _buildScalePanel(theme),
        ),
      );
    }
    if (widget.showScalePanel && widget.showImageTextPanel) {
      children.add(const SizedBox(height: 12));
    }
    if (widget.showImageTextPanel) {
      children.add(
        Expanded(
          child: _buildImageTextPanel(theme),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ScaleInstanceTile extends StatelessWidget {
  final String title;
  final ScaleInteractionMode interactionMode;
  final ScaleDataType dataType;
  final List<String> options;
  final String? unit;
  final String? value;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRemove;
  final Color textColor;
  final bool isEditing;

  const _ScaleInstanceTile({
    required this.title,
    required this.interactionMode,
    required this.dataType,
    required this.options,
    required this.unit,
    required this.value,
    required this.onChanged,
    required this.onRemove,
    required this.textColor,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSelectionMode = interactionMode == ScaleInteractionMode.selection;
    final unitText = (unit ?? '').trim();
    final displayTitle = title.isEmpty ? '(未命名)' : title;

    if (!isEditing) {
      final displayValue = value?.isEmpty ?? true ? '未填写' : value!;
      return Row(
        children: [
          Text(
            '$displayTitle: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            displayValue,
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (unitText.isNotEmpty)
            Text(
              ' $unitText',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
        ],
      );
    }

    final inputDecoration = InputDecoration(
      isDense: true,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      suffixText: unitText.isEmpty ? null : unitText,
      suffixStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    Widget inputWidget;
    if (isSelectionMode) {
      inputWidget = DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        decoration: inputDecoration,
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(growable: false),
        onChanged: options.isEmpty ? null : onChanged,
      );
    } else {
      inputWidget = TextFormField(
        initialValue: value,
        decoration: inputDecoration,
        keyboardType:
            dataType == ScaleDataType.number ? TextInputType.number : null,
        onChanged: (v) => onChanged(v.trim().isEmpty ? null : v.trim()),
      );
    }

    return Row(
      children: [
        Text(
          displayTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: inputWidget,
        ),
        const Spacer(),
        IconButton(
          onPressed: onRemove,
          icon: Icon(Icons.delete_outline,
              size: 20, color: theme.colorScheme.error),
          tooltip: '移除',
        ),
      ],
    );
  }
}

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;

  const _DashedBorder({
    required this.child,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(radius),
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dash = 6.0;
    const gap = 4.0;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
