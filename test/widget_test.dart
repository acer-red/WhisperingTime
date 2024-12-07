// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp() as Widget);

    // 添加大量列表项
    final addButtonFinder = find.byKey(Key('addtheme')); // 假设添加按钮有一个 Key
    for (int i = 0; i < 10000; i++) {
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle(); // 等待界面渲染完成
    }

    // 检查列表是否正确渲染
    expect(find.byType(ListTile), findsNWidgets(10000));

    // 使用 DevTools 监控 CPU 和内存使用情况
    // ...
  });
}

class MyApp {
  const MyApp();
}
