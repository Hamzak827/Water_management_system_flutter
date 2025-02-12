import 'package:flutter/material.dart';
import 'package:water_management_system/admin/admin_prepaid_tokens.dart';
import 'package:water_management_system/login_screen.dart';
import 'package:water_management_system/super_admin/super_admin_home.dart';
import 'package:water_management_system/super_admin/super_admin_admins.dart';
import 'package:water_management_system/super_admin/super_admin_customer.dart';
import 'package:water_management_system/super_admin/super_admin_order.dart';
import 'package:water_management_system/super_admin/super_admin_deliveryboy.dart';
import 'package:water_management_system/admin/admin_home.dart';
import 'package:water_management_system/admin/admin_customer.dart';
import 'package:water_management_system/admin/admin_deliveryboy.dart';
import 'package:water_management_system/admin/admin_order.dart';
import 'package:water_management_system/customer/customer_home.dart';
import 'package:water_management_system/customer/customer_order.dart';
import 'package:water_management_system/deliveryboy/delivery_boy_home.dart';
import 'package:water_management_system/deliveryboy/delivery_boy_order.dart';
import 'package:water_management_system/splash_screen.dart';
import 'package:water_management_system/super_admin/super_admin_prepaid_tokens.dart';



class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());
           //return MaterialPageRoute(builder: (_) => SuperAdminOrderScreen());
          case '/login-screen':
            return MaterialPageRoute(builder: (_) => LoginScreen());

          case '/super-admin-home-screen':
            return MaterialPageRoute(builder: (_) => SuperAdminHomeScreen());
          case '/super-admin-admins-screen':
            return MaterialPageRoute(builder: (_) => SuperAdminAdminsScreen());
          case '/super-admin-customer-screen':
            return MaterialPageRoute(builder: (_) => SuperAdminCustomerScreen());
          case '/super-admin-deliveryboy-screen':
            return MaterialPageRoute(builder: (_) => SuperAdminDeliveryboyScreen());
          case '/super-admin-order-screen':
            return MaterialPageRoute(builder: (_) => SuperAdminOrderScreen());
          case '/super-admin-prepaidtoken-screen':
            return MaterialPageRoute(builder: (_) => SuperAdminPrepaidTokenScreen());
            
          case '/delivery-boy-home-screen':
            return MaterialPageRoute(builder: (_) => DeliveryBoyHomeScreen());
          case '/delivery-boy-order-screen':
            return MaterialPageRoute(builder: (_) => DeliveryboyOrderScreen());

          case '/customer-home-screen':
            return MaterialPageRoute(builder: (_) => CustomerHomeScreen());
          case '/customer-order-screen':
            return MaterialPageRoute(builder: (_) => CustomerOrderScreen());
            
          case '/admin-home-screen':
            return MaterialPageRoute(builder: (_) => AdminHomeScreen());
          case '/admin-customer-screen':
            return MaterialPageRoute(builder: (_) => AdminCustomerScreen());
          case '/admin-deliveryboy-screen':
            return MaterialPageRoute(builder: (_) => AdminDeliveryboyScreen());
          case '/admin-order-screen':
            return MaterialPageRoute(builder: (_) => AdminOrderScreen());
          case '/admin-prepaidtoken-screen':
            return MaterialPageRoute(builder: (_) => AdminPrepaidTokenScreen());
        }
      },
      initialRoute: '/',
    );
  }
}
