import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mobile/app/theme/elderly_theme.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/presentation/screens/spatial_pattern_game_screen.dart';
import 'package:smriti_mobile/features/cognitive_games/games/spatial_pattern/presentation/widgets/pattern_cell_widget.dart';
import 'package:smriti_mobile/features/cognitive_games/presentation/games_home_screen.dart';
import 'package:smriti_mobile/localization/app_localizations.dart';

Widget createTestableWidget(Widget child) {
  return MaterialApp(
    theme: ElderlyTheme.lightTheme,
    locale: const Locale('en'),
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('hi', 'IN'),
      Locale('as', 'IN'),
    ],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  testWidgets('SpatialPatternGameScreen full UI workflow and elderly accessibility', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createTestableWidget(
        const SpatialPatternGameScreen(initialDifficulty: 1),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Intro Screen elements
    expect(find.text('Spatial Pattern Recognition'), findsNWidgets(2)); // AppBar + Hero Card
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Start Activity'), findsOneWidget);

    // Verify non-diagnostic safe language
    expect(find.textContaining('dementia'), findsNothing);
    expect(find.textContaining('cure'), findsNothing);
    expect(find.textContaining('diagnose'), findsNothing);
    expect(find.textContaining('FAIL'), findsNothing);

    // 2. Tap Start Activity to launch game
    await tester.tap(find.text('Start Activity'));
    await tester.pump();

    // Verify study phase banner
    expect(find.text('Look carefully at the pattern...'), findsOneWidget);
    expect(find.text('Memorizing pattern...'), findsOneWidget);

    // 3. Fast-forward timer past study duration (4000ms for Level 1)
    await tester.pump(const Duration(milliseconds: 4100));
    await tester.pump();

    // Verify recall phase
    expect(find.textContaining('Where were the'), findsOneWidget);
    expect(find.text('Submit Answers'), findsOneWidget);

    // Find grid cells and tap the first one
    final cellFinder = find.byType(PatternCellWidget);
    expect(cellFinder, findsWidgets);

    await tester.tap(cellFinder.first);
    await tester.pump();

    expect(find.textContaining('Selected: 1 of'), findsOneWidget);

    // Tap Submit Answers
    await tester.tap(find.text('Submit Answers'));
    await tester.pump();

    // Verify feedback phase
    expect(find.text('Review your results:'), findsOneWidget);
    expect(find.text('Next Pattern'), findsOneWidget);

    // Verify button touch target size meets >= 56dp
    final nextBtnFinder = find.widgetWithText(ElevatedButton, 'Next Pattern');
    final Size btnSize = tester.getSize(nextBtnFinder);
    expect(btnSize.height, greaterThanOrEqualTo(56.0));

    // Clean up timer by tapping next pattern and letting study timer advance
    await tester.tap(find.text('Next Pattern'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4500));
  });

  testWidgets('GamesHomeScreen lists all cognitive activities', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createTestableWidget(
        const GamesHomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cognitive Activities'), findsOneWidget);
    expect(find.text('Spatial Pattern Recognition'), findsOneWidget);
    expect(find.text('Play Spatial Pattern'), findsOneWidget);
  });
}
