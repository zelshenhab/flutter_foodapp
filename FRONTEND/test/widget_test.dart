import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_foodapp/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // First frame
    await tester.pump();

    // SplashScreen should appear (CircularProgressIndicator)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}