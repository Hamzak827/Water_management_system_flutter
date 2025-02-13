import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart';

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

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
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

    print('Token Data: ${jsonEncode(tokenData)}'); // Debug log

    try {
    bool success;
    if (widget.isEditing && editingIndex != null) {
      success = await _authService.updateToken(selectedCustomerId!, editingIndex!, tokenData);
    } else {
      success = await _authService.addNewToken(tokenData, selectedCustomerId!);
    }

    if (success) {
      Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Token ${widget.isEditing ? 'Updated' : 'Added'} Successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(
                'Failed to ${widget.isEditing ? 'update' : 'add'} token')));
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      DialogUtil.showErrorMessage(context, errorMessage);
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


  
Widget _buildStyledTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    bool isDateField = false,
    bool enabled = true,
    void Function(String)? onChanged, // Added onChanged parameter
  }) {
    return SizedBox(
      height: 60,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        readOnly: isDateField,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
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
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter a $label' : null,
        onChanged: onChanged, // Updated to include onChanged method
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

    if (_isLoading) {
      return Center(
          child:
              CircularProgressIndicator()); // Show loading indicator while data is being fetched
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Token" : "Add Token"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Close the dialog
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
                     
                    });
                  },
                ),
              
              SizedBox(height: 20),
              _buildStyledTextField(
                _serialStartController,
                "Start Serial Number",
                isNumeric: true,
                onChanged: (val) {
                  setState(() {
                    _numberOfTokensController.text =
                        calculateNumberOfTokens().toString();
                  });
                },
              ),

SizedBox(height: 20),
              _buildStyledTextField(
                _serialEndController,
                "End Serial Number",
                isNumeric: true,
                onChanged: (val) {
                  setState(() {
                    _numberOfTokensController.text =
                        calculateNumberOfTokens().toString();
                  });
                },
              ),

SizedBox(height: 20),
              _buildStyledTextField(
                _pricePerBookController,
                "Price Per Book",
                isNumeric: true,
              ),

SizedBox(height: 20),
              _buildStyledTextField(
                _numberOfTokensController,
                "Number of Tokens",
                isNumeric: true,
                enabled: false,
              ),

              Center(
                  child: SizedBox(
                      width: 130.0, // Set your desired width
                      height: 40.0,
                      child: ElevatedButton(
                          onPressed: _saveToken,
                          child: Text(widget.isEditing ? 'Edit' : 'Add'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )))))
            ],
          ),
        ),
      ),
    
    );
  }
}
