import 'package:flutter/material.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';

class Sidebar extends StatelessWidget {
  final String role; // User role
  final Function(String) onMenuItemClicked; // Callback for menu item click
   final AuthProvider _authProvider = AuthProvider();

  Sidebar({required this.role, required this.onMenuItemClicked});

  Map<String, List<Map<String, dynamic>>> menuItems = {
    'super-admin': [
      {'title': 'Home', 'icon': Icons.home, 'route': '/super-admin-home-screen'},
      {'title': 'Customer', 'icon': Icons.people, 'route': '/super-admin-customer-screen'},
      {'title': 'Order', 'icon': Icons.shopping_cart, 'route': '/super-admin-order-screen'},
      {'title': 'DeliveryBoy', 'icon': Icons.delivery_dining, 'route': '/super-admin-deliveryboy-screen'},
      {'title': 'Admin', 'icon': Icons.admin_panel_settings_sharp, 'route': '/super-admin-admins-screen'},
      {'title': 'Prepaid Tokens', 'icon': Icons.payment, 'route': '/super-admin-prepaidtoken-screen'},
    ],
    'admin': [
      {'title': 'Home', 'icon': Icons.home, 'route': '/admin-home-screen'},
      {'title': 'Customer', 'icon': Icons.people, 'route': '/admin-customer-screen'},
      {'title': 'Order', 'icon': Icons.shopping_cart, 'route': '/admin-order-screen'},
      {'title': 'DeliveryBoy', 'icon': Icons.delivery_dining, 'route': '/admin-deliveryboy-screen'},
      {'title': 'Prepaid Tokens', 'icon': Icons.payment, 'route': '/admin-prepaidtoken-screen'},
    ],
    'customer': [
      {'title': 'Home', 'icon': Icons.home, 'route': '/customer-home-screen'},
      {'title': 'Order', 'icon': Icons.shopping_cart, 'route': '/customer-order-screen'},
    ],
    'deliveryboy': [
      {'title': 'Home', 'icon': Icons.home, 'route': '/delivery-boy-home-screen'},
      {'title': 'Order', 'icon': Icons.shopping_cart, 'route': '/delivery-boy-order-screen'},
    ],
  };





  @override
  Widget build(BuildContext context) {
    // Get the menu items for the current role
    List<Map<String, dynamic>> roleMenuItems = menuItems[role] ?? [];

    return Drawer(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        curve: Curves.decelerate,
        color: Colors.white, // Sidebar color
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Sidebar header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$role Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Sidebar menu items
            ...roleMenuItems.map((item) {
              return ListTile(
                leading: Icon(item['icon'], color: Colors.black),
                title: Text(item['title']),
                onTap: () => onMenuItemClicked(item['route']),
              );
            }).toList(),

            // Logout option (common for all roles)
            Divider(),
            ListTile(
  leading: Icon(Icons.logout, color: Colors.black),
  title: Text('Logout'),
  onTap: () async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel logout
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm logout
              },
               child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _authProvider.logout(); // Clear user session
      Navigator.pop(context); // Close the sidebar
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  },
),

          ],
        ),
      ),
    );
  }
}
