import 'package:flutter/material.dart';
import 'package:whispering_time/pages/theme/doc/setting.dart';
import 'package:whispering_time/pages/theme/group/group.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:whispering_time/utils/export.dart';

class DocList extends StatefulWidget {
  final Group group;

  DocList({required this.group});

  @override
  State createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  List<Doc> items = <Doc>[];
  DateTime pickedDate = DateTime.now();
  int? editingIndex; // 当前正在编辑的Card索引

  @override
  void initState() {
    getDocs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.group.name), centerTitle: true, actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => createNewDoc()),
      ]),
      body: screenCard(),
    );
  }

  // 创建新文档
  void createNewDoc() {
    Doc newDoc = Doc(
      id: '',
      title: '',
      content: '',
      plainText: '',
      level: getSelectLevel(),
      crtime: DateTime.now(),
      uptime: DateTime.now(),
      config: DocConfigration(isShowTool: Config.instance.defaultShowTool),
    );

    setState(() {
      items.insert(0, newDoc);
      editingIndex = 0;
    });
  }

  // UI: 主体内容-卡片模式
  Widget screenCard() {
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isEditing = editingIndex == index;

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: isEditing
                ? _buildEditingCard(index, item)
                : _buildPreviewCard(index, item),
          );
        });
  }

  // 构建预览模式的卡片
  Widget _buildPreviewCard(int index, Doc item) {
    return InkWell(
      onTap: () => toggleEdit(index),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 标题行（包含编辑图标）
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Visibility(
                    visible: item.title.isNotEmpty ||
                        (item.title.isEmpty && Config.instance.visualNoneTitle),
                    child: Text(
                      item.title.isEmpty ? '未命名' : item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.edit,
                  color: Colors.grey[600],
                ),
              ],
            ),
            SizedBox(height: 8),

            // 印迹具体内容
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                item.plainText.trimRight(),
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 创建时间
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Level.l[item.level],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(" · ",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text(
                    Time.string(item.crtime),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 构建编辑模式的卡片
  Widget _buildEditingCard(int index, Doc item) {
    return _DocEditor(
      doc: item,
      group: widget.group,
      onSave: (updatedDoc) => handleDocUpdate(index, updatedDoc),
      onDelete: () => handleDocDelete(index),
      onCancel: () => handleDocCancel(index),
    );
  }

  // 切换编辑状态
  void toggleEdit(int? index) {
    setState(() {
      editingIndex = (editingIndex == index) ? null : index;
    });
  } // 处理文档更新

  void handleDocUpdate(int index, Doc updatedDoc) {
    setState(() {
      // 如果不符合选中的级别筛选，则删除
      if (!isContainSelectLevel(updatedDoc.level)) {
        items.removeAt(index);
      } else {
        items[index] = updatedDoc;
        items.sort(compareDocs);
      }
      editingIndex = null;
    });
  }

  // 处理文档删除
  void handleDocDelete(int index) {
    setState(() {
      items.removeAt(index);
      editingIndex = null;
    });
  }

  // 处理取消编辑（针对新建但未保存的文档）
  void handleDocCancel(int index) {
    setState(() {
      // 如果是空ID的新文档，取消时删除
      if (items[index].id.isEmpty) {
        items.removeAt(index);
      }
      editingIndex = null;
    });
  }

  // UI: 主体内容-日历模式
  Widget screenCalendar() {
    DateTime currentDate = DateTime.now();

    // 获取当月的天数
    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    // 获取当月的第一天是星期几 (星期一为1，星期天为7)
    int firstWeekdayOfMonth =
        DateTime(currentDate.year, currentDate.month, 1).weekday;

    // 计算需要多少行来显示整个月的日历
    // +1 表示新增一行，用来放星期
    int totalRows = ((daysInMonth + firstWeekdayOfMonth - 1) / 7).ceil();
    int totalitems = totalRows * 7;

    String getWeekString(int index) {
      switch (index) {
        case 0:
          return "周一";
        case 1:
          return "周二";
        case 2:
          return "周三";
        case 3:
          return "周四";
        case 4:
          return "周五";
        case 5:
          return "周六";
        default:
          return "周日";
      }
    }

    chooseDate() async {
      DateTime? d = await Time.datePacker(context);
      if (d == null) {
        return;
      }

      setState(() {
        pickedDate = d;
      });
      getDocs(year: pickedDate.year, month: pickedDate.month);
    }

    Widget dateTitle() {
      return TextButton(
          onPressed: () => chooseDate(),
          child: Text(DateFormat('yyyy MMMM').format(pickedDate)));
    }

    Widget grid(bool istoday, int dayNumber, int i) {
      return GestureDetector(
        onTap: () => toggleEdit(i),
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 让 Column 垂直方向大小包裹内容
              crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中对齐
              children: <Widget>[
                Text(
                  "$dayNumber",
                  style: TextStyle(
                      fontSize: 18,
                      color: istoday ? Colors.blue : Colors.black,
                      fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
                ),
                Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget gridNoFlag(bool istoday, int dayNumber) {
      return GestureDetector(
        child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 让 Column 垂直方向大小包裹内容
              crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中对齐
              children: <Widget>[
                Text(
                  "$dayNumber",
                  style: TextStyle(
                      fontSize: 18,
                      color: istoday ? Colors.blue : Colors.black,
                      fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          children: [
            // 当前日期
            dateTitle(),
            // 星期
            SizedBox(
              height: 60,
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7列，代表一周的7天
                    childAspectRatio: 2.0, // 单元格宽高比
                  ),
                  // 总的单元格数量
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    // 构建 星期
                    return Align(
                        alignment: Alignment.center,
                        child: Text(getWeekString(index)));
                  }),
            ),
            // 数字日期
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7列，代表一周的7天
                  childAspectRatio: 1.0, // 单元格宽高比
                ),
                // 总的单元格数量
                itemCount: totalitems,
                itemBuilder: (context, index) {
                  // 计算当前单元格对应的日期
                  int dayNumber = index - firstWeekdayOfMonth + 2;

                  // 如果dayNumber在有效日期范围内，显示日期；否则显示空单元格
                  if (!(dayNumber > 0 && dayNumber <= daysInMonth)) {
                    return Container(); // 空单元格
                  }
                  bool istoday = dayNumber == DateTime.now().day &&
                      pickedDate.month == DateTime.now().month &&
                      pickedDate.year == DateTime.now().year;

                  for (int i = 0; i < items.length; i++) {
                    if (index - firstWeekdayOfMonth + 2 ==
                        items[i].crtime.day) {
                      return grid(istoday, dayNumber, i);
                    }
                  }
                  return gridNoFlag(istoday, dayNumber);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 功能：更新当前分组下的印迹列表
  void getDocs({int? year, int? month}) async {
    final ret = await Http(gid: widget.group.id).getDocs(year, month);
    setState(() {
      if (items.isNotEmpty) {
        items.clear();
      }
      if (isNoSelectLevel()) {
        items.clear();
        return;
      }

      for (Doc doc in ret.data) {
        if (isContainSelectLevel(doc.level)) {
          items.add(doc);
        }
      }
      items.sort(compareDocs);
    });
  }

  int compareDocs(Doc a, Doc b) {
    DateTime aTime = a.crtime;
    DateTime bTime = b.crtime;
    return aTime.compareTo(bTime);
  }

  bool isNoSelectLevel() {
    for (bool one in widget.group.config.levels) {
      if (one) {
        return false;
      }
    }
    return true;
  }

  int getSelectLevel() {
    for (int buttonIndex = 0;
        buttonIndex < widget.group.config.levels.length;
        buttonIndex++) {
      if (widget.group.config.levels[buttonIndex]) {
        return buttonIndex;
      }
    }
    return 0;
  }

  bool isContainSelectLevel(int i) {
    return widget.group.config.levels[i];
  }
}

// 文档编辑器组件（直接在卡片内编辑）
class _DocEditor extends StatefulWidget {
  final Doc doc;
  final Group group;
  final Function(Doc) onSave;
  final Function() onDelete;
  final Function() onCancel;

  _DocEditor({
    required this.doc,
    required this.group,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  State<_DocEditor> createState() => _DocEditorState();
}

class _DocEditorState extends State<_DocEditor> {
  late TextEditingController titleController;
  late QuillController quillController;
  late int level;
  late DocConfigration config;
  late DateTime crtime;
  bool isLevelSelected = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.doc.title);

    // 初始化富文本编辑器
    if (widget.doc.content.isNotEmpty) {
      quillController = QuillController(
        document: Document.fromJson(jsonDecode(widget.doc.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      quillController = QuillController.basic();
    }

    level = widget.doc.level;
    config = widget.doc.config;
    crtime = widget.doc.crtime;
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题编辑
          TextField(
            controller: titleController,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '标题',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            enabled: !widget.group.isFreezedOrBuf(),
          ),
          SizedBox(height: 12),

          // 分级选择
          if (!widget.group.isFreezedOrBuf())
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(Level.l.length, (index) {
                  return ChoiceChip(
                    label: Text(Level.l[index]),
                    selected: level == index,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          level = index;
                        });
                      }
                    },
                  );
                }),
              ],
            ),
          SizedBox(height: 12),

          // 工具栏
          if (config.isShowTool!)
            QuillSimpleToolbar(
              controller: quillController,
              config: QuillSimpleToolbarConfig(
                toolbarSize: 35,
                multiRowsDisplay: false,
              ),
            ),

          // 富文本编辑器 - 使用自适应高度
          Container(
            constraints: BoxConstraints(
              minHeight: 150,
              maxHeight: 400,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuillEditor(
              controller: quillController,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              config: QuillEditorConfig(
                scrollable: true,
                autoFocus: false,
                expands: false,
                padding: EdgeInsets.all(12),
              ),
            ),
          ),
          SizedBox(height: 12),

          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 删除和设置按钮
              Row(
                children: [
                  if (!widget.group.isFreezedOrBuf())
                    IconButton(
                      icon: Icon(Icons.settings, size: 20),
                      onPressed: () => _handleSettings(),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                    ),
                  IconButton(
                    icon: Icon(Icons.download, size: 20),
                    onPressed: () => _handleExport(),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              // 取消和保存按钮
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text('取消'),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        widget.group.isFreezedOrBuf() ? null : _handleSave,
                    child: Text('保存'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 保存文档
  void _handleSave() async {
    String content = jsonEncode(quillController.document.toDelta().toJson());
    String plainText = quillController.document.toPlainText();

    // 如果有ID，更新文档
    if (widget.doc.id.isNotEmpty) {
      RequestPutDoc req = RequestPutDoc();
      bool hasChanges = false;

      if (content != widget.doc.content) {
        req.content = content;
        req.plainText = plainText;
        hasChanges = true;
      }
      if (titleController.text != widget.doc.title) {
        req.title = titleController.text;
        hasChanges = true;
      }
      if (level != widget.doc.level) {
        req.level = level;
        hasChanges = true;
      }

      if (hasChanges) {
        final res =
            await Http(gid: widget.group.id, did: widget.doc.id).putDoc(req);
        if (res.isNotOK) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败')),
            );
          }
          return;
        }
      }
    } else {
      // 创建新文档
      final req = RequestPostDoc(
        content: content,
        plainText: plainText,
        title: titleController.text,
        level: level,
        crtime: crtime,
        config: config,
      );
      final ret = await Http(gid: widget.group.id).postDoc(req);
      if (ret.isNotOK) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败')),
          );
        }
        return;
      }
      widget.doc.id = ret.id;
    }

    // 返回更新后的文档
    Doc updatedDoc = Doc(
      id: widget.doc.id,
      title: titleController.text,
      content: content,
      plainText: plainText,
      level: level,
      crtime: crtime,
      uptime: DateTime.now(),
      config: config,
    );

    widget.onSave(updatedDoc);
  }

  // 打开设置弹窗
  void _handleSettings() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DocSettingsDialog(
        gid: widget.group.id,
        did: widget.doc.id.isEmpty ? null : widget.doc.id,
        crtime: crtime,
        config: config,
      ),
    );

    if (result != null) {
      // 如果删除了文档
      if (result['deleted'] == true) {
        widget.onDelete();
        return;
      }

      // 如果有修改
      if (result['changed'] == true) {
        if (widget.doc.id.isNotEmpty) {
          RequestPutDoc req = RequestPutDoc(crtime: result['crtime']);
          req.config = result['config'];
          final res =
              await Http(gid: widget.group.id, did: widget.doc.id).putDoc(req);
          if (res.isNotOK) {
            return;
          }
        }

        setState(() {
          if (result['crtime'] != null) {
            crtime = result['crtime'];
          }
          if (result['config'] != null) {
            config = result['config'];
          }
        });
      }
    }
  }

  // 导出文档
  void _handleExport() {
    showDialog(
      context: context,
      builder: (context) => Export(
        ResourceType.doc,
        title: "导出印迹",
        doc: ExportData(
          content: jsonEncode(quillController.document.toDelta().toJson()),
          title: titleController.text,
          plainText: quillController.document.toPlainText(),
          level: level,
          crtime: crtime,
        ),
      ),
    );
  }
}
