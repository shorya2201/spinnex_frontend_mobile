import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaal_spinnex/data/models/player_model.dart';
import 'package:kaal_spinnex/modules/game/widgets/guest_waiting_overlay.dart';
import 'package:kaal_spinnex/modules/game/widgets/mode_spinner.dart';
import 'package:kaal_spinnex/modules/game/widgets/selector_widgets.dart';

void main() {
  group('Multiplayer & Custom Widgets Tests', () {
    // ─── GuestWaitingOverlay ──────────────────────────────────────
    group('GuestWaitingOverlay Tests', () {
      // Positive Cases
      testWidgets('should render awaiting approval text and room code badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GuestWaitingOverlay(
                hostName: 'HostAlice',
                roomCode: 'NEON88',
                onCancel: () {},
              ),
            ),
          ),
        );

        // Allow animation frame
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.textContaining('AWAITING APPROVAL'), findsOneWidget);
        expect(find.text('NEON88'), findsOneWidget);
        expect(find.text('Cancel & Leave'), findsOneWidget);
      });

      testWidgets('should trigger onCancel callback when Cancel & Leave button is tapped', (tester) async {
        bool canceled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GuestWaitingOverlay(
                hostName: 'HostAlice',
                roomCode: 'NEON88',
                onCancel: () => canceled = true,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final cancelButton = find.text('Cancel & Leave');
        expect(cancelButton, findsOneWidget);

        await tester.tap(cancelButton);
        await tester.pump();

        expect(canceled, isTrue);
      });

      // Negative & Edge Cases
      testWidgets('should render safely with empty room code and host name', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GuestWaitingOverlay(
                hostName: '',
                roomCode: '',
                onCancel: () {},
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.textContaining('AWAITING APPROVAL'), findsOneWidget);
        expect(find.byType(PopScope), findsOneWidget);
      });
    });

    // ─── ModeSpinner ──────────────────────────────────────────────
    group('ModeSpinner Tests', () {
      // Positive Cases
      testWidgets('should render for Party mode category', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: ModeSpinner(category: 'Party (Friends)'),
              ),
            ),
          ),
        );

        expect(find.byType(ModeSpinner), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should render for Spicy mode category', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: ModeSpinner(category: 'Spicy (Couples)'),
              ),
            ),
          ),
        );

        expect(find.byType(ModeSpinner), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should render for Classic mode category', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: ModeSpinner(category: 'Classic (Family)'),
              ),
            ),
          ),
        );

        expect(find.byType(ModeSpinner), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      });

      // Negative & Edge Cases
      testWidgets('should fallback gracefully for unknown and empty category strings', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: ModeSpinner(category: 'Unknown / Random Category'),
              ),
            ),
          ),
        );

        expect(find.byType(ModeSpinner), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: ModeSpinner(category: ''),
              ),
            ),
          ),
        );

        expect(find.byType(ModeSpinner), findsOneWidget);
      });
    });

    // ─── CyberWheelWidget ─────────────────────────────────────────
    group('CyberWheelWidget Tests', () {
      final testPlayers = [
        PlayerModel(name: 'Neon Rider', emoji: '👾', color: Colors.pink),
        PlayerModel(name: 'Cyber Fox', emoji: '🦊', color: Colors.cyan),
        PlayerModel(name: 'Laser Bob', emoji: '⚡', color: Colors.green),
      ];

      // Positive Cases
      testWidgets('should display play arrow icon when not spinning', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CyberWheelWidget(
                  players: testPlayers,
                  currentAngle: 0.0,
                  isSpinning: false,
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
        expect(find.byIcon(Icons.sync_rounded), findsNothing);
      });

      testWidgets('should display sync icon when spinning is in progress', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CyberWheelWidget(
                  players: testPlayers,
                  currentAngle: 1.5,
                  isSpinning: true,
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      });

      // Negative & Edge Cases
      testWidgets('should handle empty players list without crashing', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CyberWheelWidget(
                  players: [],
                  currentAngle: 0.0,
                  isSpinning: false,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CyberWheelWidget), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      });
    });
  });
}
