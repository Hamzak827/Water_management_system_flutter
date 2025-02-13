import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/super_admin_widget/prepaidtoken_widget.dart';

class AdminPrepaidTokenScreen extends StatelessWidget {
  const AdminPrepaidTokenScreen({super.key});
  static const routeName = '/admin-prepaidtoken-screen';

  
  @override
  Widget build(BuildContext context) {
    return PrepaidTokenScreen(role: 'admin');
  }
}
