import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/utils/preferences_service.dart';

class FakePreferencesService extends PreferencesService {
  bool fake = false;

  @override
  Future<bool> loadTheme() async => fake;

  @override
  Future<void> saveTheme(bool isDark) async {
    fake = isDark;
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
