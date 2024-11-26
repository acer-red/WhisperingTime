import 'package:flutter/material.dart';
import 'group/list.dart';
import 'package:whispering_time/http.dart';

// 主题页面 - 列表页面
class Item {
  bool isSubmitted;
  TextEditingController _textEditingController = TextEditingController();
  String? tid;
  String? themename;
  Item({this.tid, this.themename, required this.isSubmitted})
      : _textEditingController = TextEditingController(text: themename);
}

class ThemePage extends StatefulWidget {
  @override
  State createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();

    final list = Http().gettheme();
    list.then((list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == "") {
          continue;
        }
        setState(() {
          _items.add(Item(
              tid: list[i].id, themename: list[i].name, isSubmitted: true));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(left: 40, top: 10.0),
        child: StatefulBuilder(builder: (context, setState) {
          return IntrinsicWidth(
              child: _items[index].isSubmitted
                  // 文本模式
                  ? Row(
                      children: [
                        EditableTextField(
                          _items[index],
                          onEdit: () {
                            setState(
                                () {}); // Triggers a rebuild of the parent widget.
                          },
                        ),
                      ],
                    )
                  // 编辑模式
                  : Row(children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: '主题名',
                          ),
                          controller: _items[index]._textEditingController,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => submit(_items[index])),
                      IconButton(
                          icon: Icon(Icons.remove_circle_rounded),
                          onPressed: () => remove(_items[index])),
                    ]));
        }),
      ),
    );
  }

  void add() {
    setState(() {
      _items.add(Item(isSubmitted: false));
    });
  }

  void submit(Item item) {
    if (item._textEditingController.text == "") {
      return;
    }

    if (item.tid == null) {
      submitNoID(item);
      return;
    }
    submitID(item);
  }

  void submitNoID(Item item) {
    final res = Http(content: item._textEditingController.text).posttheme();
    res.then((res) {
      if (res['err'] != 0) {
        return;
      }
      setState(() {
        item.themename = res['data']['name'];
        item.tid = res['data']['id'];
        item.isSubmitted = true;
      });
    });
  }

  void submitID(Item item) {
    if (item.themename == item._textEditingController.text ||
        item._textEditingController.text == "") {
      setState(() {
        item.isSubmitted = true;
      });
      return;
    }

    final res = Http(content: item._textEditingController.text)
        .puttheme(item._textEditingController.text, item.tid!);

    res.then((res) {
      if (res['err'] != 0) {
        return;
      }

      setState(() {
        item.themename = res['data']['name'];
        item.isSubmitted = true;
      });
    });
  }

  void remove(Item item) {
    if (item.tid == null) {
      setState(() {
        _items.remove(item);
      });
      return;
    }

    final res = Http(content: item.tid).deletetheme();
    res.then((res) {
      if (res['err'] != 0) {
        return;
      }
      setState(() {
        _items.remove(item);
      });
    });
  }
}

// 主题条控件
class EditableTextField extends StatefulWidget {
  final Item item;
  final Function onEdit;
  EditableTextField(this.item, {Key? key, required this.onEdit})
      : super(key: key);

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool _showEditButton = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _showEditButton = true),
      onExit: (_) => setState(() => _showEditButton = false),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => letadd()));
                    },
                    child: Text(widget.item._textEditingController.text),
                  ),
                ),
                if (_showEditButton)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        widget.item.isSubmitted = false;
                      });
                      widget.onEdit();
                    },
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget letadd() {
    return ListPage(
        titlename: widget.item._textEditingController.text,
        tid: widget.item.tid!);
  }
}
