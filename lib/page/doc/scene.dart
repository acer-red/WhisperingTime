import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/group/model.dart';
import 'package:whispering_time/service/isar/config.dart';

enum SceneMode {
  scroll, // 流年
  focus, // 聚焦
}

class ScenePage extends StatefulWidget {
  final Group group;
  final List<Doc> docs;
  final SceneMode mode;

  const ScenePage({
    super.key,
    required this.docs,
    required this.group,
    this.mode = SceneMode.scroll,
  });

  @override
  State<ScenePage> createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  bool _isPlaying = true;
  Timer? _slideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == SceneMode.scroll) {
        _startAutoScroll(delay: true);
      } else {
        _startSlideShow();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _pageController.dispose();
    _slideTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Config.instance.keepAnimationWhenLostFocus) return;
    if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        if (widget.mode == SceneMode.scroll) {
          _startAutoScroll();
        } else {
          _startSlideShow();
        }
      }
    } else {
      if (widget.mode == SceneMode.scroll) {
        _stopAutoScroll();
      } else {
        _stopSlideShow();
      }
    }
  }

  void _stopAutoScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.offset);
    }
  }

  void _stopSlideShow() {
    _slideTimer?.cancel();
  }

  void _startSlideShow() {
    if (!mounted || !_isPlaying) return;
    _slideTimer?.cancel();
    // 幻灯片：每页停留 5 秒
    _slideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_isPlaying) return;
      if (_pageController.hasClients &&
          _pageController.page! < widget.docs.length) {
        _pageController
            .nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        )
            .then((_) {
          if (mounted && _isPlaying) _startSlideShow();
        });
      } else {
        // 播放结束
        if (mounted) Navigator.of(context).pop();
      }
    });
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
      if (widget.mode == SceneMode.scroll) {
        _startAutoScroll();
      } else {
        _startSlideShow();
      }
    } else {
      if (widget.mode == SceneMode.scroll) {
        _stopAutoScroll();
      } else {
        _stopSlideShow();
      }
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
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _togglePlay,
            child: widget.mode == SceneMode.scroll
                ? _buildScrollView(screenHeight, gap)
                : _buildFocusView(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: IgnorePointer(
                ignoring: _isPlaying,
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: '退出',
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "已暂停",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: _togglePlay,
                            tooltip: '继续',
                          ),
                        ],
                      ),
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

  Widget _buildScrollView(double screenHeight, double gap) {
    return ListView(
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
    );
  }

  Widget _buildFocusView() {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.docs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: _buildTitle(
              widget.group.name,
              widget.docs.isNotEmpty
                  ? "始于 ${widget.docs.last.createAtString}"
                  : "",
            ),
          );
        }
        final docIndex = index - 1;
        final doc = widget.docs[docIndex];
        final previousDocTime =
            docIndex > 0 ? widget.docs[docIndex - 1].createAt : null;
        return Center(
          child: SingleChildScrollView(
            child: DocItemWidget(
              doc: doc,
              previousDocTime: previousDocTime,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
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
        final decoded = jsonDecode(widget.doc.content);
        final json = (decoded is Map && decoded['rich'] is List)
            ? decoded['rich']
            : decoded;
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
      document: Document()..insert(0, widget.doc.content),
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
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (relativeTime != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    relativeTime,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                exactTime,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "·",
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.doc.levelString,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
