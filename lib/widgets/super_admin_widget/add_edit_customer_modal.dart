import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart'; // Make sure the API service is correctly imported

class CustomerModal extends StatefulWidget {
  final Map<String, dynamic>? customer; // Only needed for editing
  final String? customerId; // Only needed for editing
  final bool isEditing; // Flag to distinguish between edit and add mode

  const CustomerModal({
    Key? key,
    this.customer,
    this.customerId,
    required this.isEditing,
  }) : super(key: key);

  @override
  _CustomerModalState createState() => _CustomerModalState();
}

class _CustomerModalState extends State<CustomerModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _priceController;
  late TextEditingController _securityamountController;
  late TextEditingController _securitybottleController;
  String _priceType = 'PricePerLiter';
  

  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.customer != null) {
      _nameController = TextEditingController(text: widget.customer!['Name']);
      _emailController = TextEditingController(text: widget.customer!['Email']);
      _passwordController=TextEditingController(text: widget.customer!['Password']);
      _phoneController = TextEditingController(text: widget.customer!['Phone']);
     
      _securityamountController = TextEditingController(text: (widget.customer!['SecurityAmount'] ?? 0).toString());
      _securitybottleController = TextEditingController(text: (widget.customer!['SecurityNumberofBottle'] ?? 0).toString());

      // Determine the Price Type based on which value is not null
    if (widget.customer!['PricePerLiter'] != null && widget.customer!['PricePerLiter'] != 0) {
      _priceType = 'PricePerLiter'; // Set dropdown to PricePerLiter if it's not null
      _priceController = TextEditingController(
          text: widget.customer!['PricePerLiter'].toString());
    } else if (widget.customer!['PricePerBottle'] != null && widget.customer!['PricePerBottle'] != 0) {
      _priceType = 'PricePerBottle'; // Set dropdown to PricePerBottle if it's not null
      _priceController = TextEditingController(
          text: widget.customer!['PricePerBottle'].toString());
    }
      
      
      addresses = List<Map<String, dynamic>>.from(widget.customer!['Addresses'] ?? []);
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _priceController = TextEditingController();
      _passwordController=TextEditingController();
      _securityamountController=TextEditingController();
      _securitybottleController=TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _passwordController.dispose();
    _securityamountController.dispose();
    _securitybottleController.dispose();
;    super.dispose();
  }

  void _addAddress() {
    setState(() {
      addresses.add({"AddressLine": "", "City": "", "PostalCode": "", "Country": ""});
    });
  }

void _removeAddress(int index) async {
    if (index < 0 || index >= addresses.length) {
      // Handle invalid index
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid address index')),
      );
      return;
    }

  var address = addresses[index];
  String? addressId = address['_id']; // Ensure this field is correct in your address object

  if (addressId == null) {
      // If the address doesn't have an ID, just remove it from the local list
      setState(() {
      addresses.removeAt(index);
      });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address removed successfully')),
    );
    return;
  }

  try {
    // Call the API to delete the specific address
    bool success = await AuthService().deleteCustomerAddress(widget.customerId!, addressId);

    if (success) {
      // If deletion is successful, remove it from the local list
      setState(() {
        addresses.removeAt(index);
      });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address deleted successfully')),
        );
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete address')),
        );
    }
  } catch (e) {
    print('Error deleting address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting address: ${e.toString()}')),
      );
  }
}


void _submitCustomer() async { 
  if (_formKey.currentState?.validate() ?? false) {
    if (addresses.isEmpty) {
      DialogUtil.showErrorMessage(context, 'Please add at least one address');
      return;
    }

    // Remove empty or invalid addresses
    addresses = addresses.where((address) {
      return address['AddressLine'].isNotEmpty &&
          address['City'].isNotEmpty &&
          address['PostalCode'].isNotEmpty &&
          address['Country'].isNotEmpty;
    }).toList();

    if (addresses.isEmpty) {
      DialogUtil.showErrorMessage(context, 'Please add valid address fields');
      return;
    }

    // Check for duplicate addresses
    Set<String> addressSet = Set<String>();
    for (var address in addresses) {
      String addressHash = '${address['AddressLine']}-${address['City']}-${address['PostalCode']}-${address['Country']}';
      if (addressSet.contains(addressHash)) {
        DialogUtil.showErrorMessage(context, 'Duplicate address detected.');
        return;
      }
      addressSet.add(addressHash);
    }

    // Prepare the customer data based on selected price type
    Map<String, dynamic> customerData = {
      "Name": _nameController.text,
      "Email": _emailController.text,
      "Password": _passwordController.text,
      "Phone": _phoneController.text,
      "SecurityAmount": int.tryParse(_securityamountController.text) ?? 0,
      "SecurityNumberofBottle": int.tryParse(_securitybottleController.text) ?? 0,
      "PricePerLiter": _priceType == 'PricePerLiter' ? double.tryParse(_priceController.text) ?? 0.0 : null,
      "PricePerBottle": _priceType == 'PricePerBottle' ? double.tryParse(_priceController.text) ?? 0.0 : 0.0,
      "Addresses": addresses,
      "PrepaidTokens": []
    };

      print('Order Data: ${jsonEncode(customerData)}'); // Debug log
try {
        bool success = false;

        if (widget.isEditing) {
          // Edit customer and update address
          success =
              await _editCustomerAndAddress(widget.customerId!, customerData);
        } else {
          // Add new customer and address
          success = await _addCustomerAndAddress(customerData);
          print('Add Success:$success');
        }

        // Show success message
        if (success) {
          Navigator.pop(context, true);
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Customer Updated Successfully'
                : 'Customer Added Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.3),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Failed to update customer'
                : 'Failed to add customer',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.3),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        // Display the specific exception message
        Fluttertoast.showToast(
          msg: e.toString().replaceAll('Exception: ', ''),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
  }
}


// Function to handle adding new customer and addresses
  Future<bool> _addCustomerAndAddress(Map<String, dynamic> customerData) async {
    try {
      // Add customer and capture the response which includes the customer ID
      bool customerAdded = await AuthService().addNewCustomer(customerData);
      print('Customer added response: $customerAdded');
    
      if (!customerAdded) return false;

      return true;
    } catch (e) {
      print('Error during customer and address adding: $e');
      // Show the specific error message to the user
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

// Function to handle editing customer and addresses
Future<bool> _editCustomerAndAddress(String customerId, Map<String, dynamic> customerData) async {
  try {
    // Update customer data first
    bool customerUpdated = await AuthService().updateCustomerData(customerId, customerData);
    if (!customerUpdated) return false;

    // Then update the addresses
    for (var address in addresses) {
      if (address['_id'] != null) {
        // Update existing address
        await _updateCustomerAddress(customerId, address['_id'], address);
      } else {
        // Add new address if it doesn't have an _id
        await _addCustomerAddress(customerId, address);
      }
    }

    return true;
  } catch (e) {
    print('Error during customer and address update: $e');
      // Show the specific error message to the user
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    return false;
  }
}




Future<void> _addCustomerAddress(String customerId, Map<String, dynamic> address) async {
  try {
    print('Adding address for customerId: $customerId');
    final response = await AuthService().addCustomerAddress(customerId, address);
    if (response) {
      print('Address Added Successfully');
     
        Fluttertoast.showToast(
          msg: 'Address Added Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );

    } else {
      print('Failed to add address');
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add address')));
    }
  } catch (e) {
    print('Error adding address: $e');
    final errorMessage = e.toString().replaceAll('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}




// Function to update address
Future<void> _updateCustomerAddress(String customerId, String addressId, Map<String, dynamic> updatedAddress) async {
  try {
    final response = await AuthService().updateCustomerAddress(customerId, addressId, updatedAddress);
    if (response) {
 
        Fluttertoast.showToast(
          msg: 'Address Updated Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      
    } else {
   
        Fluttertoast.showToast(
          msg: 'Failed to update address',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );

    }
  } catch (e) {
    print('Error updating address: $e');
   
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        textColor: Colors.white,
        fontSize: 16.0,
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
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    ),
  );
}




Widget _buildAddressRow(int index) {
    final address = addresses[index];

  return Padding(
      key: ValueKey(
          address['_id'] ?? index), // Use a unique key for each address
    padding: const EdgeInsets.symmetric(vertical: 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // AddressLine in one row (first line)
          SizedBox(
            height: null, // Let it expand based on content size
            child: TextFormField(
              initialValue: address['AddressLine'].toString(),
              decoration: InputDecoration(
                labelText: "Address Line",
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: null, // Allows multiple lines
              minLines: 1, // Sets the minimum number of lines
              onChanged: (value) {
                setState(() {
                  addresses[index]['AddressLine'] = value;
                });
              },
            ),
          ),

        const SizedBox(height: 10), // Space between AddressLine and next row

        // City and PostalCode in one row (second line)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // City Field
              Expanded(
                child: SizedBox(
                  height: null,
                  child: TextFormField(
                    initialValue: address['City'].toString(),
                    decoration: InputDecoration(
                      labelText: "City",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        addresses[index]['City'] = value;
                      });
                    },
                  ),
                ),
            ),
            const SizedBox(width: 10), // Space between City and PostalCode
            // PostalCode Field
              Expanded(
                child: SizedBox(
                  height: null,
                  child: TextFormField(
                    initialValue: address['PostalCode'].toString(),
                    decoration: InputDecoration(
                      labelText: "Postal Code",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        addresses[index]['PostalCode'] = value;
                      });
                    },
                  ),
                ),
            ),
          ],
        ),

        const SizedBox(height: 10), // Space between City/PostalCode and Country

        // Country in one row (third line)
          SizedBox(
            height: null,
            child: TextFormField(
              initialValue: address['Country'].toString(),
              decoration: InputDecoration(
                labelText: "Country",
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  addresses[index]['Country'] = value;
                });
              },
            ),
          ),

        const SizedBox(height: 5), // Space between Country and Delete Button

        // Delete Button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _removeAddress(index), // Ensure the correct index is passed
          ),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return WillPopScope(
      onWillPop: () async {
        // Perform any additional actions if needed before popping
        Navigator.pop(context, true);
        return Future.value(false); // Prevents default back button behavior
      },child: Scaffold(
    appBar: AppBar(
      title: Text(widget.isEditing ? "Edit Customer" : "Add Customer"),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context, true), 
        // Close the dialog
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

              // Input Fields with Enhanced Styling
              _buildStyledTextField(_nameController, 'Name'),
              const SizedBox(height: 5),
              _buildStyledTextField(_emailController, 'Email', isEmail: true),
              const SizedBox(height: 3),
              _buildStyledTextField(_passwordController, 'Password', isPassword: true),
              const SizedBox(height: 3),
              _buildStyledTextField(_phoneController, 'Phone', isPhone: true),
              const SizedBox(height: 3),

// Add a dropdown in your widget tree
_buildStyledDropdown(label: 'Price Type',
                     value:  _priceType,
                     items: <String>['PricePerLiter', 'PricePerBottle']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(), onChanged: (String? newValue) {
      setState(() {
        _priceType = newValue!;
        // You can add logic here to set PricePerLiter or PricePerBottle
        if (_priceType == 'PricePerLiter') {
          // Set data for PricePerLiter
          _priceController.text = ''; // Reset the controller or handle accordingly
        } else if (_priceType == 'PricePerBottle') {
          // Set data for PricePerBottle
          _priceController.text = ''; // Reset the controller or handle accordingly
        }
      });
    },),
             
// Based on the selected price type, display the price input
              buildPriceField(),

              const SizedBox(height: 3),
              _buildStyledTextField(_securityamountController, 'Security Amount',isNumeric: true),
               const SizedBox(height: 3),
              _buildStyledTextField(_securitybottleController, 'Secuity Bottles',isNumeric:true),

              const SizedBox(height: 15),

              // Section for Addresses
              Text(
                "Addresses:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                itemBuilder: (context, index) => _buildAddressRow(index),
              ),
              TextButton.icon(
                onPressed: _addAddress,
                icon: const Icon(Icons.add, color: Colors.blue),
                label: const Text("Add Address"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 5),

              // Submit Button
              Center(
                child: SizedBox(
                  width: 130.0, // Set your desired width
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: _submitCustomer,
                    child: Text(widget.isEditing ? 'Save Changes' : 'Add Customer'),
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
  ));
}



Widget buildPriceField() {
  String label = _priceType == 'PricePerLiter' ? 'Price per Liter' : 'Price per Bottle';
  
  return _buildStyledTextField(
    _priceController, 
    label, 
    isNumeric: true, // Since price is a number, we pass isNumeric as true
  );
}

Widget _buildStyledTextField(TextEditingController controller, String label,
    {bool isEmail = false, bool isNumeric = false, bool isPassword = false, bool isPhone = false}) {
  return SizedBox(
    height: 60, // Increased height to accommodate error text without affecting layout
    child: TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isNumeric
              ? TextInputType.number
              : isPhone
                  ? TextInputType.phone
                  : TextInputType.text,
      obscureText: isPassword,
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
        // Reserve space for error messages
        
        errorStyle: const TextStyle(height: 1, color: Colors.red), // Consistent height
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter a $label';
        }

        if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value!)) {
          return 'Please enter a valid email';
        }

        if (label == 'Password' && value!.length < 8) {
          return 'Password must be at least 8 characters';
        }

        if (isPhone && !RegExp(r"^03\d{9}$").hasMatch(value!)) {
          return 'Please enter 11 digits';
        }

        return null;
      },
    ),

    
  );
}

}