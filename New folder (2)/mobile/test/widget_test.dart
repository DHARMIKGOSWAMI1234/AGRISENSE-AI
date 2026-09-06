import 'package:flutter_test/flutter_test.dart';
import 'package:smriti_mobile/app/app.dart';
import 'package:smriti_mobile/data/local/database/app_database.dart';

void main() {
  testWidgets('SmritiApp cold launch test', (WidgetTester tester) async {
    await AppDatabase().initialize();
    await tester.pumpWidget(const SmritiApp());
    expect(find.byType(SmritiApp), findsOneWidget);
  });
}
