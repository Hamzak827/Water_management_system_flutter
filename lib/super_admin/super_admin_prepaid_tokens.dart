import 'package:flutter/material.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/prepaidtoken_widget/add_edit_prepaidtoken_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/add_edit_customer_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/prepaidtoken_widget.dart';

class SuperAdminPrepaidTokenScreen extends StatelessWidget {
  const SuperAdminPrepaidTokenScreen({super.key});

  static const routeName = '/super-admin-prepaidtoken-screen';

 
  @override
  Widget build(BuildContext context) {
    return PrepaidTokenScreen(
      role: 'super-admin',
    );
  }
}

