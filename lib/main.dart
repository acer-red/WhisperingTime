import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whispering_time/services/sp/sp.dart';
import 'package:whispering_time/pages/welcome.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SP().init();
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
              seedColor: const Color.fromRGBO(255, 238, 227, 1)),
        ),
        home: Welcome(),
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
