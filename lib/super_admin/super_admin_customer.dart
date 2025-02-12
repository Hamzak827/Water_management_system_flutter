import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';

import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/super_admin_widget/add_edit_customer_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/customer_widget.dart';

class SuperAdminCustomerScreen extends StatelessWidget {
  const SuperAdminCustomerScreen({Key? key}) : super(key: key);

  static const routeName = '/super-admin-customer-screen'; // Add a route name for navigation

    @override
  Widget build(BuildContext context) {
    return CustomerScreen(role: 'super-admin',);
  }

 
}
