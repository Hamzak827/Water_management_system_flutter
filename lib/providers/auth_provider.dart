import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For json decoding
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  String _role = '';
  String _token = '';
  bool _isLoggedIn = false;
  String _deliveryboyId = '';
  String _customerId = '';

  String get role => _role;
  String get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  String get deliveryboyId => _deliveryboyId;
  String get customerId => _customerId;

  Future<void> login(String token, String role, {String? deliveryboyId, String? customerId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', role);
    await prefs.setString('token', token);
    
    if (role == 'deliveryboy') {
      await prefs.setString('DeliveryBoyID', deliveryboyId ?? '');
    } else if (role == 'customer') {
      await prefs.setString('CustomerID', customerId ?? '');
    }

    _token = token;
    _role = role;
    _isLoggedIn = true;
    _deliveryboyId = deliveryboyId ?? '';
    _customerId = customerId ?? '';

    notifyListeners();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _role = prefs.getString('role') ?? '';
    _token = prefs.getString('token') ?? '';
    
    if (_role == 'deliveryboy') {
      _deliveryboyId = prefs.getString('DeliveryBoyID') ?? '';
    } else if (_role == 'customer') {
      _customerId = prefs.getString('CustomerID') ?? '';
    }

    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('role');
    await prefs.remove('token');
    await prefs.remove('DeliveryBoyID');
    await prefs.remove('CustomerID');

    _isLoggedIn = false;
    _role = '';
    _token = '';
    _deliveryboyId = '';
    _customerId = '';

    notifyListeners();
  }
}
