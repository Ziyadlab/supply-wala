import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'state/app_state.dart';

class SupplyWalaApp extends StatefulWidget {
  const SupplyWalaApp({super.key});

  @override
  State<SupplyWalaApp> createState() => _SupplyWalaAppState();
}

class _SupplyWalaAppState extends State<SupplyWalaApp> {
  late final AppState appState;

  @override
  void initState() {
    super.initState();
    appState = AppState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Supply Wala',
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
