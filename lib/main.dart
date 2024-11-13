import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './page/setting/setting.dart';
import 'page/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

class MyAppState extends ChangeNotifier {
  String _uid = "";
  String get uid => _uid;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  MyAppState() : _uid = Uuid().v4() {
    loadUid();
  }

  Future<void> loadUid() async {
    // prefs = await SharedPreferences.getInstance();
    _uid = (await prefs).getString('uid') ?? const Uuid().v4();
    print("uid=$_uid");
    await (await prefs).setString('uid', _uid);

    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // 告诉 Dart 编译器这个方法是重写父类 ( StatefulWidget ) 的方法。
  @override
  // 它返回一个 _MyHomePageState 类型的对象
  State<MyHomePage> createState() =>
      // 它创建了一个 _MyHomePageState 的实例并返回。 _MyHomePageState  是一个私有类，它定义了 MyHomePage 这个 Widget 的状态和行为。
      _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int idx = 0;

  Widget panel(int idx) {
    switch (idx) {
      case 0:
        return ThemePage();
      case 1:
        return SettingsPage();
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
