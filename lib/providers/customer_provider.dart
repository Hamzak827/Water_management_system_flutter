import 'package:flutter/material.dart';
import 'package:water_management_system/services/auth_service.dart';

class CustomerProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  int _currentPage = 0;
  final int _itemsPerPage = 4;

  List<Map<String, dynamic>> get paginatedDeliveryboys {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return customers.sublist(
      startIndex,
      endIndex > filteredCustomers.length ? filteredCustomers.length : endIndex,
    );
  }

  int get currentPage => _currentPage;

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> fetchDeliveryBoys() async {
    try {
      customers = await _authService.fetchCustomers();
      filterDeliveryBoys();
    } catch (e) {
      // Handle error
    }
  }

  void filterDeliveryBoys({String query = ''}) {
    filteredCustomers = customers.where((customer) {
      return customer['Name']?.toLowerCase().contains(query.toLowerCase()) ?? false ||
          customer['Email']?.toLowerCase().contains(query.toLowerCase()) ?? false ||
          customer['Phone']?.toLowerCase().contains(query.toLowerCase()) ?? false ;
        
    }).toList();
    notifyListeners();
  }
}
