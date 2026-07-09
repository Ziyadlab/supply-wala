import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../restaurant/restaurant_shell.dart';
import '../supplier/supplier_shell.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final role = AppScope.of(context).currentUser?.role;
    if (role == UserRole.supplier) {
      return const SupplierShell();
    }
    return const RestaurantShell();
  }
}
