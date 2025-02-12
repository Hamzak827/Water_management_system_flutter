import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';

class DeliveryBoyHomeScreen extends StatelessWidget {

   
  const DeliveryBoyHomeScreen({Key? key}) : super(key: key);

  static const routeName = '/delivery-boy-home-screen'; // Add a route name for navigation

 

  @override
  Widget build(BuildContext context) {
    // Fetch role from the AuthProvider
    final role = Provider.of<AuthProvider>(context).role;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Boy Dashboard"),
        centerTitle: true,
      ),
       drawer: Sidebar(
        role: role, // Pass the role to the Sidebar
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
     
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings, // Use an admin icon
              size: 100,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Delivery Boy Dashboard",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24, // Adjust font size
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Adjust text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
