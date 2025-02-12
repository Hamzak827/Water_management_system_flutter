import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'package:intl/intl.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart';

class CustomerOrderModal extends StatefulWidget {
  final Map<String, dynamic>? order;
  final String customerId; // Pass customerId directly
  final String? orderId; // Only needed for editing
  final bool isEditing; 

  const CustomerOrderModal({
    Key? key,
    this.order,
    required this.customerId,
    this.orderId,
    required this.isEditing // Add customerId as a required parameter
  }) : super(key: key);

  @override
  _CustomerOrderModalState createState() => _CustomerOrderModalState();
}

class _CustomerOrderModalState extends State<CustomerOrderModal> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Secure storage instance

  late TextEditingController _deliveryDateController;
  late TextEditingController _bottlesController;
  late TextEditingController _addressController;

  String? selectedAddressId;
  String? selectedStatus;

  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;
  String? selectedDateForAPI; // Store Date in DateTime format

  @override
  void initState() {
    super.initState();

final address = widget.order?['Address'] ?? {};
  final addressLine = address['AddressLine'] ?? 'N/A';
  final city = address['City'] ?? 'N/A';
  final postalCode = address['PostalCode'] ?? 'N/A';
  final country = address['Country'] ?? 'N/A';
  final formattedAddress = '$addressLine, $city, $postalCode, $country';

    
  if (widget.isEditing && widget.order != null) {
    _addressController =TextEditingController(text: formattedAddress);
    _deliveryDateController = TextEditingController(text: _formatDate(widget.order!['DeliveryDate'])); // Format existing date
    //_deliveryDateController = TextEditingController.(text: widget.order!['DeliveryDate'] ?? "");
    _bottlesController = TextEditingController(text: (widget.order!['Bottles'] != null && widget.order!['Bottles'].isNotEmpty) 
    ? widget.order!['Bottles'][0]['NumberOfBottles'].toString() 
    : '0',);

   
        // Ensure correct address is selected in edit mode
    selectedAddressId = widget.order!['Address']?['_id'];
 
  }
  else{

    _deliveryDateController = TextEditingController();
    _bottlesController = TextEditingController();

   
  }
   selectedStatus = 'Processing';

   

    // Fetch delivery address using the customerId passed in
    _fetchCustomerAddresses(widget.customerId);

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }







Future<void> _fetchCustomerAddresses(String customerId) async {
  final response = await _authService.fetchCustomerAddresses(customerId);
  setState(() {
    addresses = response;

    // Ensure selectedAddressId updates properly
    if (widget.isEditing && widget.order != null) {
      selectedAddressId = widget.order!['Address']?['_id'];
    } else if (addresses.isNotEmpty && selectedAddressId == null) {
      selectedAddressId = addresses[0]['_id']; 
    }
  });
}







  @override
  void dispose() {
    _deliveryDateController.dispose();
    _bottlesController.dispose();
    super.dispose();
  }



// Function to format the date before displaying it
String _formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return "";
  try {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return dateString; // Return the original value if parsing fails
  }
}
  // Import the intl package for date formatting


Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (picked != null) {
    setState(() {
      _deliveryDateController.text = DateFormat('dd/MM/yyyy').format(picked); // For display
      selectedDateForAPI = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(picked); // For API
    });
  }
}


  


  
Future<void> _submitOrder() async { 
  if (_formKey.currentState?.validate() ?? false) {
    final bottlesData = [
      {
        // Pass _id only if editing, else do not include it at all
        if (widget.isEditing && widget.order != null && widget.order!['Bottles'].isNotEmpty)
          "_id": widget.order!['Bottles'][0]['_id'], 

        "NumberOfBottles": int.parse(_bottlesController.text),
        "NumberOfLiters": widget.isEditing && widget.order != null && widget.order!['Bottles'][0]['NumberOfLiters'] != null
            ? widget.order!['Bottles'][0]['NumberOfLiters'] // If editing and value exists, use it
            : 19, // Default value if empty or null
      }
    ];

    final orderData = {
      "CustomerID": widget.customerId,
      "DeliveryDate": selectedDateForAPI,
      "Address": {"_id": selectedAddressId}, // Ensure the latest selectedAddressId is used
      "Bottles": bottlesData,
      "Status": selectedStatus,
    };

    print('Order Data: ${jsonEncode(orderData)}'); // Debug log

    try {
      bool success = false;
      if (widget.isEditing) {
        // Update logic
        success = await AuthService().updateOrderData(widget.orderId!, orderData);
      } else {
        // Add logic
        success = await AuthService().addNewOrder(orderData);
      }

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order ${widget.isEditing ? 'Updated' : 'Added'} Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${widget.isEditing ? 'update' : 'add'} order')));
      }
    } catch (e) {
      DialogUtil.showErrorMessage(context, e.toString());
    }
  }
}



  Widget _buildStyledTextField(
    TextEditingController controller,
    String label,
    {bool isNumeric = false, bool isDateField = false, bool enabled = true}) {
    return SizedBox(
      height: 60,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        readOnly: isDateField,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          errorStyle: const TextStyle(height: 1, color: Colors.red),
          suffixIcon: isDateField
              ? IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    if (enabled) {
                      _selectDate(context);
                    }
                  },
                )
              : null,
        ),
        validator: (value) => value?.isEmpty ?? true ? 'Please enter a $label' : null,
      ),
    );
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
        onChanged: onChanged,
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // Show loading indicator while data is being fetched
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Order":"Add Order"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Close the dialog
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (isLoading)
                  CircularProgressIndicator()
                else ...[
                  _buildStyledDropdown(
                    label: 'Address',
                    value: selectedAddressId,
                    items: addresses
                        .map((address) => DropdownMenuItem<String>(
                              value: address['_id'],
                              child: Text('${address['AddressLine']}, ${address['City']}'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAddressId = value;
                        
                      });
                    },
                  ),
                  _buildStyledTextField(_deliveryDateController, 'Delivery Date', isDateField: true),
                  _buildStyledTextField(_bottlesController, 'Number of Bottles', isNumeric: true),
                  Center(
                    child: SizedBox(
                      width: 130.0, // Set your desired width
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: _submitOrder,
                        child: Text(widget.isEditing ?'Edit Order':'Add Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
