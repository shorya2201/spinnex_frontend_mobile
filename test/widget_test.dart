import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kaal_spinnex/main.dart';

void main() {
  tearDown(() {
    Get.reset();
  });

  testWidgets('App Launches, Displays Splash, and Navigates to Home View Smoke Test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const NeonSpinApp());

    // Verify splash elements exist on initial frame
    expect(find.text('NEON SPIN'), findsOneWidget);

    // Pump timer for splash delay (3 seconds) to navigate to Home
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Home screen components are loaded
    expect(find.text('SPINNEX'), findsOneWidget);
    expect(find.text('Truth or Dare'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });
}
