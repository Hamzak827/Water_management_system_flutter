import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/super_admin_widget/dashboard_widget.dart';


class   AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  static const routeName = '/admin-home-screen'; // Add a route name for navigation
   @override
  Widget build(BuildContext context) {
    return DashboardScreen(role: 'admin',);
  }

}
