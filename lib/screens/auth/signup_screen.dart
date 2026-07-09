import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
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
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<UserRole>(
            segments: UserRole.values
                .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                .toList(),
            selected: {role},
            onSelectionChanged: (value) => setState(() => role = value.first),
          ),
          const SizedBox(height: 16),
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColors.danger),
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
            child: const Text('Sign Up'),
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
      padding: const EdgeInsets.only(bottom: 12),
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
