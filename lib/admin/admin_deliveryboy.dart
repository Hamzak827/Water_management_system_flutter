import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/super_admin_widget/deliveryboy_widget.dart';


class   AdminDeliveryboyScreen extends StatelessWidget {
  const AdminDeliveryboyScreen({Key? key}) : super(key: key);

  static const routeName = '/admin-deliveryboy-screen'; // Add a route name for navigation

    @override
  Widget build(BuildContext context) {
    return DeliveryboyScreen(role: 'admin',);
  }
}
