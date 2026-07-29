import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:runiac_app/features/profile/domain/models/user_profile_read_model.dart';
import 'package:runiac_app/features/profile/presentation/about_runiac_screen.dart';
import 'package:runiac_app/features/profile/presentation/data/account_profile_demo_snapshots.dart';
import 'package:runiac_app/features/profile/presentation/widgets/account_profile_sections.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  setUpAll(() {
    // Avoids a real platform channel round-trip when AboutRuniacScreen is
    // pushed without version overrides, matching how the real routing code
    // constructs it (`const AboutRuniacScreen()`).
    PackageInfo.setMockInitialValues(
      appName: 'Runiac',
      packageName: 'app.runiac',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget buildManageSection() {
    return MaterialApp(
      home: Scaffold(
        body: AccountManageSection(
          rows: accountProfileDemoSnapshot.manageRows,
          authRepository: FakeRuniacAuthRepository(),
        ),
      ),
    );
  }

  testWidgets('tapping About Runiac pushes AboutRuniacScreen, no snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(buildManageSection());

    expect(find.byType(AboutRuniacScreen), findsNothing);

    await tester.tap(find.text('About Runiac'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutRuniacScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('About Runiac preview is coming soon.'), findsNothing);
  });

  testWidgets('About Runiac row carries a non-snackBar action', (tester) async {
    final rows = accountProfileDemoSnapshot.manageRows;
    final aboutRow = rows.firstWhere((row) => row.title == 'About Runiac');

    expect(aboutRow.action, UserProfileManageAction.about);
    expect(aboutRow.snackBarMessage, isEmpty);
  });

  testWidgets('Settings is no longer a manage row', (tester) async {
    // It moved to the Profile header's overflow menu; a stray row here would
    // give the app two entry points to the same screen.
    expect(
      accountProfileDemoSnapshot.manageRows.where(
        (row) =>
            row.title == 'Settings' ||
            row.action == UserProfileManageAction.settings,
      ),
      isEmpty,
    );

    await tester.pumpWidget(buildManageSection());
    expect(find.text('Settings'), findsNothing);
  });
}
