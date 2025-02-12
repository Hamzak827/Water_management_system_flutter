import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';

import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/super_admin_widget/order_widget.dart';


class   AdminOrderScreen extends StatelessWidget {
  const AdminOrderScreen({Key? key}) : super(key: key);

  static const routeName = '/admin-order-screen'; // Add a route name for navigation


   @override
  Widget build(BuildContext context) {
    return OrderScreen(role: 'admin');
  }
}
