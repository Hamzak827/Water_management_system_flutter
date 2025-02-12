import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/providers/customer_provider.dart';
import 'package:water_management_system/providers/deliveryboy_provider.dart';

import 'package:water_management_system/splash_screen.dart'; 
import 'package:water_management_system/navigation/app_navigator.dart';

void main() {

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
       providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryBoyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Water Management System App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AppNavigator(), // Set SplashScreen as the initial screen
      ),
    );
  }
}
