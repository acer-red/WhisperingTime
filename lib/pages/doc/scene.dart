import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/pages/doc/model.dart';
import 'package:whispering_time/pages/group/model.dart';
import 'package:whispering_time/services/isar/config.dart';

class ScenePage extends StatefulWidget {
  final Group group;
  final List<Doc> docs;
  const ScenePage({super.key, required this.docs, required this.group});

  @override
  State<ScenePage> createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(delay: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Config.instance.keepAnimationWhenLostFocus) return;
    if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _startAutoScroll();
      }
    } else {
      _stopAutoScroll();
    }
  }

  void _stopAutoScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.offset);
    }
  }

  void _startAutoScroll({bool delay = false}) {
    if (!mounted) return;
    if (!_isPlaying) return;

    void doScroll() {
      if (!mounted) return;
      if (!_isPlaying) return;
      if (!_scrollController.hasClients) return;

      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double currentScroll = _scrollController.offset;
      final double distance = maxScroll - currentScroll;

      if (distance <= 0) return;

      // 速度控制：每秒 40 像素，保证阅读舒适度
      const double speed = 40.0;
      final int durationMs = (distance / speed * 1000).toInt();

      _scrollController
          .animateTo(
        maxScroll,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      )
          .then((_) {
        if (mounted && _isPlaying) {
          // Check if we reached the end (or very close to it)
          if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 1.0) {
            Navigator.of(context).pop();
          }
        }
      });
    }

    if (delay) {
      Future.delayed(const Duration(milliseconds: 100), doScroll);
    } else {
      doScroll();
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // 间距设置为屏幕高度的 40%，这样前一个内容过半时，后一个内容差不多开始出现
    final double gap = screenHeight * 0.4;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: ListView(
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  height: screenHeight,
                  alignment: Alignment.center,
                  child: _buildTitle(
                    widget.group.name,
                    widget.docs.isNotEmpty
                        ? "始于 ${widget.docs.last.createAtString}"
                        : "",
                  ),
                ),
                ...widget.docs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  final previousDocTime =
                      index > 0 ? widget.docs[index - 1].createAt : null;
                  return Column(
                    children: [
                      DocItemWidget(
                        doc: doc,
                        previousDocTime: previousDocTime,
                      ),
                      SizedBox(height: gap),
                    ],
                  );
                }),
                SizedBox(height: screenHeight * 0.5), // 结束位置：让最后一个内容滚出屏幕
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IgnorePointer(
                ignoring: _isPlaying,
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, String subtitle) {
    const double fontSize = 30;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(fontSize: fontSize - 4, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class DocItemWidget extends StatefulWidget {
  final Doc doc;
  final DateTime? previousDocTime;
  const DocItemWidget({super.key, required this.doc, this.previousDocTime});

  @override
  State<DocItemWidget> createState() => _DocItemWidgetState();
}

class _DocItemWidgetState extends State<DocItemWidget> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    try {
      if (widget.doc.content.isNotEmpty) {
        final json = jsonDecode(widget.doc.content);
        _controller = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } else {
        _fallbackController();
      }
    } catch (e) {
      _fallbackController();
    }
  }

  void _fallbackController() {
    _controller = QuillController(
      document: Document()..insert(0, widget.doc.plainText),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String? _getRelativeTime() {
    if (widget.previousDocTime == null) return null;
    final diff = widget.doc.createAt.difference(widget.previousDocTime!);
    if (diff.inDays > 0) return "${diff.inDays}天后";
    if (diff.inHours > 0) return "${diff.inHours}小时后";
    if (diff.inMinutes > 0) return "${diff.inMinutes}分钟后";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const double fontSize = 30;
    final relativeTime = _getRelativeTime();
    final exactTime = DateFormat('MM月dd日 HH:mm').format(widget.doc.createAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.doc.title,
            style: const TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (relativeTime != null) ...[
                      Text(
                        relativeTime,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      exactTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  widget.doc.levelString,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QuillEditor(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: ScrollController(),
            config: QuillEditorConfig(
              autoFocus: false,
              expands: false,
              padding: EdgeInsets.zero,
              scrollable: false,
              enableInteractiveSelection: false,
              enableSelectionToolbar: false,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  TextStyle(
                    height: 2.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 5),
                  const VerticalSpacing(0, 0),
                  null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
