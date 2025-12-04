import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:whispering_time/pages/doc/setting.dart';
import 'package:whispering_time/pages/doc/scene.dart';
import 'package:whispering_time/utils/env.dart';
import 'package:whispering_time/utils/ui.dart';
import 'package:whispering_time/services/http/http.dart';
import 'package:whispering_time/services/isar/config.dart';
import 'package:intl/intl.dart';
import 'package:whispering_time/utils/time.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:whispering_time/utils/export.dart';
import 'package:whispering_time/utils/picker_wheel.dart';
import 'package:whispering_time/pages/group/model.dart';
import 'package:whispering_time/pages/doc/model.dart';
import 'package:whispering_time/pages/doc/manager.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class DocList extends StatefulWidget {
  final Group group;
  final String tid;

  DocList({required this.group, required this.tid});

  @override
  State createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  late DocsManager docsManager;

  DateTime pickedDate = DateTime.now();
  int? editingIndex; // 当前正在编辑的Card索引

  @override
  void initState() {
    super.initState();
    docsManager = DocsManager(widget.group.id);
    docsManager.addListener(() {
      if (mounted) setState(() {});
    });
    docsManager.fetchDocs(config: widget.group.config);
    log.d(widget.group.toString());
  }

  @override
  void dispose() {
    docsManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.group.name), centerTitle: true, actions: [
        IconButton(icon: Icon(Icons.add), onPressed: () => createNewDoc()),
        IconButton(
            onPressed: () => playDocPage(), icon: Icon(Icons.play_arrow)),
        IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () => _showBottomMenuOfDocList(context)),
      ]),
      body: widget.group.config.viewType == 1 ? screenCalendar() : screenCard(),
    );
  }

  void _showBottomMenuOfDocList(BuildContext context) {
    // 记录初始状态
    final initialViewType = widget.group.config.viewType;
    final initialSortType = widget.group.config.sortType;
    final initialLevels = List<bool>.from(widget.group.config.levels);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _FilterBottomSheet(
          initialViewType: widget.group.config.viewType,
          initialSortType: widget.group.config.sortType,
          initialLevels: widget.group.config.levels,
          onChanged: (v, s, l) {
            _updateConfig(
                viewType: v, sortType: s, levels: l, saveToServer: false);
          },
        );
      },
    ).whenComplete(() {
      // 比较是否有变化，如果有则更新
      bool isLevelsChanged =
          !listEquals(initialLevels, widget.group.config.levels);
      if (initialViewType != widget.group.config.viewType ||
          initialSortType != widget.group.config.sortType ||
          isLevelsChanged) {
        _syncConfigToServer();
      }
    });
  }

  void _updateConfig(
      {int? viewType,
      int? sortType,
      List<bool>? levels,
      bool saveToServer = true}) async {
    setState(() {
      if (viewType != null) widget.group.config.viewType = viewType;
      if (sortType != null) widget.group.config.sortType = sortType;
      if (levels != null) widget.group.config.levels = levels;

      // Re-sort or re-filter items
      docsManager.filterAndSort(widget.group.config);
    });

    if (saveToServer) {
      _syncConfigToServer();
    }
  }

  void _syncConfigToServer() async {
    // Save to server
    RequestPutGroup req = RequestPutGroup();
    req.config = GroupConfigNULL(
      viewType: widget.group.config.viewType,
      sortType: widget.group.config.sortType,
      levels: widget.group.config.levels,
      isMulti: widget.group.config.isMulti,
      isAll: widget.group.config.isAll,
    );
    await Http(tid: widget.tid, gid: widget.group.id).putGroup(req);
  }

  void playDocPage() {
    const Duration tim = Duration(milliseconds: 800);
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a, b) {
            return ScenePage(
              docs: docsManager.items,
              group: widget.group,
            );
          },
          transitionDuration: tim,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ));
  }

  // 创建新文档
  void createNewDoc() {
    // 防止重复创建空文档
    if (docsManager.items.isNotEmpty &&
        docsManager.items[0].id.isEmpty &&
        editingIndex == 0) {
      return;
    }
    Doc newDoc = Doc(
      id: '',
      title: '',
      content: '',
      plainText: '',
      level: getSelectLevel(),
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      config: DocConfig(isShowTool: Config.instance.defaultShowTool),
    );

    setState(() {
      docsManager.insertDoc(newDoc);
      editingIndex = 0;
    });
  }

  // UI: 主体内容-卡片模式
  Widget screenCard() {
    return ListView.builder(
        itemCount: docsManager.items.length,
        itemBuilder: (context, index) {
          final item = docsManager.items[index];
          final isEditing = editingIndex == index;

          return GestureDetector(
            onLongPress: () => _showBottomMenuOfDoc(context, item),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: isEditing
                  ? _buildEditingCard(index, item)
                  : _buildPreviewCard(index, item),
            ),
          );
        });
  }

  // 显示单个文档底部菜单
  void _showBottomMenuOfDoc(BuildContext context, Doc item) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.settings,
                    color: Theme.of(context).colorScheme.primary),
                title: Text('设置'),
                onTap: () {
                  Navigator.pop(context);
                  enterSettingDialog(item);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                title: Text('删除'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 确认删除对话框
  void _confirmDelete(Doc item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除这条印迹吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final res =
                    await Http(gid: widget.group.id, did: item.id).deleteDoc();
                if (res.isNotOK) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('删除失败')),
                    );
                  }
                  return;
                }
                setState(() {
                  docsManager.removeDoc(item);
                });
              },
              child: Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 打开设置对话框
  void enterSettingDialog(Doc item) async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => DocSettingsDialog(
            gid: widget.group.id,
            did: item.id,
            createAt: item.createAt,
            config: item.config));

    if (result == null) return;

    if (result['deleted'] == true) {
      setState(() {
        docsManager.removeDoc(item);
      });
      return;
    }

    if (result['changed'] == true) {
      setState(() {
        if (result['createAt'] != null) {
          item.createAt = result['createAt'];
        }
        if (result['config'] != null) {
          item.config = result['config'];
        }
      });
    }
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
                    Time.string(item.createAt),
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
    return Cardx(
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
      // Sync _allFetchedDocs
      Doc oldDoc = docsManager.items[index];
      docsManager.updateDoc(oldDoc, updatedDoc, widget.group.config);
      editingIndex = null;
    });
  }

  // 处理文档删除
  void handleDocDelete(int index) {
    setState(() {
      Doc doc = docsManager.items[index];
      docsManager.removeDoc(doc);
      editingIndex = null;
    });
  }

  // 处理取消编辑（针对新建但未保存的文档）
  void handleDocCancel(int index) {
    setState(() {
      // 如果是空ID的新文档，取消时删除
      if (docsManager.items[index].id.isEmpty) {
        Doc doc = docsManager.items[index];
        docsManager.removeDocFromItemsAndAll(doc);
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

    chooseDate() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: _DatePickerBottomSheet(
              docsManager: docsManager,
              initialDate: pickedDate,
              onConfirm: (DateTime date) {
                setState(() {
                  pickedDate = date;
                });
                getDocs(year: date.year, month: date.month);
              },
            ),
          );
        },
      );
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
                      color: istoday ? Colors.blue : Colors.grey,
                      fontWeight: istoday ? FontWeight.w700 : FontWeight.w400),
                ),
                Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: Colors.transparent,
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

                  for (int i = 0; i < docsManager.items.length; i++) {
                    if (index - firstWeekdayOfMonth + 2 ==
                        docsManager.items[i].createAt.day) {
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
    docsManager.fetchDocs(
        year: year, month: month, config: widget.group.config);
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
}

class _FilterBottomSheet extends StatefulWidget {
  final int initialViewType;
  final int initialSortType;
  final List<bool> initialLevels;
  final Function(int, int, List<bool>) onChanged;

  const _FilterBottomSheet({
    Key? key,
    required this.initialViewType,
    required this.initialSortType,
    required this.initialLevels,
    required this.onChanged,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late int viewType;
  late int sortType;
  late List<bool> levels;

  @override
  void initState() {
    super.initState();
    viewType = widget.initialViewType;
    sortType = widget.initialSortType;
    levels = List.from(widget.initialLevels);
  }

  void _updateState(VoidCallback fn) {
    setState(fn);
    widget.onChanged(viewType, sortType, levels);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          ShortGreyLine(),
          SizedBox(height: 10),
          // View Mode
          ListTile(
            title: Text('显示模式'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text('卡片'),
                  selected: viewType == 0,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => viewType = 0);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('日历'),
                  selected: viewType == 1,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => viewType = 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Sort Mode
          ListTile(
            title: Text('排序模式'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text('创建时间'),
                  selected: sortType == 0,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => sortType = 0);
                    }
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('更新时间'),
                  selected: sortType == 1,
                  onSelected: (bool selected) {
                    if (selected) {
                      _updateState(() => sortType = 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Level Selection
          ExpansionTile(
            title: Text('分级筛选'),
            children: List.generate(Level.l.length, (index) {
              return CheckboxListTile(
                title: Text(Level.l[index]),
                value: levels[index],
                onChanged: (bool? value) {
                  if (value != null) {
                    _updateState(() => levels[index] = value);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class Cardx extends StatefulWidget {
  final Doc doc;
  final Group group;
  final Function(Doc) onSave;
  final Function() onDelete;
  final Function() onCancel;

  Cardx({
    required this.doc,
    required this.group,
    required this.onSave,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  State<Cardx> createState() => _Cardx();
}

class _Cardx extends State<Cardx> {
  late TextEditingController titleController;
  late QuillController quillController;
  late FocusNode _focusNode;
  late int level;
  late DocConfig config;
  late DateTime createAt;
  bool isLevelSelected = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
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

    // 监听文档变化，拦截图片插入
    quillController.document.changes.listen(_onDocumentChange);

    level = widget.doc.level;
    config = widget.doc.config;
    createAt = widget.doc.createAt;
  }

  // 监听文档变化，处理图片上传
  void _onDocumentChange(DocChange event) async {
    // 获取文档的所有内容
    final delta = quillController.document.toDelta();

    // 遍历查找图片
    int offset = 0;
    for (int i = 0; i < delta.length; i++) {
      final op = delta.elementAt(i);

      if (op.data is Map && (op.data as Map).containsKey('image')) {
        final imageData = op.data as Map;
        final imageSource = imageData['image'] as String;

        // 如果是本地文件路径，则上传
        if (imageSource.startsWith('file://') ||
            (!imageSource.startsWith('http://') &&
                !imageSource.startsWith('https://'))) {
          // 去除 file:// 前缀
          String localPath = imageSource;
          if (localPath.startsWith('file://')) {
            localPath = localPath.substring(7);
          }

          try {
            // 读取图片文件
            final file = File(localPath);
            if (!await file.exists()) {
              log.w('图片文件不存在: $localPath');
              offset += (op.length ?? 1);
              continue;
            }

            final bytes = await file.readAsBytes();

            // 判断图片类型
            IMGType imgType;
            if (localPath.toLowerCase().endsWith('.png')) {
              imgType = IMGType.png;
            } else {
              imgType = IMGType.jpg;
            }

            // 上传图片
            final req = RequestPostImage(type: imgType, data: bytes);
            final res = await Http(gid: widget.group.id).postImage(req);

            if (res.isOK) {
              // 删除旧的图片引用并插入文件名（不是完整URL）
              quillController.document.delete(offset, 1);
              quillController.document
                  .insert(offset, BlockEmbed.image(res.name));

              log.i('图片上传成功，文件名: ${res.name}');
            } else {
              log.e('图片上传失败: ${res.msg}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('图片上传失败: ${res.msg}')),
                );
              }
            }
          } catch (e) {
            log.e('处理图片上传失败: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('图片上传失败: $e')),
              );
            }
          }
        }
      }

      offset += (op.length ?? 1);
    }
  }

  void _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      final text = data.text!;
      final selection = quillController.selection;
      if (!selection.isValid) {
        return;
      }
      quillController.replaceText(
        selection.start,
        selection.end - selection.start,
        text,
        null,
      );
      quillController.updateSelection(
        TextSelection.collapsed(offset: selection.start + text.length),
        ChangeSource.local,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 获取自定义的嵌入构建器，自动拼接图片服务器地址
  List<EmbedBuilder> _getCustomEmbedBuilders() {
    return [
      // 自定义图片构建器
      _CustomImageEmbedBuilder(),
      // 添加其他默认的嵌入构建器（视频等）
      ...(kIsWeb
              ? FlutterQuillEmbeds.editorWebBuilders()
              : FlutterQuillEmbeds.editorBuilders())
          .where((builder) => builder.key != 'image'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题和分级选择
          Row(
            children: [
              // 标题编辑
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: titleController,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '标题',
                    border: titleController.text.trim().isEmpty
                        ? OutlineInputBorder()
                        : InputBorder.none,
                    enabledBorder: titleController.text.trim().isEmpty
                        ? OutlineInputBorder()
                        : InputBorder.none,
                    focusedBorder: titleController.text.trim().isEmpty
                        ? OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                          )
                        : InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => setState(() {}),
                  enabled: !widget.group.isFreezedOrBuf(),
                ),
              ),
              SizedBox(width: 8),
              // 分级选择按钮
              TextButton(
                onPressed:
                    widget.group.isFreezedOrBuf() ? null : _showLevelDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(Level.l[level]),
              ),
            ],
          ),
          SizedBox(height: 12),

          // 工具栏
          if (config.isShowTool!)
            QuillSimpleToolbar(
              controller: quillController,
              config: QuillSimpleToolbarConfig(
                color: Colors.transparent,
                toolbarSize: 35,
                multiRowsDisplay: false,
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              ),
            ),

          // 富文本编辑器 - 使用自适应高度
          Container(
            constraints: BoxConstraints(
              minHeight: 150,
              maxHeight: 400,
            ),
            decoration: !quillController.document.isEmpty()
                ? null
                : BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
                    _handlePaste,
                const SingleActivator(LogicalKeyboardKey.keyV, control: true):
                    _handlePaste,
              },
              child: QuillEditor(
                controller: quillController,
                focusNode: _focusNode,
                scrollController: ScrollController(),
                config: QuillEditorConfig(
                  embedBuilders: _getCustomEmbedBuilders(),
                  scrollable: true,
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.all(12),
                ),
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
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text('取消'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        widget.group.isFreezedOrBuf() ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 显示分级选择对话框
  void _showLevelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择分级'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(Level.l.length, (index) {
              return ListTile(
                title: Text(Level.l[index]),
                leading: RadioGroup(
                  groupValue: level,
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        level = value;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Radio<int>(
                    value: index,
                  ),
                ),
                onTap: () {
                  setState(() {
                    level = index;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
        );
      },
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
        createAt: createAt,
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
      createAt: createAt,
      updateAt: DateTime.now(),
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
        createAt: createAt,
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
          RequestPutDoc req = RequestPutDoc(createAt: result['createAt']);
          req.config = result['config'];
          final res =
              await Http(gid: widget.group.id, did: widget.doc.id).putDoc(req);
          if (res.isNotOK) {
            return;
          }
        }

        setState(() {
          if (result['createAt'] != null) {
            createAt = result['createAt'];
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
          createAt: createAt,
        ),
      ),
    );
  }
}

class _CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    var imageSource = embedContext.node.value.data as String;

    // 如果不是完整URL（不以http开头），则拼接服务器地址
    if (!imageSource.startsWith('http://') &&
        !imageSource.startsWith('https://')) {
      final serverAddress = Config.instance.serverAddress;
      final uid = Config.instance.uid;
      imageSource = '$serverAddress/image/$uid/$imageSource';
    }

    // 使用默认的图片widget显示
    return Image.network(
      imageSource,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
                SizedBox(height: 8),
                Text('图片加载中...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.grey[200],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 4),
              Text('图片加载失败',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        );
      },
    );
  }
}

class _DatePickerBottomSheet extends StatefulWidget {
  final DocsManager docsManager;
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;

  const _DatePickerBottomSheet({
    Key? key,
    required this.docsManager,
    required this.initialDate,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _DatePickerBottomSheetState createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late int selectedYear;
  late int selectedMonth;
  late List<int> years;
  late List<int> months;
  late FixedExtentScrollController yearController;
  late FixedExtentScrollController monthController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;

    years = widget.docsManager.getAvailableYears();
    if (years.isEmpty) {
      years = [DateTime.now().year];
    }
    if (!years.contains(selectedYear)) {
      selectedYear = years.first;
    }

    _updateMonths();

    yearController = FixedExtentScrollController(
        initialItem: years.indexOf(selectedYear) != -1
            ? years.indexOf(selectedYear)
            : 0);
    monthController = FixedExtentScrollController(
        initialItem: months.indexOf(selectedMonth) != -1
            ? months.indexOf(selectedMonth)
            : 0);
  }

  void _updateMonths() {
    List<String> monthStrs = widget.docsManager.getAvailableMonth(selectedYear);
    months = monthStrs.map((e) => int.parse(e)).toList();
    if (months.isEmpty) {
      months = [1];
    }
    if (!months.contains(selectedMonth)) {
      selectedMonth = months.first;
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  widget.onConfirm(DateTime(selectedYear, selectedMonth));
                  Navigator.pop(context);
                },
                child: Text('确定'),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                YearPickerWheel(
                  selectedYear: selectedYear,
                  years: years,
                  controller: yearController,
                  onYearChanged: (year) {
                    setState(() {
                      selectedYear = year;
                      _updateMonths();
                      // Reset month controller if needed or jump to new index
                      if (months.contains(selectedMonth)) {
                        monthController
                            .jumpToItem(months.indexOf(selectedMonth));
                      } else {
                        monthController.jumpToItem(0);
                      }
                    });
                  },
                ),
                MonthPickerWheel(
                  selectedMonth: selectedMonth,
                  months: months,
                  controller: monthController,
                  onMonthChanged: (month) {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
