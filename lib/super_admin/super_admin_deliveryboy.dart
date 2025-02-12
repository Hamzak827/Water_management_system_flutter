import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/super_admin_widget/add_edit_deliveryboy_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/deliveryboy_widget.dart';

class SuperAdminDeliveryboyScreen extends StatelessWidget {
  const SuperAdminDeliveryboyScreen({Key? key}) : super(key: key);

  static const routeName = '/super-admin-deliveryboy-screen';

 @override
  Widget build(BuildContext context) {
    return DeliveryboyScreen(role: 'super-admin',);
  }
}






