import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';

import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/super_admin_widget/customer_widget.dart';

class   AdminCustomerScreen extends StatelessWidget {
  const AdminCustomerScreen({Key? key}) : super(key: key);

  static const routeName = '/admin-customer-screen'; // Add a route name for navigation


    @override
  Widget build(BuildContext context) {
    return CustomerScreen(role: 'admin',);
  }

}
