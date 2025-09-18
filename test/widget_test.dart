// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grade12_exam_prep_tutor/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
  // Build the app using the non-Firebase fallback so the test doesn't need
  // to initialize Firebase in the test environment.
  await tester.pumpWidget(const MyApp(firebaseOk: false));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
