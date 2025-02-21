import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/providers/theme_provider.dart';

class Sidebar extends StatelessWidget {
  final String role;
  final Function(String) onMenuItemClicked;
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
    List<Map<String, dynamic>> roleMenuItems = menuItems[role] ?? [];
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return SizedBox(
      width: 270, // Adjust this value for the desired width
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Container(
          color: Theme.of(context).colorScheme.surface, // Use theme-based color
          child: Column(
            children: [
              SizedBox(height: 70),
              Row(
                children: [
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child:
                        Icon(Icons.water_drop, size: 30, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Water Management System',
                    style: GoogleFonts.lato(
                      fontSize: 17,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface, // Use theme-based color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color:
                      Theme.of(context).dividerColor, // Use theme-based color
                  thickness: 1,
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...roleMenuItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: ListTile(
                          leading: Icon(
                            item['icon'],
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface, // Use theme-based color
                            size: 22,
                          ),
                          title: Text(
                            item['title'],
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface, // Use theme-based color
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          minLeadingWidth: 0,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () => onMenuItemClicked(item['route']),
                        ),
                      );
                    }).toList(),

                    // Dark/Light Mode Toggle

                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ListTile(
                        leading: Icon(
                          themeNotifier.themeMode == ThemeMode.dark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface, // Use theme-based color
                          size: 22,
                        ),
                        title: Text(
                          themeNotifier.themeMode == ThemeMode.dark
                              ? 'Dark Mode'
                              : 'Light Mode',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface, // Use theme-based color
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: Switch(
                          value: themeNotifier.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeNotifier.toggleTheme();
                          },
                          activeColor: Colors.blue, // Customize switch color
                        ),
                        minLeadingWidth: 0,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  color:
                      Theme.of(context).dividerColor, // Use theme-based color
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () async {
                    bool confirmLogout = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Logout"),
                          content: Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                "Logout",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmLogout == true) {
                      await _authProvider.logout();
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login-screen');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
