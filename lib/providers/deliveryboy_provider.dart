import 'package:flutter/material.dart';
import 'package:water_management_system/services/auth_service.dart';

class DeliveryBoyProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> deliveryboys = [];
  List<Map<String, dynamic>> filteredDeliveryboys = [];
  int _currentPage = 0;
  final int _itemsPerPage = 4;

  List<Map<String, dynamic>> get paginatedDeliveryboys {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return filteredDeliveryboys.sublist(
      startIndex,
      endIndex > filteredDeliveryboys.length ? filteredDeliveryboys.length : endIndex,
    );
  }

  int get currentPage => _currentPage;

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> fetchDeliveryBoys() async {
    try {
      deliveryboys = await _authService.fetchDeliveryBoys();
      filterDeliveryBoys();
    } catch (e) {
      // Handle error
    }
  }

  void filterDeliveryBoys({String query = ''}) {
    filteredDeliveryboys = deliveryboys.where((deliveryboy) {
      return deliveryboy['Name']?.toLowerCase().contains(query.toLowerCase()) ?? false ||
          deliveryboy['Phone']?.toLowerCase().contains(query.toLowerCase()) ?? false ||
          deliveryboy['AssignedArea']?.toLowerCase().contains(query.toLowerCase()) ?? false ||
          deliveryboy['CNIC']?.toLowerCase().contains(query.toLowerCase()) ?? false ||
          deliveryboy['Email']?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();
    notifyListeners();
  }
}
