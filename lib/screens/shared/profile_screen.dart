import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.currentUser;
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Profile')) : null,
      body: user == null
          ? const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Not logged in',
              message: 'Please login to view profile.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        NetworkThumb(url: user.avatarUrl, size: 92, radius: 28),
                        const SizedBox(height: 12),
                        Text(
                          user.businessName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${user.role.label} • ${user.location}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(user.email),
                        Text(user.phone),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await state.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ],
            ),
    );
  }
}
