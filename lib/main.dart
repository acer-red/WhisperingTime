import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whispering_time/welcome.dart';
import 'package:whispering_time/page/home/appbar.dart';
import 'package:whispering_time/service/sp/sp.dart';
import 'package:whispering_time/service/isar/config.dart';
import 'package:window_manager/window_manager.dart';
import 'package:whispering_time/util/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 在桌面平台上设置窗口大小为类似手机的尺寸
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(375, 812), // iPhone 尺寸
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(320, 568), // 最小尺寸，防止窗口过小
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await SP().init();
  final uid = SP().getUID();
  print(uid);
  await Config().init(uid);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, WindowListener {
  void _resetKeyboardState() {
    // ignore: invalid_use_of_visible_for_testing_member
    HardwareKeyboard.instance.clearState();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetKeyboardState();

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Clear any stale pressed-key state when the app resumes or loses focus.
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      _resetKeyboardState();
    }
  }

  @override
  void onWindowFocus() {
    _resetKeyboardState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: '枫迹',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(255, 238, 227, 1)),
        ),
        home: enterPage(),
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

  Widget enterPage() {
    return SP().getIsAutoLogin() ? HomePage() : Welcome();
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState();
}
