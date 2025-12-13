import 'package:flutter/material.dart';

import 'package:whispering_time/page/doc/zk_model.dart';
import 'package:whispering_time/service/scale/scale_service.dart';

class ScaleTemplateCreatorDialog extends StatefulWidget {
  final ScaleService scaleService;
  final ScaleTemplatePlain? initialTemplate;

  const ScaleTemplateCreatorDialog({
    super.key,
    required this.scaleService,
    this.initialTemplate,
  });

  @override
  State<ScaleTemplateCreatorDialog> createState() =>
      _ScaleTemplateCreatorDialogState();
}

class _ScaleTemplateCreatorDialogState
    extends State<ScaleTemplateCreatorDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _optionsController = TextEditingController();
  final _unitController = TextEditingController();

  ScaleInteractionMode _interactionMode = ScaleInteractionMode.selection;
  ScaleDataType _dataType = ScaleDataType.text;
  bool _hasUnit = false;

  bool _isSubmitting = false;

  bool get _isSelectionMode =>
      _interactionMode == ScaleInteractionMode.selection;

  bool get _isEditMode => widget.initialTemplate != null;

  @override
  void initState() {
    super.initState();

    final t = widget.initialTemplate;
    if (t != null) {
      _titleController.text = t.title;
      _interactionMode = t.interactionMode;
      _dataType = t.dataType;
      _optionsController.text = t.options.join(',');
      _hasUnit = t.hasUnit;
      _unitController.text = t.unit;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _optionsController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final title = _titleController.text.trim();

    final options = _isSelectionMode
        ? _optionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false)
        : const <String>[];

    setState(() {
      _isSubmitting = true;
    });

    try {
      final unit = _hasUnit ? _unitController.text.trim() : '';
      final metadata = <String, dynamic>{
        'title': title,
        'type': 'fixed',
        'interaction_mode': _interactionMode.name,
        'data_type': _dataType.name,
        'options': options,
        'has_unit': _hasUnit,
        'unit': unit,
      };

      final encryptedMetadata =
          await widget.scaleService.encryptMetadata(metadata);

      late final String id;
      if (_isEditMode) {
        final existingId = widget.initialTemplate!.id;
        await widget.scaleService.updateScaleTemplate(
          id: existingId,
          encryptedMetadata: encryptedMetadata,
        );
        id = existingId;
      } else {
        final record = await widget.scaleService.createScaleTemplate(
          encryptedMetadata: encryptedMetadata,
        );
        id = record.id;
      }

      if (!mounted) return;
      Navigator.of(context).pop(
        ScaleTemplatePlain.fromMetadata(id: id, metadata: metadata),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? '编辑刻度模板' : '新建刻度模板'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '刻度名称',
                  hintText: '例如：心情、体重、今日花费',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return '请填写刻度名称';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: '记录方式',
                child: SegmentedButton<ScaleInteractionMode>(
                  segments: const [
                    ButtonSegment(
                      value: ScaleInteractionMode.selection,
                      label: Text('选项选择'),
                    ),
                    ButtonSegment(
                      value: ScaleInteractionMode.input,
                      label: Text('手动填写'),
                    ),
                  ],
                  selected: <ScaleInteractionMode>{_interactionMode},
                  onSelectionChanged: (s) {
                    final next = s.first;
                    setState(() {
                      _interactionMode = next;
                      if (!_isSelectionMode) _optionsController.clear();
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: '数据格式',
                child: SegmentedButton<ScaleDataType>(
                  segments: const [
                    ButtonSegment(
                      value: ScaleDataType.text,
                      label: Text('文字'),
                    ),
                    ButtonSegment(
                      value: ScaleDataType.number,
                      label: Text('数值'),
                    ),
                  ],
                  selected: <ScaleDataType>{_dataType},
                  onSelectionChanged: (s) {
                    final next = s.first;
                    setState(() {
                      _dataType = next;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: '单位',
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('不需要')),
                    ButtonSegment(value: true, label: Text('需要')),
                  ],
                  selected: <bool>{_hasUnit},
                  onSelectionChanged: (s) {
                    final next = s.first;
                    setState(() {
                      _hasUnit = next;
                      if (!_hasUnit) _unitController.clear();
                    });
                  },
                ),
              ),
              if (_hasUnit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: '单位内容',
                    hintText: '例如：kg、元、次',
                  ),
                  textInputAction: _isSelectionMode
                      ? TextInputAction.next
                      : TextInputAction.done,
                  validator: (v) {
                    if (!_hasUnit) return null;
                    if ((v ?? '').trim().isEmpty) return '请填写单位';
                    return null;
                  },
                ),
              ],
              if (_isSelectionMode) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: '预设选项 (用逗号分隔)',
                    hintText: '开心,难过,平淡',
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (!_isSelectionMode) return null;
                    final options = (v ?? '')
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList(growable: false);
                    if (options.isEmpty) return '请至少填写 1 个预设选项';
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(
            _isSubmitting
                ? (_isEditMode ? '保存中…' : '创建中…')
                : (_isEditMode ? '保存' : '创建'),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
