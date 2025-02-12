import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:water_management_system/services/auth_service.dart';

class PrepaidTokenModal extends StatefulWidget {
  final Map<String, dynamic>? customerData;
  final String customerId;
  final bool isEditing;

  const PrepaidTokenModal({
    Key? key,
    this.customerData,
    required this.customerId,
    required this.isEditing,
  }) : super(key: key);

  @override
  _PrepaidTokenModalState createState() => _PrepaidTokenModalState();
}

class _PrepaidTokenModalState extends State<PrepaidTokenModal> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> customers = [];
  String? selectedCustomerId;
  int? editingIndex;
  bool _isLoading = true; // Track loading state
  bool _showFields = false; // Initially hide fields

  late TextEditingController _serialStartController;
  late TextEditingController _serialEndController;
  late TextEditingController _pricePerBookController;
  late TextEditingController _numberOfTokensController;

  Map<String, dynamic>? lastToken;

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditing && widget.customerData != null) {
      List<dynamic> prepaidTokens = widget.customerData!['PrepaidTokens'] ?? [];
      if (prepaidTokens.isNotEmpty) {
        lastToken = prepaidTokens.last;
        editingIndex = prepaidTokens.indexOf(lastToken);
      }
      selectedCustomerId = widget.customerId;
      _showFields = true; // Show fields if editing
    }

    _serialStartController = TextEditingController(
      text: widget.isEditing && lastToken != null
          ? lastToken!['serialNumberStarting'].toString()
          : '',
    );
    _serialEndController = TextEditingController(
      text: widget.isEditing && lastToken != null
          ? lastToken!['serialNumberEnding'].toString()
          : '',
    );
    _pricePerBookController = TextEditingController(
      text: widget.isEditing && lastToken != null
          ? lastToken!['PricePerBook'].toString()
          : '',
    );
    _numberOfTokensController = TextEditingController(
      text: widget.isEditing && lastToken != null
          ? lastToken!['numberoftokens'].toString()
          : '',
    );

    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final data = await _authService.fetchCustomers();
      setState(() {
        customers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load customers. Please try again.")),
      );
    }
  }

  int calculateNumberOfTokens() {
    int start = int.tryParse(_serialStartController.text) ?? 0;
    int end = int.tryParse(_serialEndController.text) ?? 0;
    return (end - start) + 1;
  }

  Future<void> _saveToken() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> tokenData = {
      "CustomerID": selectedCustomerId,
      "serialNumberStarting": int.parse(_serialStartController.text),
      "serialNumberEnding": int.parse(_serialEndController.text),
      "PricePerBook": double.tryParse(_pricePerBookController.text) ?? 0,
      "numberoftokens": calculateNumberOfTokens(),
    };

    bool success;
    if (widget.isEditing && editingIndex != null) {
      success = await _authService.updateToken(selectedCustomerId!, editingIndex!, tokenData);
    } else {
      success = await _authService.addNewToken(tokenData, selectedCustomerId!);
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save token. Try again.")),
      );
    }
  }

  Widget _buildStyledDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return SizedBox(
      height: 60,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          errorStyle: const TextStyle(height: 1, color: Colors.red),
        ),
        items: items,
        onChanged: (value) {
          setState(() {
            selectedCustomerId = value;
            _showFields = true; // Show fields after selecting a customer
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _serialStartController.dispose();
    _serialEndController.dispose();
    _pricePerBookController.dispose();
    _numberOfTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? "Edit Token" : "Add Token"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              _buildStyledDropdown(
                label: 'Customer',
                value: selectedCustomerId,
                items: customers.map((customer) {
                  return DropdownMenuItem<String>(
                    value: customer['CustomerID'].toString(),
                    child: Text(customer['Name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomerId = value;
                    _showFields = true; // Show fields after selecting a customer
                  });
                },
              ),
            if (_showFields) ...[
              TextFormField(
                controller: _serialStartController,
                decoration: InputDecoration(labelText: "Start Serial Number"),
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() {
                  _numberOfTokensController.text = calculateNumberOfTokens().toString();
                }),
              ),
              TextFormField(
                controller: _serialEndController,
                decoration: InputDecoration(labelText: "End Serial Number"),
                keyboardType: TextInputType.number,
                onChanged: (val) => setState(() {
                  _numberOfTokensController.text = calculateNumberOfTokens().toString();
                }),
              ),
              TextFormField(
                controller: _pricePerBookController,
                decoration: InputDecoration(labelText: "Price Per Book"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _numberOfTokensController,
                decoration: InputDecoration(labelText: "Number of Tokens"),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        if (_showFields)
          ElevatedButton(
            onPressed: _saveToken,
            child: Text(widget.isEditing ? "Update" : "Add"),
          ),
      ],
    );
  }
}
