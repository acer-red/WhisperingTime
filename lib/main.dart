import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 该函数只是告知 Flutter 运行 MyApp 中定义的应用
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: '枫迹',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 211, 118, 5)),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

// MyAppState 定义应用运行所需的数据
// 确保向任何通过 watch 方法跟踪 MyAppState 的对象发出通知。
// notifyListeners();
class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // 告诉 Dart 编译器这个方法是重写父类 ( StatefulWidget ) 的方法。
  @override
  // 它返回一个 _MyHomePageState 类型的对象
  State<MyHomePage> createState() =>
      // 它创建了一个 _MyHomePageState 的实例并返回。 _MyHomePageState  是一个私有类，它定义了 MyHomePage 这个 Widget 的状态和行为。
      _MyHomePageState();
}

class Item {
  bool isSubmitted;
  final TextEditingController _textEditingController = TextEditingController();

  Item({required this.isSubmitted});
}

class _MyHomePageState extends State<MyHomePage> {
  int idx = 0;

  Widget panel(int idx) {
    switch (idx) {
      case 0:
        return ListPage();
      case 1:
        return const SettingsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
  }

  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: panel(idx),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.checklist), label: "列表"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置"),
            ],
            currentIndex: idx,
            onTap: (x) {
              setState(() {
                idx = x;
              });
            }),
      );
    });
  }
}

class ListPage extends StatefulWidget {
  @override
  State createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Item> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
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

  void _addItem() {
    setState(() {
      _items.add(Item(isSubmitted: false));
    });
  }

  void submit(Item item) {
    if (item._textEditingController.text == "") {
      return;
    }
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
                  child: Text(widget.item._textEditingController.text),
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('settings');
  }
}
