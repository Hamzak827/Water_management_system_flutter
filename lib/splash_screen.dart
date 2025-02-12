import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/login_screen.dart';
import 'package:water_management_system/super_admin/super_admin_home.dart';
import 'package:water_management_system/admin/admin_home.dart';
import 'package:water_management_system/customer/customer_home.dart';
import 'package:water_management_system/deliveryboy/delivery_boy_home.dart';
import 'package:water_management_system/providers/auth_provider.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate a delay (e.g., 2 seconds for the splash screen)
    await Future.delayed(const Duration(seconds: 5));

    // Load user data
    await Provider.of<AuthProvider>(context, listen: false).loadUserData();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      // Navigate to the role-specific screen
      if (authProvider.role == 'super-admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAdminHomeScreen()),
        );
      } else if (authProvider.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
      } else if (authProvider.role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
        );
      } else if (authProvider.role == 'deliveryboy') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DeliveryBoyHomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/1024.png", 
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 20),
             LoadingAnimationWidget.threeRotatingDots(
              color: Colors.black, // Customize the color
              size: 30, // Customize the size
            ),
            const SizedBox(height: 10),
            Text(
              "WMS",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
