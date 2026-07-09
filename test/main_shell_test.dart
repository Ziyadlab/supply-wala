import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supplywala1/core/app_theme.dart';
import 'package:supplywala1/models/app_models.dart';
import 'package:supplywala1/screens/shared/main_shell.dart';
import 'package:supplywala1/state/app_state.dart';

void main() {
  testWidgets('restaurant shell paints home content and switches tabs', (
    tester,
  ) async {
    final state = AppState()
      ..currentUser = AppUser(
        name: 'Ali Khan',
        email: 'restaurant@supplywala.pk',
        role: UserRole.restaurant,
        businessName: 'Spice Bistro',
        location: 'Lahore, Pakistan',
        phone: '+92 300 1234567',
        avatarUrl:
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
      );

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(theme: AppTheme.light, home: const MainShell()),
      ),
    );

    expect(find.text('Ordering for'), findsOneWidget);
    expect(find.text('AI Smart Cart'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-orders')));
    await tester.pumpAndSettle();

    expect(find.text('Spice Bistro'), findsWidgets);
  });
}
