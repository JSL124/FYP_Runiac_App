import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/app.dart';

void main() {
  testWidgets('Runiac app shell shows static tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('Maps tab shows static route discovery placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RuniacApp());

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Search routes or area'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Shared Routes'), findsOneWidget);
    expect(
      find.text('Nearby route suggestions will appear after location setup.'),
      findsOneWidget,
    );
    expect(find.text('Route preview'), findsOneWidget);
    expect(find.text('Details will appear after setup.'), findsOneWidget);
    expect(find.text('Community routes'), findsOneWidget);
    expect(find.text('Shared route details will appear here.'), findsOneWidget);

    await tester.drag(find.text('Shared Routes'), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(find.text('Saved routes'), findsOneWidget);
    expect(find.text('Saved routes will be available later.'), findsOneWidget);
  });
}
