import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whispering_time/utils/path.dart';
import 'package:whispering_time/services/Isar/config.dart';
import 'package:whispering_time/services/Isar/font.dart';
import 'package:whispering_time/services/Isar/env.dart';
import 'package:whispering_time/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getMainStoreDir();
  print("数据存储路径:${dir.path}");

  isar = await Isar.open(
    [ConfigSchema, FontSchema], // 你的模型 Schema 列表
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
              seedColor: const Color.fromRGBO(255, 238, 227,1)),
        ),
        home: HomePage(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh', 'CH'),
          // const Locale('en', 'US'),
        ],
        locale: Locale('zh'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState();
}