import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/providers/theme_provider.dart';
import 'package:water_management_system/navigation/app_navigator.dart';
import 'package:water_management_system/themes/app_themes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Water Management System App',
          // theme: ThemeData.light(),
          // darkTheme: ThemeData.dark(),
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeNotifier.themeMode,
          home: AppNavigator(),
        );
      },
    );
  }
}

