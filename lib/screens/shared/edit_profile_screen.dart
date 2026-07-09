import 'package:flutter/material.dart';

import '../../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController? name;
  TextEditingController? business;
  TextEditingController? location;
  TextEditingController? phone;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final user = AppScope.of(context).currentUser!;
    name = TextEditingController(text: user.name);
    business = TextEditingController(text: user.businessName);
    location = TextEditingController(text: user.location);
    phone = TextEditingController(text: user.phone);
    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(name!, 'Name'),
            _field(business!, 'Business name'),
            _field(location!, 'Location'),
            _field(phone!, 'Phone'),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                state.updateProfile(
                  name: name!.text,
                  businessName: business!.text,
                  location: location!.text,
                  phone: phone!.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
