import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whispering_time/services/grpc/grpc.dart';
import 'package:whispering_time/utils/ui.dart';

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});

  @override
  State<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  bool _isLoading = true;
  List<BackgroundJob> _jobs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBackgroundJobs();
  }

  Future<void> _loadBackgroundJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await Grpc().getBackgroundJobs();
      if (res.isNotOK) {
        setState(() {
          _errorMessage = res.msg;
          _isLoading = false;
        });
        if (mounted) {
          showErrMsg(context, res.msg);
        }
        return;
      }

      setState(() {
        // 按创建时间降序排序（最新的在前面）
        _jobs = res.jobs;
        _jobs.sort((a, b) {
          try {
            final aTime = DateTime.parse(a.createdAt);
            final bTime = DateTime.parse(b.createdAt);
            return bTime.compareTo(aTime); // 降序
          } catch (e) {
            return 0;
          }
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return '未知时间';
    }
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return '刚刚';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}小时前';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackgroundJobs,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[300]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBackgroundJobs,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无任务', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBackgroundJobs,
      child: ListView.builder(
        itemCount: _jobs.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(BackgroundJob job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getJobTypeDisplay(job.jobType),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(job.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '创建时间: ${_formatDateTime(job.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (job.startedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '开始时间: ${_formatDateTime(job.startedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (job.completedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '完成: ${_formatDateTime(job.completedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (job.error != null && job.error!.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.error!.message,
                        style: TextStyle(fontSize: 12, color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (job.status == 'failed') ...[
                  TextButton.icon(
                    onPressed: () => _retryJob(job),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('重试'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (job.status == 'completed') ...[
                  TextButton.icon(
                    onPressed: () => _downloadResult(job),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('下载'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton.icon(
                  onPressed: () => _deleteJob(job),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildStatusIcon(String status) {
  //   IconData iconData;
  //   Color iconColor;

  //   switch (status.toLowerCase()) {
  //     case 'pending':
  //       iconData = Icons.schedule;
  //       iconColor = Colors.orange;
  //       break;
  //     case 'running':
  //       iconData = Icons.sync;
  //       iconColor = Colors.blue;
  //       break;
  //     case 'completed':
  //       iconData = Icons.check_circle;
  //       iconColor = Colors.green;
  //       break;
  //     case 'failed':
  //       iconData = Icons.error;
  //       iconColor = Colors.red;
  //       break;
  //     default:
  //       iconData = Icons.help_outline;
  //       iconColor = Colors.grey;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.all(8),
  //     decoration: BoxDecoration(
  //       color: iconColor.withValues(alpha: .1),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Icon(iconData, color: iconColor, size: 24),
  //   );
  // }

  String _getJobTypeDisplay(String jobType) {
    switch (jobType) {
      case 'ExportGroupConfig':
        return '导出群组配置';
      default:
        return jobType;
    }
  }

  Future<void> _retryJob(BackgroundJob job) async {
    if (mounted) {
      showSuccessMsg(context, '重试功能开发中...');
    }
  }

  Future<void> _downloadResult(BackgroundJob job) async {
    if (!mounted) return;

    try {
      // 显示下载进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在下载...'),
            ],
          ),
        ),
      );

      // 调用下载接口
      final res = await Grpc().downloadBackgroundJobFile(job.id);

      // 关闭进度对话框
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      // 处理 404 错误
      if (res.err == 404) {
        showErrMsg(context, '文件未找到');
        return;
      }

      // 处理其他错误
      if (res.err != 0 || res.data == null) {
        showErrMsg(context, res.msg);
        return;
      }

      // 生成文件名
      String defaultFilename =
          res.filename ?? 'download_${DateTime.now().millisecondsSinceEpoch}';

      // 确保文件名安全
      defaultFilename =
          defaultFilename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      // 让用户选择保存路径
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存位置',
        fileName: defaultFilename,
      );

      if (filePath == null) {
        // 用户取消了选择
        return;
      }

      // 保存文件
      final file = File(filePath);
      await file.writeAsBytes(res.data!);

      if (!mounted) return;

      // 显示成功对话框,提供打开文件夹选项
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('下载成功'),
          content: Text('文件已保存到:\n$filePath'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _openFileLocation(filePath);
              },
              child: const Text('打开文件夹'),
            ),
          ],
        ),
      );
    } catch (e) {
      // 关闭进度对话框(如果还在显示)
      if (mounted) {
        Navigator.of(context, rootNavigator: true).popUntil((route) {
          return route.isFirst || !route.willHandlePopInternally;
        });
      }

      if (mounted) {
        showErrMsg(context, '下载失败: ${e.toString()}');
      }
    }
  }

  // 打开文件所在文件夹
  Future<void> _openFileLocation(String filePath) async {
    try {
      final file = File(filePath);
      final directory = file.parent;

      if (Platform.isMacOS) {
        // macOS: 使用 open 命令打开 Finder 并选中文件
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isWindows) {
        // Windows: 使用 explorer 命令选中文件
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isLinux) {
        // Linux: 使用 xdg-open 打开文件管理器
        await Process.run('xdg-open', [directory.path]);
      } else {
        // 其他平台: 尝试使用 url_launcher 打开目录
        final uri = Uri.file(directory.path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            showErrMsg(context, '无法打开文件夹');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrMsg(context, '打开文件夹失败: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteJob(BackgroundJob job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除任务 "${job.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 调用删除接口
        final res = await Grpc().deleteBackgroundJob(job.id);

        if (mounted) {
          if (res.isOK) {
            // 响应成功，从列表中删除
            setState(() {
              _jobs.removeWhere((j) => j.id == job.id);
            });
            showSuccessMsg(context, '删除成功');
          } else {
            // 响应失败，显示错误信息
            showErrMsg(context, res.msg);
          }
        }
      } catch (e) {
        if (mounted) {
          showErrMsg(context, '删除失败: ${e.toString()}');
        }
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        displayText = '等待中';
        break;
      case 'running':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        displayText = '进行中';
        break;
      case 'completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        displayText = '已完成';
        break;
      case 'failed':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        displayText = '失败';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[900]!;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
