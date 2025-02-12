
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/super_admin_widget/add_edit_deliveryboy_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/add_edit_order_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/order_preview_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/order_widget.dart';

class SuperAdminOrderScreen extends StatelessWidget {
  const SuperAdminOrderScreen({Key? key}) : super(key: key);

  static const routeName = '/super-admin-order-screen';

   @override
  Widget build(BuildContext context) {
    return OrderScreen(role: 'super-admin',);
  }

 
}
