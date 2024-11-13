import 'package:flutter/material.dart';
import './event/list.dart';
import '../../http.dart';

import 'package:provider/provider.dart';
import 'package:whispering_time/main.dart';

// 主题页面 - 列表页面
class Item {
  bool isSubmitted;
  TextEditingController _textEditingController = TextEditingController();
  final String? themeid;
  final String? themename;
  Item({this.themeid, this.themename, required this.isSubmitted}):_textEditingController = TextEditingController(text: themename);
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
    final uid = Provider.of<MyAppState>(context, listen: false).uid;
    final list = Http(uid: uid).gettheme();
    list.then((list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == "") {
          continue;
        }
        setState(() {
          _items.add(Item(
              themeid: list[i].id, themename: list[i].name, isSubmitted: true));
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
    Http(
            data: item._textEditingController.text,
            uid: Provider.of<MyAppState>(context, listen: false).uid)
        .posttheme();

    setState(() {
      item.isSubmitted = true;
    });
  }

  void remove(Item item) {
    setState(() {
      _items.remove(item);
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListPage(Data(
                                  name: widget
                                      .item._textEditingController.text))));
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
}
