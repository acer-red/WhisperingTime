import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page/theme/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whispering_time/env.dart';
import './page/setting/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsManager().init(); // 在这里调用 init()
  Setting();
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 211, 118, 5)),
        ),
        home: Overlay( 
        key: Msg.overlayKey, 
        initialEntries: [
          OverlayEntry(builder: (context) => MyHomePage()),
        ],
      ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh', 'CH'),
          const Locale('en', 'US'),
        ],
        locale: Locale('zh'),
      ),
    );
  }
}

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
              BottomNavigationBarItem(
                  icon: Icon(Icons.sunny), label: "主题"),
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
