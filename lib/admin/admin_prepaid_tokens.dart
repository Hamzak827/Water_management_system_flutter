import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';

class AdminPrepaidTokenScreen extends StatefulWidget {
  const AdminPrepaidTokenScreen({super.key});
  static const routeName = '/admin-prepaidtoken-screen';

  @override
  State<AdminPrepaidTokenScreen> createState() => _AdminPrepaidTokenScreenState();
}

class _AdminPrepaidTokenScreenState extends State<AdminPrepaidTokenScreen> {
    @override
  Widget build(BuildContext context) {

    // Fetch role from the AuthProvider
    final role = Provider.of<AuthProvider>(context).role;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Prepaid Tokens"),
        centerTitle: true,
      ),
      drawer: Sidebar(role: role,  onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },),
    );
  }
}