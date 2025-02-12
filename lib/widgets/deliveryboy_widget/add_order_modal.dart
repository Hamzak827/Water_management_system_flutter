import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'package:intl/intl.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart';

class DeliveryboyOrderModal extends StatefulWidget {
  final Map<String, dynamic>? order;

  const DeliveryboyOrderModal({
    Key? key,
    this.order,
  }) : super(key: key);

  @override
  _DeliveryboyOrderModalState createState() => _DeliveryboyOrderModalState();
}

class _DeliveryboyOrderModalState extends State<DeliveryboyOrderModal> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Secure storage instance

  late TextEditingController _deliveryDateController;
  late TextEditingController _bottlesController;

  String? selectedCustomerId;
  String? selectedAddressId;
  String? selectedDeliveryBoyId;

  String? selectedDeliveryDateISO;


  String? selectedStatus;

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _deliveryDateController = TextEditingController();
    _bottlesController = TextEditingController();

     selectedStatus = 'Out For Delivery';

    // Fetch customers
    _authService.fetchCustomers().then((data) {
      setState(() {
        customers = data;
      });
    });

    // Fetch delivery boy ID from secure storage
    _fetchDeliveryBoyId();

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
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

  // Fetch delivery boy ID from secure storage
  Future<void> _fetchDeliveryBoyId() async {
    final deliveryBoyId = await _storage.read(key: 'deliveryboyId');
    setState(() {
      selectedDeliveryBoyId = deliveryBoyId; // Set the delivery boy ID
    });
  }

  @override
  void dispose() {
    _deliveryDateController.dispose();
    _bottlesController.dispose();
    super.dispose();
  }

  void _onCustomerChanged(String? customerId) {
    if (customerId == null || customerId.isEmpty) {
      setState(() {
        addresses = [];
        selectedAddressId = null;
      });
      return;
    }

    final selectedCustomer = customers.firstWhere(
      (customer) => customer['CustomerID'].toString() == customerId,
      orElse: () => {},
    );

    setState(() {
      addresses = List<Map<String, dynamic>>.from(selectedCustomer['Addresses'] ?? []);
      selectedAddressId = addresses.isNotEmpty ? addresses[0]['_id'] : null;
    });
  }

  // Date Picker
Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
  if (picked != null) {
    setState(() {
      _deliveryDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      // Store the ISO format in a separate variable (for saving)
      selectedDeliveryDateISO = picked.toIso8601String();
    });
  }
}


  Future<void> _submitOrder() async {
    if (_formKey.currentState?.validate() ?? false) {
      final orderData = {
        "CustomerID": selectedCustomerId,
        "DeliveryBoyID": selectedDeliveryBoyId, // Use the fetched delivery boy ID
        "DeliveryDate": selectedDeliveryDateISO,
        "Address": {"_id": selectedAddressId},
        "Bottles": [
          {
            "NumberOfBottles": int.parse(_bottlesController.text),
            "NumberOfLiters": 19, // Default value for liters
          }
        ],
         "Status": selectedStatus,
      };
      print('Order Data: $orderData'); // Debug log

      try {
        bool success = await AuthService().addNewOrder(orderData);

        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order Added Successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add order')));
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
      title: Text("Add Order"),
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
                  label: 'Customer',
                  value: selectedCustomerId,








                  items: customers
                      .map((customer) => DropdownMenuItem<String>(
                            value: customer['CustomerID'].toString(),
                            child: Text(customer['Name']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCustomerId = value;
                    });
                    _onCustomerChanged(value);
                  },
                ),
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
                    child: Text('Add Order'),
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