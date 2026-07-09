import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogo(),
              const Spacer(),
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.softOrange,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 120,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Restaurant supplies, ordered faster.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Browse verified suppliers, manage inventory, place B2B orders, and chat in one clean marketplace app.',
                style: TextStyle(color: AppColors.muted, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  state.completeOnboarding();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
