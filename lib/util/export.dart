import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/service/grpc/grpc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/util/time.dart';
import 'package:file_picker/file_picker.dart';

// class Content {
//   String ? rich;
//   Content(this.rich);
// }
class ExportData {
  String content;
  String title;
  int level;
  DateTime createAt;

  String get levelString => Level.string(level);
  String get createAtString => DateFormat('yyyy-MM-dd HH:mm').format(createAt);
  // String get updateAtString =>DateFormat('yyyy-MM-dd HH:mm').format(updateAt);

  ExportData({
    required this.content,
    required this.title,
    required this.level,
    required this.createAt,
  });
}

class Export extends StatefulWidget {
  final String? tid;
  final String? gid;
  final String? did;
  final ExportData? doc;
  final ResourceType t;

  const Export(
    this.t, {
    this.tid,
    this.gid,
    this.did,
    this.doc,
  });

  @override
  State<Export> createState() => _Export();
}

enum ResourceType { theme, group, doc }

enum ExportScope { theme, group, doc }

enum ExportFormat { pdf, text }

enum ThemeSelectionMode { all, manual }

enum IntegrateType { multiple, one }

class _Export extends State<Export> {
  final Set<String> _selectedThemeIds = {};
  ThemeSelectionMode _themeMode = ThemeSelectionMode.all;
  ExportFormat _format = ExportFormat.pdf;
  IntegrateType _integrate = IntegrateType.multiple;
  late ExportScope _scope;

  List<XTheme> _themes = [];
  bool _loading = true;
  bool _submitting = false;
  String? _errorMsg;
  int _currentStep = 0; // 0: scope, 1: target, 2: format, 3: integrate

  String? _selectedThemeForGroup;
  String? _selectedGroupId;

  String? _selectedThemeForDoc;
  String? _selectedGroupForDoc;
  String? _selectedDocId;

  bool get _scopeLocked => widget.t != ResourceType.theme || widget.tid != null;
  bool get _themeLocked => widget.tid != null;
  bool get _groupLocked => widget.gid != null && widget.t != ResourceType.group;
  bool get _docLocked => widget.doc != null;

  @override
  void initState() {
    super.initState();
    _scope = _mapScope(widget.t);
    _integrate =
        _scope == ExportScope.doc ? IntegrateType.one : IntegrateType.multiple;
    _loadThemes();
  }

  ExportScope _mapScope(ResourceType t) {
    switch (t) {
      case ResourceType.group:
        return ExportScope.group;
      case ResourceType.doc:
        return ExportScope.doc;
      case ResourceType.theme:
      default:
        return ExportScope.theme;
    }
  }

  Future<void> _loadThemes() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final res = await Grpc().getThemesAndDoc();
    if (!mounted) {
      return;
    }

    if (res.isNotOK) {
      setState(() {
        _loading = false;
        _errorMsg = "加载主题失败";
      });
      return;
    }

    setState(() {
      _themes = res.data;
      _loading = false;
    });

    _applyInitialSelection();
  }

  void _applyInitialSelection() {
    // 主题范围
    if (_themeLocked && widget.tid != null) {
      _themeMode = ThemeSelectionMode.manual;
      _selectedThemeIds
        ..clear()
        ..add(widget.tid!);
    }

    // 分组范围
    if (_scope == ExportScope.group) {
      if (widget.gid != null) {
        _selectedGroupId = widget.gid;
        final foundTid = _findThemeIdByGroup(widget.gid);
        _selectedThemeForGroup =
            foundTid ?? widget.tid ?? _themes.firstOrNull?.tid;
      } else {
        _selectedThemeForGroup = widget.tid ?? _themes.firstOrNull?.tid;
        _selectedGroupId = _firstGroupId(_selectedThemeForGroup);
      }
    }

    // 日志范围
    if (_scope == ExportScope.doc) {
      _selectedThemeForDoc ??= widget.tid ?? _findThemeIdByGroup(widget.gid);
      _selectedGroupForDoc ??= widget.gid ?? _findGroupIdByDoc(widget.did);
      _selectedDocId ??=
          widget.did ?? _firstDocId(_selectedThemeForDoc, _selectedGroupForDoc);
    }

    if (_isScopeReady() && _scopeLocked) {
      _currentStep = 1;
      if (_isTargetReady() &&
          (_docLocked || (_themeLocked && _scope == ExportScope.theme))) {
        _currentStep = 2;
      }
    }

    setState(() {});
  }

  String? _findThemeIdByGroup(String? gid) {
    if (gid == null) {
      return null;
    }
    for (final theme in _themes) {
      if (theme.groups.any((g) => g.gid == gid)) {
        return theme.tid;
      }
    }
    return null;
  }

  String? _findGroupIdByDoc(String? did) {
    if (did == null) {
      return null;
    }
    for (final theme in _themes) {
      for (final group in theme.groups) {
        if (group.docs.any((doc) => doc.did == did)) {
          return group.gid;
        }
      }
    }
    return null;
  }

  String? _firstGroupId(String? tid) {
    if (tid == null) {
      return null;
    }
    final theme = _themes.firstWhere(
      (item) => item.tid == tid,
      orElse: () => _themes.isNotEmpty
          ? _themes.first
          : XTheme(tid: '', name: '', groups: const []),
    );
    return theme.groups.isNotEmpty ? theme.groups.first.gid : null;
  }

  String? _firstDocId(String? tid, String? gid) {
    if (tid == null || gid == null) {
      return null;
    }
    final theme = _themes.firstWhereOrNull((item) => item.tid == tid);
    final group = theme?.groups.firstWhereOrNull((g) => g.gid == gid);
    return group?.docs.isNotEmpty == true ? group!.docs.first.did : null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _errorMsg != null
            ? Center(child: Text(_errorMsg!))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepContent(),
                ],
              );

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        _currentStepTitle(),
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        child: body,
      ),
      actions: _loading
          ? null
          : [
              TextButton(
                onPressed: _currentStep == 0 ? null : _prevStep,
                child: const Text('上一步'),
              ),
              ElevatedButton(
                onPressed: _canProceed() ? _nextOrSubmit : null,
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_currentStep == 3 ? '开始导出' : '下一步'),
              ),
            ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildScopeStep();
      case 1:
        return _buildTargetStep();
      case 2:
        return _buildFormatStep();
      case 3:
      default:
        return _buildIntegrateStep();
    }
  }

  String _currentStepTitle() {
    switch (_currentStep) {
      case 0:
        return '选择导出范围';
      case 1:
        return '选择导出对象';
      case 2:
        return '选择导出类型';
      case 3:
        return '选择导出方式';
      default:
        return '';
    }
  }

  Widget _buildScopeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionCard(_buildScopeRadios()),
      ],
    );
  }

  Widget _buildTargetStep() {
    switch (_scope) {
      case ExportScope.theme:
        return _sectionCard(_buildThemeScope());
      case ExportScope.group:
        return _sectionCard(_buildGroupScope());
      case ExportScope.doc:
        return _sectionCard(_buildDocScope());
    }
  }

  Widget _buildScopeRadios() {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outlineVariant.withValues(alpha: 0.35);
    return _GuideList(
      dividerColor: dividerColor,
      children: [
        _OptionTile(
          title: '按照主题',
          subtitle: '选择全部主题或指定主题导出',
          icon: Icons.topic_outlined,
          selected: _scope == ExportScope.theme,
          disabled: _scopeLocked,
          onTap: () => _changeScope(ExportScope.theme),
          colorScheme: colorScheme,
        ),
        _OptionTile(
          title: '按照分组',
          subtitle: '先选主题，再选分组',
          icon: Icons.layers_outlined,
          selected: _scope == ExportScope.group,
          disabled: _scopeLocked,
          onTap: () => _changeScope(ExportScope.group),
          colorScheme: colorScheme,
        ),
        _OptionTile(
          title: '按照日志',
          subtitle: '先选主题，再选分组和印迹',
          icon: Icons.article_outlined,
          selected: _scope == ExportScope.doc,
          disabled: _scopeLocked,
          onTap: () => _changeScope(ExportScope.doc),
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  void _changeScope(ExportScope scope) {
    setState(() {
      _scope = scope;
      _integrate =
          scope == ExportScope.doc ? IntegrateType.one : IntegrateType.multiple;
      _currentStep = 1; // move forward to target selection once scope is chosen
    });
  }

  Widget _buildThemeScope() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              _SegmentTab(
                label: '全部主题',
                selected: _themeMode == ThemeSelectionMode.all,
                onTap: _themeLocked
                    ? null
                    : () => setState(() => _themeMode = ThemeSelectionMode.all),
              ),
              _SegmentTab(
                label: '手动选择',
                selected: _themeMode == ThemeSelectionMode.manual,
                onTap: _themeLocked
                    ? null
                    : () {
                        setState(() {
                          _themeMode = ThemeSelectionMode.manual;
                          if (_selectedThemeIds.isEmpty && _themes.isNotEmpty) {
                            _selectedThemeIds.add(_themes.first.tid);
                          }
                        });
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_themeMode == ThemeSelectionMode.manual)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _themes
                .map(
                  (theme) => FilterChip(
                    label: Text(theme.name),
                    selected: _selectedThemeIds.contains(theme.tid),
                    onSelected: _themeLocked
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected) {
                                _selectedThemeIds.add(theme.tid);
                              } else {
                                _selectedThemeIds.remove(theme.tid);
                              }
                            });
                          },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildGroupScope() {
    final groups = _themeGroups(_selectedThemeForGroup);
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择主题', style: titleStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _themes
              .map(
                (theme) => ChoiceChip(
                  label: Text(theme.name),
                  selected: _selectedThemeForGroup == theme.tid,
                  onSelected: _themeLocked
                      ? null
                      : (selected) {
                          if (selected) {
                            setState(() {
                              _selectedThemeForGroup = theme.tid;
                              _selectedGroupId = _firstGroupId(theme.tid);
                            });
                          }
                        },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        Text('选择分组', style: titleStyle),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          const Text('该主题下暂无分组')
        else
          SizedBox(
            height: 140,
            child: SingleChildScrollView(
              child: RadioGroup<String>(
                groupValue: _selectedGroupId,
                onChanged: (value) {
                  if (_groupLocked || value == null) {
                    return;
                  }
                  setState(() {
                    _selectedGroupId = value;
                  });
                },
                child: Column(
                  children: groups
                      .map(
                        (group) => RadioListTile<String>(
                          value: group.gid,
                          title: Text(group.name),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocScope() {
    final groups = _themeGroups(_selectedThemeForDoc);
    final docs = _groupDocs(_selectedThemeForDoc, _selectedGroupForDoc);
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择主题', style: titleStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _themes
              .map(
                (theme) => ChoiceChip(
                  label: Text(theme.name),
                  selected: _selectedThemeForDoc == theme.tid,
                  onSelected: _themeLocked
                      ? null
                      : (selected) {
                          if (selected) {
                            setState(() {
                              _selectedThemeForDoc = theme.tid;
                              _selectedGroupForDoc = _firstGroupId(theme.tid);
                              _selectedDocId = _firstDocId(
                                  _selectedThemeForDoc, _selectedGroupForDoc);
                            });
                          }
                        },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        Text('选择分组', style: titleStyle),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          const Text('该主题下暂无分组')
        else
          Wrap(
            spacing: 8,
            children: groups
                .map(
                  (group) => ChoiceChip(
                    label: Text(group.name),
                    selected: _selectedGroupForDoc == group.gid,
                    onSelected: _groupLocked
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() {
                                _selectedGroupForDoc = group.gid;
                                _selectedDocId = _firstDocId(
                                    _selectedThemeForDoc, _selectedGroupForDoc);
                              });
                            }
                          },
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
        Text('选择印迹', style: titleStyle),
        const SizedBox(height: 8),
        if (_docLocked && widget.doc != null)
          Text(widget.doc!.title.isEmpty ? '无题' : widget.doc!.title)
        else if (docs.isEmpty)
          const Text('该分组下暂无印迹')
        else
          SizedBox(
            height: 140,
            child: SingleChildScrollView(
              child: RadioGroup<String>(
                groupValue: _selectedDocId,
                onChanged: (value) {
                  if (_docLocked || value == null) {
                    return;
                  }
                  setState(() {
                    _selectedDocId = value;
                  });
                },
                child: Column(
                  children: docs
                      .map(
                        (doc) => RadioListTile<String>(
                          value: doc.did,
                          title: Text(doc.title.isEmpty ? '无题' : doc.title),
                          subtitle: Text(
                              '${doc.levelString} · ${doc.createAtString}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: null,
      child: child,
    );
  }

  List<XGroup> _themeGroups(String? tid) {
    return _themes.firstWhereOrNull((t) => t.tid == tid)?.groups ??
        const <XGroup>[];
  }

  List<XDoc> _groupDocs(String? tid, String? gid) {
    final theme = _themes.firstWhereOrNull((t) => t.tid == tid);
    return theme?.groups.firstWhereOrNull((g) => g.gid == gid)?.docs ??
        const <XDoc>[];
  }

  Widget _buildFormatStep() {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outlineVariant.withValues(alpha: 0.35);
    return _sectionCard(
      _GuideList(
        dividerColor: dividerColor,
        children: [
          _OptionTile(
            title: 'PDF',
            subtitle: '保留排版与图片，适合打印与分享',
            icon: Icons.picture_as_pdf_outlined,
            selected: _format == ExportFormat.pdf,
            disabled: false,
            onTap: () => setState(() => _format = ExportFormat.pdf),
            colorScheme: colorScheme,
          ),
          _OptionTile(
            title: '纯文本',
            subtitle: '仅导出文字内容，体积更小',
            icon: Icons.notes_outlined,
            selected: _format == ExportFormat.text,
            disabled: false,
            onTap: () => setState(() => _format = ExportFormat.text),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrateStep() {
    if (_scope == ExportScope.doc) {
      return _sectionCard(const Text('单条印迹将导出为一个文件。'));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outlineVariant.withValues(alpha: 0.35);
    return _sectionCard(
      _GuideList(
        dividerColor: dividerColor,
        children: [
          _OptionTile(
            title: '分开保存',
            subtitle: '每条选定的印迹生成一个独立文件',
            icon: Icons.call_split,
            selected: _integrate == IntegrateType.multiple,
            disabled: false,
            onTap: () => setState(() => _integrate = IntegrateType.multiple),
            colorScheme: colorScheme,
          ),
          _OptionTile(
            title: '合并保存',
            subtitle: '将选定印迹内容合并到同一个文件',
            icon: Icons.merge_type,
            selected: _integrate == IntegrateType.one,
            disabled: false,
            onTap: () => setState(() => _integrate = IntegrateType.one),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  void _prevStep() {
    setState(() {
      _currentStep = (_currentStep - 1).clamp(0, 2);
    });
  }

  void _nextOrSubmit() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      return;
    }
    _submit();
  }

  bool _canProceed() {
    if (_loading || _submitting) {
      return false;
    }
    switch (_currentStep) {
      case 0:
        return _isScopeReady();
      case 1:
        return _isTargetReady();
      case 2:
        return true;
      case 3:
        return _scope != ExportScope.doc || _integrate == IntegrateType.one;
      default:
        return false;
    }
  }

  bool _isTargetReady() {
    switch (_scope) {
      case ExportScope.theme:
        return _themeMode == ThemeSelectionMode.all ||
            _selectedThemeIds.isNotEmpty;
      case ExportScope.group:
        return _selectedThemeForGroup != null && _selectedGroupId != null;
      case ExportScope.doc:
        return _selectedThemeForDoc != null &&
            _selectedGroupForDoc != null &&
            _selectedDocId != null;
    }
  }

  bool _isScopeReady() {
    // scope selection itself is always ready because it has a current value
    return true;
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
    });

    try {
      switch (_scope) {
        case ExportScope.theme:
          await _exportTheme();
          break;
        case ExportScope.group:
          await _exportGroup();
          break;
        case ExportScope.doc:
          await _exportDoc();
          break;
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _exportTheme() async {
    final Set<String>? filters =
        _themeMode == ThemeSelectionMode.manual && _selectedThemeIds.isNotEmpty
            ? _selectedThemeIds
            : null;

    if (_format == ExportFormat.pdf) {
      if (_integrate == IntegrateType.multiple) {
        await PDF().themeSplit(filterThemeIds: filters);
      } else {
        await PDF().themeOne(filterThemeIds: filters);
      }
    } else {
      if (_integrate == IntegrateType.multiple) {
        await TXT().themeSplit(filterThemeIds: filters);
      } else {
        await TXT().themeOne(filterThemeIds: filters);
      }
    }
  }

  Future<void> _exportGroup() async {
    final tid = _selectedThemeForGroup ?? widget.tid;
    final gid = _selectedGroupId ?? widget.gid;

    if (tid == null || gid == null) {
      _showSnack('请选择分组');
      return;
    }

    if (_format == ExportFormat.pdf) {
      if (_integrate == IntegrateType.multiple) {
        await PDF(tid: tid, gid: gid).groupSplit();
      } else {
        await PDF(tid: tid, gid: gid).groupOne();
      }
    } else {
      if (_integrate == IntegrateType.multiple) {
        await TXT(tid: tid, gid: gid).groupSplit();
      } else {
        await TXT(tid: tid, gid: gid).groupOne();
      }
    }
  }

  Future<void> _exportDoc() async {
    final ExportData? data = widget.doc ?? await _loadDocData();
    if (data == null) {
      _showSnack('无法获取印迹内容');
      return;
    }

    if (_format == ExportFormat.pdf) {
      await PDF().docSplit(data);
    } else {
      await TXT().docSplit(data);
    }
  }

  Future<ExportData?> _loadDocData() async {
    if (_selectedGroupForDoc == null || _selectedDocId == null) {
      return null;
    }
    final res = await Grpc(gid: _selectedGroupForDoc).getDocs(null, null);
    if (res.isNotOK) {
      return null;
    }
    final doc = res.data.firstWhereOrNull((item) => item.id == _selectedDocId);
    if (doc == null) {
      return null;
    }
    return ExportData(
      content: doc.content,
      title: doc.title,
      level: doc.level,
      createAt: doc.createAt,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideList extends StatelessWidget {
  final List<Widget> children;
  final Color dividerColor;

  const _GuideList({
    required this.children,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final stacked = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      stacked.add(children[i]);
      if (i != children.length - 1) {
        stacked.add(Divider(
          height: 22,
          thickness: 1,
          color: dividerColor,
        ));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stacked,
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.disabled,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = disabled ? null : onTap;
    final textColor = disabled
        ? colorScheme.onSurface.withValues(alpha: 0.45)
        : colorScheme.onSurface;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: InkWell(
        onTap: effectiveOnTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.04)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? colorScheme.primary : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RadioListTileExample extends StatefulWidget {
  final ValueChanged<int> onValueChanged; // 添加回调函数
  const RadioListTileExample({required this.onValueChanged});

  @override
  State<StatefulWidget> createState() => _RadioListTileExampleState();
}

class _RadioListTileExampleState extends State<RadioListTileExample> {
  int _selectedValue = 0; // 存储选中的值

  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
        groupValue: _selectedValue,
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _selectedValue = value;
            widget.onValueChanged(value);
          });
        },
        child: const Column(
          children: [
            RadioListTile<int>(
              title: Text('保存为多个文件'),
              value: 0,
            ),
            RadioListTile<int>(
              title: Text('保存为一个文件'),
              value: 1,
            ),
          ],
        ));
  }
}

class TXT {
  String? tid;
  String? gid;
  TXT({this.tid, this.gid});

  /// 导出所有主题为多个txt文件
  Future<void> themeSplit({Set<String>? filterThemeIds}) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final res = await Grpc().getThemesAndDoc();
    if (res.isNotOK) {
      return;
    }
    final themes = filterThemeIds == null
        ? res.data
        : res.data
            .where((theme) => filterThemeIds.contains(theme.tid))
            .toList();
    if (themes.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (XTheme theme in themes) {
      for (XGroup group in theme.groups) {
        for (XDoc doc in group.docs) {
          // 文件名: XTheme.name/XGroup.name/XDoc.title
          // 文件内容: XTheme.name/XGroup.name/XDoc.plainText
          final String fileName = doc.title.isEmpty ? "无题" : doc.title;
          final String savePath =
              '$selectedDirectory/枫迹/$currentDate/${theme.name}/${group.name}';

          // 创建文件夹并写入文件
          final filePath = '$savePath/$fileName.txt';

          try {
            await Directory(savePath).create(recursive: true);
          } catch (e) {
            log.e('创建文件夹失败: $e');
            return;
          }

          File file = File(filePath);

          try {
            // await file.writeAsString(doc.content);
            try {
              await file.setLastModified(doc.createAt);
              await file.setLastAccessed(doc.createAt);
            } catch (e) {
              print('修改时间出错: $e');
            }
          } catch (e) {
            print('写入TXT时出错: $e');
            return;
          }
          print("保存成功 $savePath");
        }
      }
    }
    print("保存结束");
  }

  /// 导出所有主题为单个txt文件
  Future<void> themeOne({Set<String>? filterThemeIds}) async {
    final res = await Grpc().getThemesAndDoc();
    if (res.isNotOK) {
      return;
    }
    final themes = filterThemeIds == null
        ? res.data
        : res.data
            .where((theme) => filterThemeIds.contains(theme.tid))
            .toList();
    if (themes.isEmpty) {
      return;
    }

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹--${Time.getCurrentTime()}.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (filePath == null) {
      return;
    }

    Stream<String> dataStream = (() async* {
      for (XTheme theme in themes) {
        for (XGroup group in theme.groups) {
          for (XDoc doc in group.docs) {
            yield "分类: ${theme.name}/${group.name}\n";
            yield "主题: ${doc.title}\n";
            yield "印迹分级: ${doc.levelString}\n";
            yield "创建时间: ${doc.createAtString}\n";
            // yield doc.plainText;
            yield "\n\n\n\n------------------------------------------------------------\n";
          }
        }
      }
    })();

    // 将 String Stream 转换为 List<int> Stream (UTF-8 编码)
    Stream<List<int>> byteStream = dataStream.transform(utf8.encoder);

    await saveSteam(filePath, byteStream);

    print("保存结束");
  }

  /// 导出一个主题下的一个分组的所有印迹为多个TXT文件
  Future<void> groupSplit() async {
    final res = await Grpc(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    String currentDate = Time.getCurrentTime();
    for (DDoc doc in res.data.docs) {
      // 文件名: DGroup.name/DDoc.title
      // 文件内容: DGroup.name/DDoc.content
      final String savePath =
          '$selectedDirectory/枫迹/$currentDate/${res.data.name}';
      print("目录:$savePath,title:${doc.title}");
      try {
        await Directory(savePath).create(recursive: true);
      } catch (e) {
        log.e('创建文件夹失败: $e');
        return;
      }
      try {
        await docSplit(
            ExportData(
                title: doc.title,
                content: "",
                level: doc.level,
                createAt: doc.createAt),
            savePath: savePath);
      } catch (e) {
        log.e('写入TXT失败失败: $e');
        return;
      }
    }
    print("保存结束");
  }

  /// 导出一个主题下的一个分组的所有印迹为单个TXT文件
  Future<void> groupOne() async {
    final res = await Grpc(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹-${res.data.name}-${Time.getCurrentTime()}.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (filePath == null) {
      return;
    }

    Stream<String> dataStream = (() async* {
      for (DDoc doc in res.data.docs) {
        yield "分类: ${res.data.name}\n";
        yield "主题: ${doc.title}\n";
        yield "印迹分级: ${doc.levelString}\n";
        yield "创建时间: ${doc.createAtString}\n";
        // yield doc.plainText;
        yield "\n\n\n\n------------------------------------------------------------\n";
      }
    })();

    // 将 String Stream 转换为 List<int> Stream (UTF-8 编码)
    Stream<List<int>> byteStream = dataStream.transform(utf8.encoder);

    await saveSteam(filePath, byteStream);

    print("保存结束");
  }

  Future<void> docSplit(ExportData doc, {String? savePath}) async {
    if (savePath == null) {
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存路径',
        fileName: doc.title,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (savePath == null) {
        return;
      }
    }
    String fileName =
        "${savePath!}/${doc.title.isEmpty ? "无题" : doc.title}.txt";
    File file = File(fileName);
    await file.writeAsString(doc.content);
    try {
      await file.setLastModified(doc.createAt);
      await file.setLastAccessed(doc.createAt);
    } catch (e) {
      print('修改时间出错: $e');
    }
    print("保存成功：$fileName");
  }

  Future<void> saveSteam(String filePath, Stream<List<int>> dataStream) async {
    File file = File(filePath);
    IOSink sink = file.openWrite(); // 打开文件用于写入，返回 IOSink

    try {
      await dataStream.forEach((chunk) {
        // 遍历数据流中的每个数据块
        sink.add(chunk); // 将数据块添加到 IOSink
      });
    } catch (e) {
      log.e('写入文件出错: $e');
    } finally {
      await sink.close(); // 关闭 IOSink
    }
  }
}

class PDF {
  String? tid;
  String? gid;
  PDF({this.tid, this.gid});

  /// 导出所有主题为多个PDF文件
  Future<void> themeSplit({Set<String>? filterThemeIds}) async {
    print("导出所有主题为多个PDF文件");
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final res = await Grpc().getThemesAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    final themes = filterThemeIds == null
        ? res.data
        : res.data
            .where((theme) => filterThemeIds.contains(theme.tid))
            .toList();
    if (themes.isEmpty) {
      return;
    }
    String currentDate = Time.getCurrentTime();
    for (DTheme theme in themes) {
      for (DGroup group in theme.groups) {
        for (DDoc doc in group.docs) {
          // 文件名: DTheme.name/DGroup.name/DDoc.title
          // 文件内容: DTheme.name/DGroup.name/DDoc.content
          final String savePath =
              '$selectedDirectory/枫迹/$currentDate/${theme.name}/${group.name}';
          print("目录:$savePath,title:${doc.title}");
          try {
            await Directory(savePath).create(recursive: true);
          } catch (e) {
            log.e('创建文件夹失败: $e');
            return;
          }
          try {
            await docSplit(
                ExportData(
                    title: doc.title,
                    content: doc.content,
                    level: doc.level,
                    createAt: doc.createAt),
                savePath: savePath);
          } catch (e) {
            log.e('写入PDF失败失败: $e');
            return;
          }
        }
      }
    }
    log.i("保存结束");
  }

  /// 导出所有主题为单个PDF文件
  Future<void> themeOne({Set<String>? filterThemeIds}) async {
    print("导出所有主题为单个PDF文件");
    final res = await Grpc().getThemesAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    final themes = filterThemeIds == null
        ? res.data
        : res.data
            .where((theme) => filterThemeIds.contains(theme.tid))
            .toList();
    if (themes.isEmpty) {
      return;
    }
    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    List<Map<String, dynamic>> outline = [];
    List<pw.Widget> content = [];

    for (DTheme theme in themes) {
      for (DGroup group in theme.groups) {
        for (DDoc doc in group.docs) {
          // 添加到大纲
          outline.add({
            'title': "${theme.name}/${group.name}/${doc.title}",
            'page': content.length + 2, // +2 是因为首页和大纲页
          });

          // 创建印迹内容
          QuillController edit = QuillController(
              document: Document.fromJson(jsonDecode(doc.content)),
              selection: const TextSelection.collapsed(offset: 0));

          content.add(pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                    level: 0,
                    child: pw.Text(doc.title,
                        style: pw.TextStyle(
                            fontSize: titleFontSize,
                            font: font,
                            fontWeight: pw.FontWeight.bold))),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("印迹分级: ${doc.levelString}",
                        style: pw.TextStyle(
                            fontSize: mainBodyFontSize,
                            font: font,
                            color: PdfColor.fromInt(Colors.grey.hashCode),
                            fontWeight: pw.FontWeight.normal)),
                    pw.Text("创建时间: ${doc.createAtString}",
                        style: pw.TextStyle(
                            fontSize: mainBodyFontSize,
                            font: font,
                            color: PdfColor.fromInt(Colors.grey.hashCode),
                            fontWeight: pw.FontWeight.normal)),
                  ],
                ),
                pw.SizedBox(height: 20),
                ...edit.document.toDelta().toList().map((op) {
                  if (op.isInsert && op.value is String) {
                    String value = op.value.toString();
                    if (value.contains('\n')) {
                      List<String> paragraphs = value.split('\n');
                      return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: paragraphs.map((paragraph) {
                            if (paragraph.trim().isEmpty) {
                              return pw.SizedBox(height: 10);
                            }
                            return pw.Column(
                              children: [
                                pw.Text(paragraph,
                                    style: pw.TextStyle(
                                        fontSize: mainBodyFontSize,
                                        font: font,
                                        fontWeight: pw.FontWeight.normal)),
                                pw.SizedBox(height: 10)
                              ],
                            );
                          }).toList());
                    } else {
                      return pw.Paragraph(
                          text: value,
                          style: pw.TextStyle(
                              fontSize: mainBodyFontSize,
                              font: font,
                              fontWeight: pw.FontWeight.normal));
                    }
                  } else if (op.isInsert && op.value is Map) {
                    final map = op.value as Map;
                    if (map.containsKey('image')) {
                      return _pdfImage(map);
                    } else {
                      log.e("发现未知map类型");
                    }
                  }
                  log.e("发现未知类型");
                  return pw.Paragraph(
                      text: op.value.toString(),
                      style: pw.TextStyle(
                          fontSize: mainBodyFontSize,
                          font: font,
                          fontWeight: pw.FontWeight.normal));
                })
              ]));
        }
      }
    }

    // 首页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("枫迹",
                style: pw.TextStyle(
                    fontSize: 40, font: font, fontWeight: pw.FontWeight.bold)),
          );
        },
      ),
    );

    // 大纲页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("大纲",
                  style: pw.TextStyle(
                      fontSize: 30,
                      font: font,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...outline.map((item) {
                return pw.Text(item['title'],
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: font,
                    ));
              }),
            ],
          );
        },
      ),
    );

    // 内容页
    pdf.addPage(pw.MultiPage(build: (pw.Context context) {
      return content;
    }));

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹-${Time.getCurrentTime()}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (filePath == null) {
      return;
    }

    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    print("保存成功：${file.path}");
  }

  /// 导出一个主题下的一个分组的所有印迹为多个PDF文件
  Future<void> groupSplit() async {
    final res = await Grpc(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    String currentDate = Time.getCurrentTime();
    for (DDoc doc in res.data.docs) {
      // 文件名: DGroup.name/DDoc.title
      // 文件内容: DGroup.name/DDoc.content
      final String savePath =
          '$selectedDirectory/枫迹/$currentDate/${res.data.name}';
      print("目录:$savePath,title:${doc.title}");
      try {
        await Directory(savePath).create(recursive: true);
      } catch (e) {
        log.e('创建文件夹失败: $e');
        return;
      }
      try {
        await docSplit(
            ExportData(
                title: doc.title,
                content: doc.content,
                level: doc.level,
                createAt: doc.createAt),
            savePath: savePath);
      } catch (e) {
        log.e('写入PDF失败失败: $e');
        return;
      }
    }
    log.i("保存结束");
  }

  /// 导出一个主题下的一个分组的所有印迹为单个PDF文件
  Future<void> groupOne() async {
    print("导出一个主题下的一个分组的所有印迹为单个PDF文件");

    final res = await Grpc(tid: tid, gid: gid).getGroupAndDocDetail();
    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }

    if (res.isNotOK) {
      return;
    }
    if (res.data.docs.isEmpty) {
      return;
    }
    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    List<Map<String, dynamic>> outline = [];
    List<pw.Widget> content = [];

    for (DDoc doc in res.data.docs) {
      // 添加到大纲
      outline.add({
        'title': "${res.data.name}/${doc.title}",
        'page': content.length + 2, // +2 是因为首页和大纲页
      });

      // 创建印迹内容
      QuillController edit = QuillController(
          document: Document.fromJson(jsonDecode(doc.content)),
          selection: const TextSelection.collapsed(offset: 0));

      content.add(
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Header(
            level: 0,
            child: pw.Text(doc.title,
                style: pw.TextStyle(
                    fontSize: titleFontSize,
                    font: font,
                    fontWeight: pw.FontWeight.bold))),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("印迹分级: ${doc.levelString}",
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    color: PdfColor.fromInt(Colors.grey.hashCode),
                    fontWeight: pw.FontWeight.normal)),
            pw.Text("创建时间: ${doc.createAtString}",
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    color: PdfColor.fromInt(Colors.grey.hashCode),
                    fontWeight: pw.FontWeight.normal)),
          ],
        ),
        pw.SizedBox(height: 20),
        ...edit.document.toDelta().toList().map((op) {
          if (op.isInsert && op.value is String) {
            String value = op.value.toString();
            if (value.contains('\n')) {
              List<String> paragraphs = value.split('\n');
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: paragraphs.map((paragraph) {
                    if (paragraph.trim().isEmpty) {
                      return pw.SizedBox(height: 10);
                    }
                    return pw.Column(
                      children: [
                        pw.Text(paragraph,
                            style: pw.TextStyle(
                                fontSize: mainBodyFontSize,
                                font: font,
                                fontWeight: pw.FontWeight.normal)),
                        pw.SizedBox(height: 10)
                      ],
                    );
                  }).toList());
            } else {
              return pw.Paragraph(
                  text: value,
                  style: pw.TextStyle(
                      fontSize: mainBodyFontSize,
                      font: font,
                      fontWeight: pw.FontWeight.normal));
            }
          } else if (op.isInsert && op.value is Map) {
            final map = op.value as Map;
            if (map.containsKey('image')) {
              return _pdfImage(map);
            } else {
              log.e("发现未知map类型");
            }
          }
          log.e("发现未知类型");
          return pw.Paragraph(
              text: op.value.toString(),
              style: pw.TextStyle(
                  fontSize: mainBodyFontSize,
                  font: font,
                  fontWeight: pw.FontWeight.normal));
        })
      ]));
    }

    // 首页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("枫迹",
                style: pw.TextStyle(
                    fontSize: 40, font: font, fontWeight: pw.FontWeight.bold)),
          );
        },
      ),
    );

    // 大纲页
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("大纲",
                  style: pw.TextStyle(
                      fontSize: 30,
                      font: font,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              ...outline.map((item) {
                return pw.Text(item['title'],
                    style: pw.TextStyle(
                      fontSize: 12,
                      font: font,
                    ));
              }),
            ],
          );
        },
      ),
    );

    // 内容页
    pdf.addPage(pw.MultiPage(build: (pw.Context context) {
      return content;
    }));

    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存路径',
      fileName: '枫迹-${Time.getCurrentTime()}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (filePath == null) {
      return;
    }

    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    print("保存成功：${file.path}");
  }

  Future<void> one(ExportData doc, {String? savePath}) async {
    QuillController edit = QuillController(
        document: Document.fromJson(jsonDecode(doc.content)),
        selection: const TextSelection.collapsed(offset: 0));

    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          if (context.pageNumber != 1) {
            return pw.Container();
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _pdfHeader(doc, font, titleFontSize, mainBodyFontSize),
          );
        },
        build: (pw.Context context) {
          return edit.document.toDelta().toList().map((op) {
            if (op.isInsert && op.value is String) {
              String value = op.value.toString();
              if (value.contains('\n')) {
                List<String> paragraphs = value.split('\n');
                return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: paragraphs.map((paragraph) {
                      if (paragraph.trim().isEmpty) {
                        return pw.SizedBox(height: 10);
                      }
                      return pw.Column(
                        children: [
                          pw.Text(paragraph,
                              style: pw.TextStyle(
                                  fontSize: mainBodyFontSize,
                                  font: font,
                                  fontWeight: pw.FontWeight.normal)),
                          pw.SizedBox(height: 10)
                        ],
                      );
                    }).toList());
              } else {
                return pw.Paragraph(
                    text: value,
                    style: pw.TextStyle(
                        fontSize: mainBodyFontSize,
                        font: font,
                        fontWeight: pw.FontWeight.normal));
              }
            } else if (op.isInsert && op.value is Map) {
              final map = op.value as Map;
              if (map.containsKey('image')) {
                return _pdfImage(map);
              } else {
                log.e("发现未知map类型");
                // return pw.Paragraph(
                //     text: op.value.toString(),
                //     style: pw.TextStyle(
                //         fontSize: mainBodyFontSize,
                //         font: font,
                //         fontWeight: pw.FontWeight.normal));
              }
            }
            log.e("发现未知类型");
            return pw.Paragraph(
                text: op.value.toString(),
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    fontWeight: pw.FontWeight.normal));
          }).toList();
        },
      ),
    );
    final String fileName = doc.title.isEmpty ? "无题" : doc.title;

    if (savePath == null) {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存路径',
        fileName: '$fileName.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savePath == null) {
        return;
      }
    } else {
      savePath = '$savePath/$fileName.pdf';
    }

    File file = File(savePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF文件已保存：${file.path}');
  }

  List<pw.Widget> _pdfHeader(
      ExportData doc, pw.Font font, double titleFontSize, double fontsize) {
    return [
      pw.Header(
          level: 0,
          child: pw.Text(doc.title,
              style: pw.TextStyle(
                  fontSize: titleFontSize,
                  font: font,
                  fontWeight: pw.FontWeight.bold))),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("印迹分级: ${doc.levelString}",
              style: pw.TextStyle(
                  fontSize: fontsize,
                  font: font,
                  color: PdfColor.fromInt(Colors.grey.hashCode),
                  fontWeight: pw.FontWeight.normal)),
          pw.Text("创建时间: ${doc.createAtString}",
              style: pw.TextStyle(
                  fontSize: fontsize,
                  font: font,
                  color: PdfColor.fromInt(Colors.grey.hashCode),
                  fontWeight: pw.FontWeight.normal)),
        ],
      ),
      pw.SizedBox(height: 20),
    ];
  }

  pw.Image _pdfImage(Map<dynamic, dynamic> map) {
    return pw.Image(
      pw.MemoryImage(
        base64Decode(
          map['image'].toString().split(',').last,
        ),
      ),
      width: double.tryParse(map['width'].toString()),
      height: double.tryParse(map['height'].toString()),
    );
  }

  Future<void> docSplit(ExportData doc, {String? savePath}) async {
    QuillController edit = QuillController(
        document: Document.fromJson(jsonDecode(doc.content)),
        selection: const TextSelection.collapsed(offset: 0));

    final pdf = pw.Document();
    pw.Font font = pw.Font.ttf(
        (await rootBundle.load("lib/assets/NotoSansSC-VariableFont_wght.ttf")));

    double titleFontSize = 30;
    double mainBodyFontSize = 9;

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          if (context.pageNumber != 1) {
            return pw.Container();
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _pdfHeader(doc, font, titleFontSize, mainBodyFontSize),
          );
        },
        build: (pw.Context context) {
          return edit.document.toDelta().toList().map((op) {
            if (op.isInsert && op.value is String) {
              String value = op.value.toString();
              if (value.contains('\n')) {
                List<String> paragraphs = value.split('\n');
                return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: paragraphs.map((paragraph) {
                      if (paragraph.trim().isEmpty) {
                        return pw.SizedBox(height: 10);
                      }
                      return pw.Column(
                        children: [
                          pw.Text(paragraph,
                              style: pw.TextStyle(
                                  fontSize: mainBodyFontSize,
                                  font: font,
                                  fontWeight: pw.FontWeight.normal)),
                          pw.SizedBox(height: 10)
                        ],
                      );
                    }).toList());
              } else {
                return pw.Paragraph(
                    text: value,
                    style: pw.TextStyle(
                        fontSize: mainBodyFontSize,
                        font: font,
                        fontWeight: pw.FontWeight.normal));
              }
            } else if (op.isInsert && op.value is Map) {
              final map = op.value as Map;
              if (map.containsKey('image')) {
                return _pdfImage(map);
              } else {
                log.e("发现未知map类型");
                // return pw.Paragraph(
                //     text: op.value.toString(),
                //     style: pw.TextStyle(
                //         fontSize: mainBodyFontSize,
                //         font: font,
                //         fontWeight: pw.FontWeight.normal));
              }
            }
            log.e("发现未知类型");
            return pw.Paragraph(
                text: op.value.toString(),
                style: pw.TextStyle(
                    fontSize: mainBodyFontSize,
                    font: font,
                    fontWeight: pw.FontWeight.normal));
          }).toList();
        },
      ),
    );
    final String fileName = doc.title.isEmpty ? "无题" : doc.title;

    if (savePath == null) {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存路径',
        fileName: '$fileName.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (savePath == null) {
        return;
      }
    } else {
      savePath = '$savePath/$fileName.pdf';
    }

    File file = File(savePath);
    await file.writeAsBytes(await pdf.save());
    try {
      await file.setLastModified(doc.createAt);
      await file.setLastAccessed(doc.createAt);
    } catch (e) {
      print('修改时间出错: $e');
    }

    print('PDF文件已保存：${file.path}');
  }
}
