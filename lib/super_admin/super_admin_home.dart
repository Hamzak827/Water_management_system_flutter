import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/super_admin_widget/dashboard_widget.dart';


class SuperAdminHomeScreen extends StatelessWidget {


  static const routeName = '/super-admin-home-screen';
  @override
  Widget build(BuildContext context) {
    return DashboardScreen(role: 'super-admin',);
  }
}
