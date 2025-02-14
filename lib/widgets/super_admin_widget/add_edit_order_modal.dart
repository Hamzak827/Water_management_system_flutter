import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart';

class OrderModal extends StatefulWidget {
  final Map<String, dynamic>? order; // Only needed for editing
  final String? orderId; // Only needed for editing
  final bool isEditing; // Flag to distinguish between edit and add mode

  const OrderModal({
    Key? key,
    this.order,
    this.orderId,
    required this.isEditing,
  }) : super(key: key);

  @override
  _OrderModalState createState() => _OrderModalState();
}

class _OrderModalState extends State<OrderModal> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _customerController;
  late TextEditingController _addressController;
  late TextEditingController _deliverydateController;
  late TextEditingController _collectedamountController;
  late TextEditingController _collectedbottlesController;
  late TextEditingController _deliveryboyController;
  late TextEditingController _statusController;

  List<Map<String, dynamic>> bottles = [];

  String? selectedCustomerId;
  String? selectedDeliveryBoyId;
  String? selectedAddressId;
  String? selectedStatus;

bool isPricePerLiter = true;
double? customerPricePerLiter;
double? customerPricePerBottle;

  bool isPricePerLiterNull = false; // Track if PricePerLiter is null

  String? selectedDateForAPI;
  

  String _formatDate(String isoDate) {
  // Parse the ISO 8601 date string
  DateTime parsedDate = DateTime.parse(isoDate);

  // Format the date into a desired format (e.g., 'yyyy-MM-dd')
  return DateFormat('yyyy-MM-dd').format(parsedDate);
}
  

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> deliveryBoys = [];
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true; // Add a loading state

@override
void initState() {
  super.initState();

  final address = widget.order?['Address'] ?? {};
  final addressLine = address['AddressLine'] ?? 'N/A';
  final city = address['City'] ?? 'N/A';
  final postalCode = address['PostalCode'] ?? 'N/A';
  final country = address['Country'] ?? 'N/A';
  final formattedAddress = '$addressLine, $city, $postalCode, $country';

    selectedStatus = widget.isEditing ? widget.order!['Status'] : 'Processing';

  if (widget.isEditing && widget.order != null) {
      // Parse the DeliveryDate from the order
      final deliveryDate = widget.order!['DeliveryDate'];
      final parsedDate =
          DateTime.parse(deliveryDate); // Parse the ISO 8601 date

    // Set initial values for the form fields
    _customerController = TextEditingController(text: widget.order!['CustomerID']?['Name'] ?? "");
    _addressController = TextEditingController(text: formattedAddress);
      _deliverydateController = TextEditingController(
          text: DateFormat('dd/MM/yyyy').format(parsedDate)); // Display format
    _collectedamountController = TextEditingController(text: (widget.order!['TotalCollectedAmount'] ?? 0).toString());
    _collectedbottlesController = TextEditingController(text: (widget.order!['TotalCollectedBottles'] ?? 0).toString());
    _deliveryboyController = TextEditingController(text: widget.order!['DeliveryBoyID']?['Name']);
    _statusController = TextEditingController(text: widget.order!['Status']);

      // Store the API-formatted date
      selectedDateForAPI =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(parsedDate);

    // Populate bottles list
    bottles = List<Map<String, dynamic>>.from(widget.order!['Bottles'] ?? []);

      // Check if PricePerLiter is null to adjust bottle fields
      if (widget.order!['PricePerLiter'] == null) {
        isPricePerLiterNull = true;
      }

    // Set the selected customer, address, and delivery boy
      selectedCustomerId =
          widget.order!['CustomerID']?['CustomerID'].toString();
    selectedAddressId = widget.order!['Address']?['_id'];
    selectedDeliveryBoyId = widget.order!['DeliveryBoyID']?['DeliveryBoyID'].toString();
      selectedStatus = widget.order!['Status'];
    } else {
    _customerController = TextEditingController();
    _addressController = TextEditingController();
    _deliverydateController = TextEditingController();
    _collectedamountController = TextEditingController();
    _collectedbottlesController = TextEditingController();
    _deliveryboyController = TextEditingController();
      _statusController = TextEditingController();
  }

    print('Data:${selectedCustomerId}');

  // Fetch customers and delivery boys
  _authService.fetchCustomers().then((data) {
    setState(() {
        customers = data;
      if (widget.isEditing) {
        _onCustomerChanged(selectedCustomerId); // Populate addresses based on selected customer
      }
    });
  });

  _authService.fetchDeliveryBoys().then((data) {
    setState(() {
        deliveryBoys = data;
    });
  });

  // Simulate fetching data
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false; // Data is ready, stop loading
      });
    });
}








bool _isCustomerAndAddressEditable() {
  // Always editable in add section, apply restrictions only in edit section
  if (!widget.isEditing) return true;
  return selectedStatus != 'Delivered' && 
         selectedStatus != 'Out For Delivery' && 
         selectedStatus != 'Canceled' && 
         selectedStatus != 'Processing';
}

bool _isDeliveryDateEditable() {
  // Always editable in add section, apply restriction only in edit section
  if (!widget.isEditing) return true;
  return selectedStatus != 'Delivered';
}

void _onCustomerChanged(String? customerId) {
  if (customerId == null || customerId.isEmpty) {
    setState(() {
      addresses = [];
      selectedAddressId = null;
      bottles.clear(); // Ensure the bottles list is cleared if no customer is selected
    });
    return;
  }

  final selectedCustomer = customers.firstWhere(
    (customer) => customer['CustomerID'].toString() == customerId,
    orElse: () => {},
  );

  setState(() {
    // Get customer pricing info
    customerPricePerLiter = selectedCustomer['PricePerLiter']?.toDouble();
    customerPricePerBottle = selectedCustomer['PricePerBottle']?.toDouble();
    isPricePerLiter = customerPricePerLiter != null && customerPricePerLiter! > 0;

    addresses = List<Map<String, dynamic>>.from(selectedCustomer['Addresses'] ?? []);

    // If editing an existing order, load the existing bottles data
    if (widget.order != null) {
      // Populate the bottles list from the order data if editing
      bottles = List<Map<String, dynamic>>.from(widget.order?['Bottles'] ?? []);
    } else {
      // Clear existing bottles and add default entry if new
      bottles.clear();
      if (!isPricePerLiter) {
        bottles.add({"NumberOfLiters": 19, "NumberOfBottles": ""});
      }
    }

    selectedAddressId = addresses.firstWhere(
      (address) => address['_id'] == widget.order?['Address']?['_id'],
      orElse: () => {},
    )?['_id'] ?? (addresses.isNotEmpty ? addresses[0]['_id'] : null);
  });
}



  @override
  void dispose() {
    _customerController.dispose();
    _addressController.dispose();
    _deliverydateController.dispose();
    _collectedamountController.dispose();
    _collectedbottlesController.dispose();
    _deliveryboyController.dispose();
    _statusController.dispose();
    super.dispose();
  }

void _addBottle() {
  if (!isPricePerLiter && bottles.isNotEmpty) return;

  setState(() {
    bottles.add({
      "NumberOfLiters": isPricePerLiter ? "" : 19,
      "NumberOfBottles": ""
    });
  });
}
  void _removeBottle(int index) {
    setState(() {
      bottles.removeAt(index);
    });
  }



 void _updateAddresses(String? customerId) {
    if (customerId == null) {
      setState(() {
        addresses = [];
        selectedAddressId = null;
      });
      return;
    }

    final customer = customers.firstWhere(
      (customer) => customer['CustomerID'].toString() == customerId,
      orElse: () => {},
    );

    setState(() {
      addresses = List<Map<String, dynamic>>.from(customer['Addresses'] ?? []);
      selectedAddressId = null;
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
        _deliverydateController.text =
            DateFormat('dd/MM/yyyy').format(picked); // Display format
        selectedDateForAPI = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
            .format(picked); // API format
      });
    }
  }

  // Dropdown for status
Widget _buildStatusDropdown() {
  // Define available statuses based on whether it's editing or not
  final availableStatuses = widget.isEditing
      ? ['Out For Delivery', 'Delivered', 'Canceled'] // Options for edit mode
      : ['Processing']; // Default option for non-edit mode

  // Determine the initial value for the dropdown
  String? initialValue =
      widget.isEditing && selectedStatus == 'Processing' ? null : selectedStatus;

  return widget.isEditing
      ? _buildStyledDropdown(
          label: 'Status',
          value: initialValue,
          items: availableStatuses.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedStatus = value;
            });
          },
        )
      : Container(); // Hide the status dropdown for new orders
}


   Future<void> _submitOrder() async {
    if (_formKey.currentState?.validate() ?? false) {

if (bottles.isEmpty) {
      DialogUtil.showErrorMessage(context,'Please add at least one bottle');
      return;
    }

    for (var bottle in bottles) {
      if (bottle['NumberOfLiters'].toString().isEmpty ||
          bottle['NumberOfBottles'].toString().isEmpty ) {
        DialogUtil.showErrorMessage(context,'All bottle fields are required');
        return;
      }
    }


      final orderData = {
        "CustomerID": selectedCustomerId,
        "Address": {"_id": selectedAddressId},
        "DeliveryDate": selectedDateForAPI, // Use the API-formatted date
        "TotalCollectedAmount": _collectedamountController.text,
        "TotalCollectedBottles": _collectedbottlesController.text,
        "DeliveryBoyID": selectedDeliveryBoyId,
        "Status": selectedStatus,
        "Bottles": bottles,
      };

try{
      bool success = false;
      if (widget.isEditing) {
        // Update logic
        success = await AuthService().updateOrderData(widget.orderId!, orderData);
      } else {
        // Add logic
       success = await AuthService().addNewOrder(orderData);
      }

      if (success) {
        Navigator.pop(context, true); // Close the modal
       
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Order Updated Successfully'
                : 'Order Added Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.3),
            textColor: Colors.white,
            fontSize: 16.0,
          );
      } else {
        
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Failed to update order'
                : 'Failed to add order',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.3),
            textColor: Colors.white,
            fontSize: 16.0,
          );
      }
}catch (e) {
        Fluttertoast.showToast(
          msg: e.toString().replaceAll('Exception: ', ''),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );
    }
      print("Order submitted: $orderData");
    }
  }







Widget _buildStyledTextField(
  TextEditingController controller,
  String label,
  {bool isNumeric = false, bool isDateField = false, bool enabled = true}) {
  
  return SizedBox(
    height: 60, // Consistent height with text field
    child: TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: isDateField, // Make it read-only if it's a date field
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
                icon: Icon(Icons.calendar_today), // Calendar icon
                onPressed: () async {
                  if (enabled) {
                    // Trigger the date picker when the icon is pressed
                    _selectDate(context);
                  }
                },
              )
            : null, // No icon if not a date field
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
      height: 60, // Consistent height with text field
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

          if (label == 'Status') {
          return null; // No validation for status field
        }
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }






Widget _buildBottleRow(int index) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isPricePerLiter) ...[
          Expanded(
            child: TextFormField(
              initialValue: bottles[index]['NumberOfLiters'].toString(),
              decoration: _bottleFieldDecoration("Liters"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  bottles[index]['NumberOfLiters'] = int.tryParse(value) ?? "";
                });
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: TextFormField(
            initialValue: bottles[index]['NumberOfBottles'].toString(),
            decoration: _bottleFieldDecoration("Bottles"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                bottles[index]['NumberOfBottles'] = int.tryParse(value) ?? "";
              });
            },
          ),
        ),
        if (isPricePerLiter) // Only show delete button for price-per-liter
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeBottle(index),
          ),
      ],
    ),
  );
}

InputDecoration _bottleFieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    filled: true,
    fillColor: Colors.grey[100],
  );
}








  
@override
Widget build(BuildContext context) {

if (isLoading) {
      return Center(child: CircularProgressIndicator()); // Show loading indicator while data is being fetched
    }



  return Scaffold(
    appBar: AppBar(
      title: Text(widget.isEditing ? "Edit Order" : "Add Order"),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),


        // Customer Dropdown
   

// In your dropdown widgets
_buildStyledDropdown(
  label: 'Customer',
  value: customers.any((customer) => 
          customer['CustomerID'].toString() == selectedCustomerId)
      ? selectedCustomerId
      : null,
  items: customers.map((customer) {
    return DropdownMenuItem<String>(
      value: customer['CustomerID'].toString(),
      child: Text(customer['Name'] ?? ''),
    );
  }).toList(),
  onChanged: _isCustomerAndAddressEditable()
      ? (value) {
          setState(() {
            selectedCustomerId = value;
            _onCustomerChanged(value);
          });
        }
      : null,
),

_buildStyledDropdown(
  label: 'Address',
  value: addresses.any((address) => 
          address['_id'] == selectedAddressId)
      ? selectedAddressId
      : null,
  items: addresses.map((address) {
    return DropdownMenuItem<String>(
      value: address['_id'],
      child: Text('${address['AddressLine']}, ${address['City']}'),
    );
  }).toList(),
  onChanged: _isCustomerAndAddressEditable()
      ? (value) {
          setState(() {
            selectedAddressId = value;
          });
        }
      : null,
),

// Delivery Boy Dropdown
_buildStyledDropdown(
              label: 'Delivery Boy',
              value: deliveryBoys.any((deliveryBoy) =>
                      deliveryBoy['DeliveryBoyID'].toString() ==
                      selectedDeliveryBoyId)
                  ? selectedDeliveryBoyId
                  : null,
              items: deliveryBoys.map((deliveryBoy) {
                return DropdownMenuItem<String>(
                  value: deliveryBoy['DeliveryBoyID'].toString(),
                  child: Text(deliveryBoy['Name'] ?? ''),
                );
              }).toList(),
              onChanged:  (value) {
                      setState(() {
                        selectedDeliveryBoyId = value;
                      });
                    }
                  
            ),







              // Input Fields with Enhanced Styling
              //_buildStyledTextField(_deliverydateController, 'Delivery Date',enabled: _isDeliveryDateEditable(),),
  _buildStyledTextField(
  _deliverydateController,
  'Delivery Date',
  enabled: _isDeliveryDateEditable(),
  isDateField: true, // Enable calendar icon for date picker
),

              const SizedBox(height: 5),
              _buildStyledTextField(_collectedamountController, 'Collected Amount',),
              const SizedBox(height: 3),
              _buildStyledTextField(_collectedbottlesController, 'Collected Bottles', ),
              const SizedBox(height: 3),

              _buildStatusDropdown(),
             
                const SizedBox(height: 20),
                const Text("Bottles:"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: bottles.length,
                  itemBuilder: (context, index) => _buildBottleRow(index),
                ),
                TextButton.icon(
  onPressed: isPricePerLiter ? _addBottle : null,
  icon: const Icon(Icons.add),
  label: const Text("Add Bottle"),
),
                const SizedBox(height: 20),
              // Submit Button
              Center(
                child: SizedBox(
                  width: 130.0, // Set your desired width
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: _submitOrder,
                    child: Text(widget.isEditing ? 'Save Changes' : 'Add Order'),
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
          ),
        ),
      ),
    ),
  );
}

}