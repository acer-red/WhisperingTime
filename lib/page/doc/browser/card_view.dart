import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/doc/manager.dart';
import 'package:whispering_time/util/env.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:whispering_time/page/doc/time_display.dart';
import 'package:whispering_time/page/doc/browser/image_utils.dart';
import 'package:whispering_time/page/doc/browser/bubble.dart';

class DocCardList extends StatefulWidget {
  final DocsManager docsManager;
  final int? expandedIndex;
  final Map<String, bool> flippedStates;
  final Function(int?) onToggleExpand;
  final Function(int, Doc) onEdit;
  final Function(Doc) onSetting;
  final Function(String, bool) onFlip;

  const DocCardList({
    super.key,
    required this.docsManager,
    required this.expandedIndex,
    required this.flippedStates,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onSetting,
    required this.onFlip,
  });

  @override
  State<DocCardList> createState() => _DocCardListState();
}

class _DocCardListState extends State<DocCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.docsManager.items.length,
        itemBuilder: (context, index) {
          final item = widget.docsManager.items[index];
          final isExpanded = widget.expandedIndex == index;
          // log.d(item.toJson()); // Removed log for cleaner code

          final priority = item.config.displayPriority ?? 0;
          final isFlipped = widget.flippedStates[item.id] ?? false;

          if (priority == 1 && isFlipped) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: _buildCardContent(index, item, isExpanded),
              ),
            );
          }

          return GestureDetector(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: _buildCardContent(index, item, isExpanded),
            ),
          );
        });
  }

  Widget _buildCardContent(int index, Doc item, bool isExpanded) {
    final priority = item.config.displayPriority ?? 0;
    if (priority == 1) {
      return _buildTextFirstCard(index, item, isExpanded);
    } else if (priority == 2) {
      return _buildMediaFirstCard(index, item, isExpanded);
    } else {
      return isExpanded
          ? _buildExpandedCard(index, item)
          : _buildPreviewCard(index, item);
    }
  }

  Widget _buildTextFirstCard(int index, Doc item, bool isExpanded) {
    bool isFlipped = widget.flippedStates[item.id] ?? false;
    if (isFlipped) {
      return _buildBackSide(item);
    }
    return Stack(
      children: [
        isExpanded
            ? _buildExpandedCard(index, item, textOnly: true)
            : _buildPreviewCard(index, item, textOnly: true),
        if (!isExpanded)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.image, size: 22, color: Colors.grey.shade700),
              onPressed: () {
                widget.onFlip(item.id, true);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMediaFirstCard(int index, Doc item, bool isExpanded) {
    bool isFlipped = widget.flippedStates[item.id] ?? false;
    if (isFlipped) {
      return _buildBackSide(item);
    }

    // Media First: Title . Text Content (minimized)
    // Then Carousel
    List<String> images = extractImages(item.content);
    if (images.isEmpty) {
      // Fallback to text first if no images
      return _buildTextFirstCard(index, item, isExpanded);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${item.title.isEmpty ? '未命名' : item.title} · ${item.content.replaceAll(RegExp(r'\{.*?\}'), '').replaceAll('\n', ' ').substring(0, item.content.length > 20 ? 20 : item.content.length)}...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined, size: 20),
                onPressed: () => widget.onSetting(item),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return DocImage(imageSource: images[index]);
            },
          ),
        ),
        _buildCardFooter(item),
      ],
    );
  }

  Widget _buildBackSide(Doc item) {
    List<String> images = extractImages(item.content);
    if (images.isEmpty) {
      return Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("无图片"),
            TextButton(
                onPressed: () => widget.onFlip(item.id, false),
                child: Text("返回"))
          ]));
    }

    return SizedBox(
        height: 260,
        child: Stack(children: [
          PageView.builder(
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.trackpad
                },
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    DocImage(imageSource: images[index]),
                    if (images.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${index + 1}/${images.length}",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                );
              }),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.grey.shade700),
                constraints: BoxConstraints(),
                padding: EdgeInsets.all(6),
                onPressed: () => widget.onFlip(item.id, false),
              ),
            ),
          )
        ]));
  }

  // 底部信息栏
  Widget _buildCardFooter(Doc item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.bookmark_border, size: 14, color: Colors.grey.shade500),
            SizedBox(width: 4),
            Text(
              Level.l[item.level],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        TimeDisplay(time: item.createAt),
      ],
    );
  }

  // 卡片: 预览模式
  Widget _buildPreviewCard(int index, Doc item, {bool textOnly = false}) {
    return InkWell(
      onTap: () => widget.onToggleExpand(index),
      borderRadius: BorderRadius.circular(15.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 标题行
            if (item.title.isNotEmpty || Config.instance.visualNoneTitle) ...[
              Text(
                item.title.isEmpty ? '未命名' : item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
            ],

            // 印迹具体内容
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _buildRichText(item.content,
                  limitLines: true, textOnly: textOnly),
            ),

            SizedBox(height: 12),

            // 底部信息
            _buildCardFooter(item),
          ],
        ),
      ),
    );
  }

  // 卡片: 展开模式
  Widget _buildExpandedCard(int index, Doc item, {bool textOnly = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 顶部区域：标题与操作栏
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (item.title.isNotEmpty ||
                        Config.instance.visualNoneTitle)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                        child: Text(
                          item.title.isEmpty ? '未命名' : item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            height: 1.2,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(Icons.edit_outlined,
                      () => widget.onEdit(index, item), '编辑'),
                  _buildActionButton(Icons.settings_outlined,
                      () => widget.onSetting(item), '设置'),
                  if (textOnly)
                    _buildActionButton(Icons.image_outlined, () {
                      widget.onFlip(item.id, true);
                    }, '查看图片'),
                  _buildActionButton(Icons.expand_less,
                      () => widget.onToggleExpand(null), '收缩'),
                ],
              ),
            ],
          ),
        ),

        // 分割线
        Divider(
            height: 1,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
            color: Colors.grey.withValues(alpha: 0.2)),

        // 完整内容
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: _buildRichText(item.content, textOnly: textOnly),
        ),

        // 底部信息
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _buildCardFooter(item),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback onPressed, String tooltip) {
    return IconButton(
      icon: Icon(icon, size: 22, color: Colors.grey.shade700),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 40, height: 40),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildRichText(String content,
      {bool limitLines = false, bool textOnly = false}) {
    if (content.isEmpty) return SizedBox.shrink();
    final Document doc;

    try {
      var json = jsonDecode(content);
      if (textOnly && json is List) {
        json = json.where((op) {
          if (op is Map && op.containsKey('insert')) {
            if (op['insert'] is Map && op['insert'].containsKey('image')) {
              return false;
            }
          }
          return true;
        }).toList();
      }
      doc = Document.fromJson(json);
    } catch (e) {
      return Text(content);
    }

    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final double fontSize = baseStyle?.fontSize ?? 14;
    final double heightFactor = baseStyle?.height ?? 1.2;
    final double? maxHeight = limitLines
        ? fontSize * heightFactor * 3 - 8 // approximate three lines
        : null;

    final editor = QuillEditor(
      controller: QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true),
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      config: QuillEditorConfig(
        embedBuilders: [
          CustomImageEmbedBuilder(),
          ...(kIsWeb
                  ? FlutterQuillEmbeds.editorWebBuilders()
                  : FlutterQuillEmbeds.editorBuilders())
              .where((builder) => builder.key != 'image'),
        ],
        scrollable: limitLines,
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        enableInteractiveSelection: !limitLines,
      ),
    );

    if (maxHeight != null) {
      return SizedBox(
        height: maxHeight,
        child: AbsorbPointer(
          absorbing: true, // let taps fall through to the card to expand
          child: ClipRect(child: editor),
        ),
      );
    }
    return editor;
  }
}
