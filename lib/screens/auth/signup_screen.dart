import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/main_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final business = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  UserRole role = UserRole.restaurant;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Join SupplyWala',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create a Firebase account or continue with Google.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          SegmentedButton<UserRole>(
            segments: UserRole.values
                .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                .toList(),
            selected: {role},
            onSelectionChanged: (value) => setState(() => role = value.first),
          ),
          const SizedBox(height: 18),
          GoogleAuthButton(
            label: 'Sign up with Google',
            isLoading: state.isLoading,
            onPressed: () async {
              final ok = await state.signInWithGoogle(role);
              if (!context.mounted || !ok) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell()),
                (_) => false,
              );
            },
          ),
          const SizedBox(height: 18),
          const _AuthDivider(),
          const SizedBox(height: 18),
          Form(
            key: formKey,
            child: Column(
              children: [
                _field(name, 'Full name', Icons.person_outline),
                _field(
                  business,
                  role == UserRole.restaurant
                      ? 'Restaurant name'
                      : 'Supplier business name',
                  Icons.store_outlined,
                ),
                _field(email, 'Email', Icons.email_outlined, emailField: true),
                _field(
                  password,
                  'Password',
                  Icons.lock_outline,
                  passwordField: true,
                ),
              ],
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await state.signup(
                      name: name.text,
                      businessName: business.text,
                      email: email.text,
                      password: password.text,
                      role: role,
                    );
                    if (!context.mounted || !ok) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (_) => false,
                    );
                  },
            child: state.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('CREATE ACCOUNT'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool emailField = false,
    bool passwordField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: passwordField,
        keyboardType: emailField
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          if (emailField && !value.contains('@')) return 'Enter valid email';
          if (passwordField && value.length < 6) return 'Minimum 6 characters';
          return null;
        },
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
