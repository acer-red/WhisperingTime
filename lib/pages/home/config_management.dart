import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:whispering_time/services/grpc/grpc.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:whispering_time/utils/ui.dart';

enum _ConfigMode { backup, restore }

enum _RestoreStep { source, content, options }

enum _SourceType { local, job }

enum _ImportConflictStrategy { overwrite, skip }

class ConfigManagementDialog extends StatefulWidget {
  const ConfigManagementDialog({super.key});

  @override
  State<ConfigManagementDialog> createState() => _ConfigManagementDialogState();
}

class _ConfigManagementDialogState extends State<ConfigManagementDialog> {
  _ConfigMode _mode = _ConfigMode.backup;
  _RestoreStep _restoreStep = _RestoreStep.source;
  bool _busy = false;
  bool _processing = false;
  String? _sourceName;
  String? _sourceError;
  String? _imagesDir;
  String? _workDir;
  String? _downloadedZipPath;
  List<_ImportThemeNode> _themes = [];
  _ImportConflictStrategy _conflict = _ImportConflictStrategy.overwrite;
  _SourceType? _sourceType;

  @override
  void dispose() {
    _cleanupTemp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      title: Text(
        _mode == _ConfigMode.backup ? '配置备份' : _restoreTitle(),
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModeTabs(),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _mode == _ConfigMode.backup
                      ? _buildBackupBody()
                      : _buildRestoreBody(),
                ),
              ],
            ),
            if (_processing)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: _buildActions(),
    );
  }

  String _restoreTitle() {
    switch (_restoreStep) {
      case _RestoreStep.source:
        return '恢复配置 · 导入来源';
      case _RestoreStep.content:
        return '恢复配置 · 选择内容';
      case _RestoreStep.options:
        return '恢复配置 · 导入选项';
    }
  }

  Widget _buildModeTabs() {
    return SegmentedButton<_ConfigMode>(
      segments: const [
        ButtonSegment(
            value: _ConfigMode.backup,
            icon: Icon(Icons.upload),
            label: Text('备份')),
        ButtonSegment(
            value: _ConfigMode.restore,
            icon: Icon(Icons.download),
            label: Text('恢复')),
      ],
      selected: {_mode},
      onSelectionChanged: _processing
          ? null
          : (value) {
              setState(() {
                _mode = value.first;
                if (_mode == _ConfigMode.restore) {
                  _restoreStep = _RestoreStep.source;
                }
              });
            },
    );
  }

  Widget _buildBackupBody() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '一键导出当前配置，会创建后台任务，可在任务列表下载。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _StepCard(
          child: Row(
            children: [
              Icon(Icons.settings_backup_restore, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '包含所有主题、分组与印迹的配置和资源文件',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _handleBackup,
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('生成备份'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestoreBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRestoreStepper(),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _buildRestoreStepContent(),
        ),
      ],
    );
  }

  Widget _buildRestoreStepContent() {
    switch (_restoreStep) {
      case _RestoreStep.source:
        return _buildSourceStep();
      case _RestoreStep.content:
        return _buildContentStep();
      case _RestoreStep.options:
        return _buildOptionsStep();
    }
  }

  Widget _buildRestoreStepper() {
    String label;
    switch (_restoreStep) {
      case _RestoreStep.source:
        label = '步骤 1/3 · 选择来源';
        break;
      case _RestoreStep.content:
        label = '步骤 2/3 · 选择内容';
        break;
      case _RestoreStep.options:
        label = '步骤 3/3 · 导入选项';
        break;
    }

    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSourceStep() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择备份来源',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _StepCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.folder_open, color: scheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('从本地上传 .zip 备份包')),
                  FilledButton(
                    onPressed: _processing ? null : _pickLocalZip,
                    child: const Text('选择文件'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.task_alt, color: scheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('从已完成的任务读取备份')),
                  FilledButton(
                    onPressed: _processing ? null : _openJobPicker,
                    child: const Text('选择任务'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_sourceName != null)
          _InfoRow(
            icon: Icons.check_circle,
            color: scheme.primary,
            text: '已选择 $_sourceName',
          ),
        if (_sourceError != null) ...[
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.error_outline,
            color: scheme.error,
            text: _sourceError!,
          ),
        ],
      ],
    );
  }

  Widget _buildContentStep() {
    final totalGroups = _themes.fold<int>(0, (sum, t) => sum + t.groups.length);
    final totalDocs = _totalDocCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('选择需要导入的主题、分组或印迹。支持逐层展开勾选。'),
        const SizedBox(height: 6),
        Text('已选 $_selectedDocCount / 共 $totalDocs 条 · 分组 $totalGroups'),
        const SizedBox(height: 10),
        _StepCard(
          child: SizedBox(
            height: 300,
            child: _themes.isEmpty
                ? const Center(child: Text('未解析到可导入内容'))
                : ListView(
                    shrinkWrap: true,
                    children: _themes.map(_buildThemeTile).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsStep() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('导入选项'),
        const SizedBox(height: 8),
        _StepCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConflictTile(
                icon: Icons.auto_fix_high,
                title: '同名覆盖',
                subtitle: '当目标存在同名分组时先删除再导入',
                value: _ImportConflictStrategy.overwrite,
                groupValue: _conflict,
                onChanged:
                    _processing ? null : (v) => setState(() => _conflict = v!),
                colorScheme: scheme,
              ),
              const Divider(height: 12),
              _ConflictTile(
                icon: Icons.block,
                title: '同名跳过',
                subtitle: '保留现有内容，不导入同名分组',
                value: _ImportConflictStrategy.skip,
                groupValue: _conflict,
                onChanged:
                    _processing ? null : (v) => setState(() => _conflict = v!),
                colorScheme: scheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_mode == _ConfigMode.backup) {
      return [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: _processing ? null : () => Navigator.of(context).pop(),
        child: const Text('取消'),
      ),
      if (_restoreStep != _RestoreStep.source)
        TextButton(
          onPressed: _processing
              ? null
              : () {
                  setState(() {
                    _restoreStep = _restoreStep == _RestoreStep.content
                        ? _RestoreStep.source
                        : _RestoreStep.content;
                  });
                },
          child: const Text('上一步'),
        ),
      ElevatedButton(
        onPressed: _processing ? null : _onNext,
        child: _processing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(_nextLabel()),
      ),
    ];
  }

  String _nextLabel() {
    switch (_restoreStep) {
      case _RestoreStep.source:
        return '下一步';
      case _RestoreStep.content:
        return '下一步';
      case _RestoreStep.options:
        return '开始导入';
    }
  }

  Widget _buildThemeTile(_ImportThemeNode theme) {
    return ExpansionTile(
      title: Row(
        children: [
          Checkbox(
            value: theme.selected,
            onChanged: (v) => _toggleTheme(theme, v ?? false),
          ),
          Expanded(child: Text(theme.name)),
        ],
      ),
      initiallyExpanded: theme.expanded,
      onExpansionChanged: (v) => setState(() => theme.expanded = v),
      children: theme.groups.map(_buildGroupTile).toList(),
    );
  }

  Widget _buildGroupTile(_ImportGroupNode group) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: group.selected,
              onChanged: (v) => _toggleGroup(group, v ?? false),
            ),
            Expanded(child: Text(group.name)),
          ],
        ),
        initiallyExpanded: group.expanded,
        onExpansionChanged: (v) => setState(() => group.expanded = v),
        children: group.docs.map(_buildDocTile).toList(),
      ),
    );
  }

  Widget _buildDocTile(_ImportDocNode doc) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0),
      child: CheckboxListTile(
        value: doc.selected,
        title: Text(doc.title),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) => _toggleDoc(doc, v ?? false),
      ),
    );
  }

  Future<void> _handleBackup() async {
    setState(() {
      _busy = true;
    });

    final res = await Http().exportAllConfig();
    if (!mounted) return;

    setState(() {
      _busy = false;
    });

    if (res.isNotOK) {
      showErrMsg(context, res.msg);
      return;
    }

    showSuccessMsg(context, '配置备份已生成');
    Navigator.of(context).pop();
  }

  Future<void> _pickLocalZip() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        setState(() {
          _sourceError = '无法读取文件';
        });
        return;
      }

      await _prepareZip(File(file.path!), sourceType: _SourceType.local);
    } catch (e) {
      setState(() {
        _sourceError = '读取文件失败: $e';
      });
    }
  }

  Future<void> _openJobPicker() async {
    final jobsRes = await Http().getBackgroundJobs();
    if (!mounted) return;

    if (jobsRes.isNotOK) {
      showErrMsg(context, jobsRes.msg);
      return;
    }

    final available = jobsRes.jobs
        .where((j) =>
            j.status == 'completed' &&
            (j.jobType == 'ExportGroupConfig' ||
                j.jobType == 'ExportAllConfig'))
        .toList();
    if (available.isEmpty) {
      showErrMsg(context, '没有可用的完成任务');
      return;
    }

    final selected = await showDialog<BackgroundJob>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('选择任务'),
          children: available
              .map(
                (j) => SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(j),
                  child: Row(
                    children: [
                      const Icon(Icons.archive_outlined),
                      const SizedBox(width: 8),
                      Expanded(child: Text(j.name.isEmpty ? j.id : j.name)),
                      const SizedBox(width: 8),
                      Text(j.jobType),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );

    if (selected == null) return;

    await _downloadJobFile(selected);
  }

  Future<void> _downloadJobFile(BackgroundJob job) async {
    setState(() {
      _processing = true;
      _sourceError = null;
    });
    try {
      final res = await Http().downloadBackgroundJobFile(job.id);
      if (!mounted) return;
      if (res.err != 0 || res.data == null) {
        setState(() {
          _sourceError = res.msg;
          _processing = false;
        });
        showErrMsg(context, res.msg);
        return;
      }

      final tempDir = await getTempDir();
      final filename = res.filename ?? '${job.id}.zip';
      final safeName = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File(p.join(tempDir.path, safeName));
      await file.writeAsBytes(res.data!);
      _downloadedZipPath = file.path;
      await _prepareZip(file, sourceType: _SourceType.job);
    } catch (e) {
      setState(() {
        _sourceError = '下载失败: $e';
        _processing = false;
      });
    }
  }

  Future<void> _prepareZip(File file, {_SourceType? sourceType}) async {
    setState(() {
      _processing = true;
      _sourceError = null;
      _themes = [];
      _sourceType = sourceType ?? _sourceType;
    });

    _cleanupTemp();

    try {
      final workDir = p.join((await getTempDir()).path,
          'config_import_${DateTime.now().millisecondsSinceEpoch}');
      await Directory(workDir).create(recursive: true);
      final extractDir = p.join(workDir, 'unzipped');
      await Directory(extractDir).create(recursive: true);
      _workDir = workDir;

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final entry in archive) {
        final entryPath = p.join(extractDir, entry.name);
        if (entry.isFile) {
          final outFile = File(entryPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(entry.content as List<int>);
        } else {
          await Directory(entryPath).create(recursive: true);
        }
      }

      final configPath = await _findConfigJson(extractDir);
      if (configPath == null) {
        setState(() {
          _processing = false;
          _sourceError = '未找到 config.json，无法导入';
        });
        return;
      }

      final configRaw = await File(configPath).readAsString();
      final dynamic parsed = jsonDecode(configRaw);
      final themes = _parseConfig(parsed);
      if (themes.isEmpty) {
        setState(() {
          _processing = false;
          _sourceError = '备份文件中没有可导入的数据';
        });
        return;
      }

      final imagesDir = Directory(p.join(extractDir, 'images'));

      setState(() {
        _processing = false;
        _sourceName = p.basename(file.path);
        _imagesDir = imagesDir.existsSync() ? imagesDir.path : null;
        _themes = themes;
        _restoreStep = _RestoreStep.content;
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _sourceError = '解析失败: $e';
      });
    }
  }

  Future<String?> _findConfigJson(String root) async {
    final dir = Directory(root);
    final entries = dir.listSync(recursive: true, followLinks: false);
    for (final entity in entries) {
      if (entity is File &&
          p.basename(entity.path).toLowerCase() == 'config.json') {
        return entity.path;
      }
    }
    return null;
  }

  List<_ImportThemeNode> _parseConfig(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => _ImportThemeNode.fromJson(e))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final group = _ImportGroupNode.fromJson(data);
      return [
        _ImportThemeNode(
          name: data['theme_name']?.toString() ?? '导入分组',
          raw: {
            'tid': data['tid'] ?? '',
            'name': data['theme_name'] ?? '导入分组',
          },
          groups: [group],
        )
      ];
    }

    return [];
  }

  void _toggleTheme(_ImportThemeNode theme, bool value) {
    setState(() {
      theme.selected = value;
      for (final group in theme.groups) {
        group.selected = value;
        for (final doc in group.docs) {
          doc.selected = value;
        }
      }
    });
  }

  void _toggleGroup(_ImportGroupNode group, bool value) {
    setState(() {
      group.selected = value;
      for (final doc in group.docs) {
        doc.selected = value;
      }
      final parent = _themes.firstWhere((t) => t.groups.contains(group));
      parent.selected = parent.groups.every((g) => g.selected);
    });
  }

  void _toggleDoc(_ImportDocNode doc, bool value) {
    setState(() {
      doc.selected = value;
      final group = _themes
          .expand((t) => t.groups)
          .firstWhere((g) => g.docs.contains(doc));
      group.selected = group.docs.every((d) => d.selected);
      final theme = _themes.firstWhere((t) => t.groups.contains(group));
      theme.selected = theme.groups.every((g) => g.selected);
    });
  }

  Future<void> _onNext() async {
    switch (_restoreStep) {
      case _RestoreStep.source:
        if (_themes.isEmpty) {
          showErrMsg(context, '请先选择导入来源');
          return;
        }
        setState(() => _restoreStep = _RestoreStep.content);
        break;
      case _RestoreStep.content:
        if (_selectedDocCount == 0) {
          showErrMsg(context, '至少选择一条印迹');
          return;
        }
        setState(() => _restoreStep = _RestoreStep.options);
        break;
      case _RestoreStep.options:
        await _performImport();
        break;
    }
  }

  int get _selectedDocCount {
    int count = 0;
    for (final theme in _themes) {
      for (final group in theme.groups) {
        count += group.docs.where((d) => d.selected).length;
      }
    }
    return count;
  }

  int get _totalDocCount {
    int count = 0;
    for (final theme in _themes) {
      for (final group in theme.groups) {
        count += group.docs.length;
      }
    }
    return count;
  }

  Future<void> _performImport() async {
    setState(() {
      _processing = true;
    });

    try {
      final themesRes = await Http().getthemes();
      if (themesRes.isNotOK) {
        if (mounted) showErrMsg(context, themesRes.msg);
        setState(() => _processing = false);
        return;
      }

      final existingThemes = {for (final t in themesRes.data) t.name: t.id};
      int successGroups = 0;
      final errors = <String>[];

      for (final theme in _themes) {
        final selectedGroups =
            theme.groups.where((g) => g.docs.any((d) => d.selected)).toList();
        if (selectedGroups.isEmpty) continue;

        String? tid = existingThemes[theme.name];
        if (tid == null) {
          final createRes =
              await Http().postTheme(RequestPostTheme(name: theme.name));
          if (createRes.isOK) {
            tid = createRes.id;
            existingThemes[theme.name] = tid;
          } else {
            errors.add('创建主题失败: ${theme.name}');
            continue;
          }
        }

        final groupsRes = await Http(tid: tid).getGroups();
        final existingGroups = <String, String>{};
        if (groupsRes.isOK) {
          for (final g in groupsRes.data) {
            existingGroups[g.name] = g.id;
          }
        }

        for (final group in selectedGroups) {
          if (!mounted) break;
          if (_conflict == _ImportConflictStrategy.skip &&
              existingGroups.containsKey(group.name)) {
            continue;
          }

          if (_conflict == _ImportConflictStrategy.overwrite &&
              existingGroups.containsKey(group.name)) {
            final gid = existingGroups[group.name]!;
            await Http(tid: tid, gid: gid).deleteGroup();
          }

          final zipFile = await _buildGroupZip(group);
          final res =
              await Http(tid: tid, gid: 'temp').importGroupConfig(zipFile.path);
          if (res.isOK) {
            successGroups += 1;
          } else {
            errors.add('导入分组失败: ${group.name} (${res.msg})');
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _processing = false;
      });

      if (errors.isEmpty) {
        showSuccessMsg(context, '导入成功，完成 $successGroups 个分组');
        _cleanupTemp();
        Navigator.of(context).pop(true);
      } else {
        showErrMsg(context, '部分导入失败: ${errors.join('; ')}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
      });
      showErrMsg(context, '导入失败: $e');
    }
  }

  Future<File> _buildGroupZip(_ImportGroupNode group) async {
    final archive = Archive();
    final docs = group.docs.where((d) => d.selected).map((d) => d.raw).toList();
    final config = Map<String, dynamic>.from(group.raw);
    config['docs'] = docs;
    final configBytes = utf8.encode(jsonEncode(config));
    archive
        .addFile(ArchiveFile('config.json', configBytes.length, configBytes));

    if (_imagesDir != null) {
      final imagesDir = Directory(_imagesDir!);
      if (imagesDir.existsSync()) {
        for (final entity in imagesDir.listSync(recursive: true)) {
          if (entity is! File) continue;
          final relPath = p.relative(entity.path, from: p.dirname(_imagesDir!));
          final data = await entity.readAsBytes();
          archive.addFile(
              ArchiveFile(relPath.replaceAll('\\', '/'), data.length, data));
        }
      }
    }

    final tempDir = await getTempDir();
    final filename =
        'import_${group.gid ?? group.name}_${DateTime.now().millisecondsSinceEpoch}.zip';
    final outPath = p.join(tempDir.path, filename);
    final bytes = ZipEncoder().encode(archive);
    final file = File(outPath);
    await file.writeAsBytes(bytes ?? []);
    return file;
  }

  void _cleanupTemp() {
    if (_workDir != null) {
      try {
        final dir = Directory(_workDir!);
        if (dir.existsSync()) {
          dir.deleteSync(recursive: true);
        }
      } catch (_) {}
      _workDir = null;
    }
    if (_downloadedZipPath != null) {
      try {
        final file = File(_downloadedZipPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
      _downloadedZipPath = null;
    }
  }
}

class _ImportThemeNode {
  _ImportThemeNode({
    required this.name,
    required this.raw,
    required this.groups,
  })  : selected = true,
        expanded = true;

  final String name;
  final Map<String, dynamic> raw;
  final List<_ImportGroupNode> groups;
  bool selected;
  bool expanded;

  factory _ImportThemeNode.fromJson(Map<String, dynamic> json) {
    final groups = (json['groups'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => _ImportGroupNode.fromJson(e))
        .toList();
    return _ImportThemeNode(
      name:
          json['name']?.toString() ?? json['theme_name']?.toString() ?? '未命名主题',
      raw: json,
      groups: groups,
    );
  }
}

class _ImportGroupNode {
  _ImportGroupNode({
    required this.name,
    required this.raw,
    required this.docs,
    this.gid,
  })  : selected = true,
        expanded = false;

  final String name;
  final Map<String, dynamic> raw;
  final List<_ImportDocNode> docs;
  final String? gid;
  bool selected;
  bool expanded;

  factory _ImportGroupNode.fromJson(Map<String, dynamic> json) {
    final docs = (json['docs'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => _ImportDocNode.fromJson(e))
        .toList();
    return _ImportGroupNode(
      name: json['name']?.toString() ?? '未命名分组',
      gid: json['gid']?.toString(),
      raw: json,
      docs: docs,
    );
  }
}

class _ImportDocNode {
  _ImportDocNode({
    required this.title,
    required this.raw,
  }) : selected = true;

  final String title;
  final Map<String, dynamic> raw;
  bool selected;

  factory _ImportDocNode.fromJson(Map<String, dynamic> json) {
    return _ImportDocNode(
      title: json['title']?.toString() ?? '未命名印迹',
      raw: json,
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.colorScheme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _ImportConflictStrategy value;
  final _ImportConflictStrategy groupValue;
  final ValueChanged<_ImportConflictStrategy?>? onChanged;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onChanged == null ? null : () => onChanged!(value),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: Radio<_ImportConflictStrategy>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
