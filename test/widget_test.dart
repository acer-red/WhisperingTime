import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whispering_time/page/theme/group/group.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp() as Widget);
    var a = Group(
        id: "",
        name: "",
        overtime: DateTime.now().add(const Duration(hours: 2)));
    expect(a.isBufTime(), true);
  });
}

// class MyApp {
//   const MyApp();
// }
