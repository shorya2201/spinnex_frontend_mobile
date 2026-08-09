// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaal_spinnex/main.dart';

void main() {
  testWidgets('Game Setup Screen Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeonSpinApp());

    // Wait for splash screen navigation delay (3 seconds) to finish
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that we are on the home screen.
    expect(find.text('SPINNEX'), findsOneWidget);
    expect(find.text('Truth or Dare'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });
}
