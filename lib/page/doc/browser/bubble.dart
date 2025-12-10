import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/page/doc/model.dart';
import 'package:whispering_time/page/doc/browser/image_utils.dart';

class BubblePainter extends CustomPainter {
  final Color color;
  final double arrowOffset;
  final double tailHeight;
  final Color shadowColor;
  final double shadowBlur;

  BubblePainter({
    required this.color,
    required this.arrowOffset,
    required this.tailHeight,
    required this.shadowColor,
    required this.shadowBlur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - tailHeight);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)))
      ..moveTo(rect.left + arrowOffset - 8, rect.bottom)
      ..lineTo(rect.left + arrowOffset, rect.bottom + tailHeight)
      ..lineTo(rect.left + arrowOffset + 8, rect.bottom)
      ..close();

    canvas.drawShadow(path, shadowColor, shadowBlur, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void showDocsBubble({
  required BuildContext context,
  required List<Doc> docs,
  required Function(Doc) onEdit,
  required Function(Doc) onSetting,
}) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final size = renderBox.size;
  final offset = renderBox.localToGlobal(Offset.zero);

  OverlayEntry? entry;
  bool isEditing = false;

  // 气泡配置
  final double bubbleWidth = 240.0;
  final double itemHeight = 52.0;
  final double headerHeight = 40.0;
  final double maxBubbleHeight = 280.0;
  final double tailHeight = 10.0;

  // 计算内容高度
  final double contentHeight = headerHeight + (docs.length * itemHeight);
  final double bubbleHeight =
      contentHeight.clamp(headerHeight + itemHeight, maxBubbleHeight) +
          tailHeight;

  // 计算位置
  final double centerX = offset.dx + size.width / 2;
  double left = centerX - bubbleWidth / 2;
  double top = offset.dy - bubbleHeight - 4; // 4px 间距

  // 边界检查，防止气泡超出屏幕左右边界
  final double screenWidth = MediaQuery.of(context).size.width;
  if (left < 10) left = 10;
  if (left + bubbleWidth > screenWidth - 10) {
    left = screenWidth - bubbleWidth - 10;
  }

  // 箭头相对于气泡左侧的偏移量
  final double arrowOffset = centerX - left;

  entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // 遮罩层，点击关闭
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              entry?.remove();
            },
            child: Container(color: Colors.black.withValues(alpha: 0.05)),
          ),
        ),
        // 气泡主体
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  alignment: Alignment(
                      (arrowOffset - bubbleWidth / 2) / (bubbleWidth / 2), 1.0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: bubbleWidth,
                height: bubbleHeight,
                child: CustomPaint(
                  painter: BubblePainter(
                    color: Colors.white,
                    arrowOffset: arrowOffset,
                    tailHeight: tailHeight,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    shadowBlur: 16,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setStateBubble) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: tailHeight),
                        child: Column(
                          children: [
                            // 标题栏
                            Container(
                              height: headerHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey
                                            .withValues(alpha: 0.1))),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: 40),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.article_outlined,
                                          size: 16,
                                          color:
                                              Theme.of(context).primaryColor),
                                      SizedBox(width: 6),
                                      Text(
                                        "${docs.length} 篇印迹",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isEditing
                                          ? Icons.check_rounded
                                          : Icons.edit_rounded,
                                      size: 18,
                                      color: Colors.grey.shade700,
                                    ),
                                    onPressed: () {
                                      setStateBubble(() {
                                        isEditing = !isEditing;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints.tightFor(
                                        width: 40, height: 40),
                                  ),
                                ],
                              ),
                            ),
                            // 列表
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.only(
                                    top: 4, bottom: 4, left: 4, right: 4),
                                itemCount: docs.length,
                                separatorBuilder: (c, i) => Divider(
                                  height: 1,
                                  indent: 12,
                                  endIndent: 12,
                                  color: Colors.grey.withValues(alpha: 0.05),
                                ),
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final priority =
                                      doc.config.displayPriority ?? 0;

                                  String plainText = "";
                                  try {
                                    final document = Document.fromJson(
                                        jsonDecode(doc.content));
                                    plainText = document.toPlainText().trim();
                                  } catch (e) {
                                    plainText = doc.content;
                                  }

                                  String title = doc.title;
                                  if (title.isEmpty) {
                                    title = plainText.split('\n').first;
                                    if (title.length > 12) {
                                      title = '${title.substring(0, 12)}...';
                                    }
                                  }
                                  if (title.isEmpty) title = "无标题";

                                  Widget rightContent = SizedBox.shrink();

                                  if (priority == 2) {
                                    List<String> images =
                                        extractImages(doc.content);
                                    if (images.isNotEmpty) {
                                      rightContent = GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                GestureDetector(
                                              onTap: () =>
                                                  Navigator.of(context).pop(),
                                              child: Container(
                                                color: Colors.black
                                                    .withValues(alpha: 0.5),
                                                child: Center(
                                                  child: InteractiveViewer(
                                                    child: DocImage(
                                                        imageSource: images[0]),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: DocImage(
                                                imageSource: images[0],
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      );
                                    } else {
                                      rightContent = Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 100),
                                        child: Text(
                                          plainText.replaceAll('\n', ' '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600),
                                          textAlign: TextAlign.right,
                                        ),
                                      );
                                    }
                                  } else {
                                    rightContent = Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 100),
                                      child: Text(
                                        plainText.replaceAll('\n', ' '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                  }

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      if (!isEditing) {
                                        entry?.remove();
                                        onEdit(doc);
                                      }
                                    },
                                    child: Container(
                                      height: itemHeight - 8, // 减去padding
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade800,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('HH:mm')
                                                      .format(doc.createAt),
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          rightContent,
                                          SizedBox(width: 8),
                                          if (isEditing)
                                            IconButton(
                                              icon: Icon(Icons.settings,
                                                  size: 18,
                                                  color: Colors.grey.shade600),
                                              onPressed: () {
                                                entry?.remove();
                                                onSetting(doc);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                      width: 32, height: 32),
                                            )
                                          else
                                            Icon(Icons.chevron_right,
                                                size: 16,
                                                color: Colors.grey.shade300),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(entry);
}

List<String> extractImages(String content) {
  try {
    var json = jsonDecode(content);
    if (json is List) {
      List<String> images = [];
      for (var op in json) {
        if (op is Map && op.containsKey('insert')) {
          if (op['insert'] is Map && op['insert'].containsKey('image')) {
            images.add(op['insert']['image']);
          }
        }
      }
      return images;
    }
  } catch (e) {}
  return [];
}
