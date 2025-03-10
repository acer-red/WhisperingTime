import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'pages/theme/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whispering_time/utils/env.dart';
import 'pages/setting/setting.dart';
import 'package:whispering_time/services/Isar/config.dart';
import 'package:whispering_time/services/Isar/env.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getMainStoreDir();
  print("数据存储路径:${dir.path}");
  
  isar = await Isar.open(
    [ConfigSchema], // 你的模型 Schema 列表
    directory: dir.path, // 指定数据库存储目录
    inspector: true, // 启用 Isar Inspector 连接
  );
  await Config().init();

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
        home: MyHomePage(),
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
        throw UnimplementedError('no widget');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: panel(idx),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "主页"),
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
