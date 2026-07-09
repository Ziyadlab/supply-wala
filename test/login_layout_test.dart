import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supplywala1/core/app_theme.dart';
import 'package:supplywala1/screens/auth/login_screen.dart';
import 'package:supplywala1/state/app_state.dart';

void main() {
  testWidgets('login role cards fit a compact viewport', (tester) async {
    tester.view.physicalSize = const Size(624, 592);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      AppScope(
        state: AppState(),
        child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
      ),
    );

    expect(find.text('Restaurant Buyer'), findsOneWidget);
    expect(find.text('Wholesale Supplier'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
