import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './page/setting/setting.dart';
import 'page/theme/theme.dart';
import 'package:whispering_time/env.dart';

// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsManager().init(); // 在这里调用 init()

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

// class MyAppState extends ChangeNotifier {
//   String _uid = ""; // 使用 _uid 私有变量存储 uid

//   MyAppState() {
//     _loadUid();
//   }

//   Future<void> _loadUid() async {
//     final prefs = await SharedPreferences.getInstance();
//     _uid = prefs.getString('uid') ??
//     prefs.setString('uid', _uid);
//     notifyListeners();
//   }

//   String get uid {
//     if (_uid.isEmpty) {
//       // 如果 _uid 还没有初始化，则返回一个占位值或抛出异常
//       return "loading..."; // 或者 throw Exception("UID is not initialized yet.");
//     }
//     return _uid;
//   }

//   set uid(String value) {
//     _uid = value;
//     notifyListeners();
//   }
// }
class MyAppState extends ChangeNotifier {
  MyAppState();
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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
