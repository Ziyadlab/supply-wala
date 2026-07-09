import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import '../shared/main_shell.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(text: 'restaurant@supplywala.pk');
  final password = TextEditingController(text: '123456');
  UserRole role = UserRole.restaurant;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const AppLogo(compact: true)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome back',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Login as a restaurant or supplier.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          SegmentedButton<UserRole>(
            segments: UserRole.values
                .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                .toList(),
            selected: {role},
            onSelectionChanged: (value) => setState(() => role = value.first),
          ),
          const SizedBox(height: 18),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v != null && v.length >= 6
                      ? null
                      : 'Minimum 6 characters',
                ),
              ],
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text('Forgot password?'),
            ),
          ),
          ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await state.login(
                      email.text,
                      password.text,
                      role,
                    );
                    if (!context.mounted || !ok) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (_) => false,
                    );
                  },
            child: state.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Login'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            ),
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
