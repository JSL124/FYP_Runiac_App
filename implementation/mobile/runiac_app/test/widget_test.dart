import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

void main() {
  testWidgets('Runiac app shell shows static tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Runiac'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
  });
}
