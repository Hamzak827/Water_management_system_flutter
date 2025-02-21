import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart';

class DeliveredStatusModal extends StatefulWidget {
  final Map<String, dynamic> order;

  const DeliveredStatusModal({Key? key, required this.order}) : super(key: key);

  @override
  _DeliveredStatusModalState createState() => _DeliveredStatusModalState();
}

class _DeliveredStatusModalState extends State<DeliveredStatusModal> {
  final _formKey = GlobalKey<FormState>();
  
    final AuthService _authService = AuthService();

  late TextEditingController _bottlesReturnedController;
  late TextEditingController _collectedAmountController;
  List<TextEditingController> _serialNumberControllers = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bottlesReturnedController = TextEditingController();
    _collectedAmountController = TextEditingController();
    _serialNumberControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _bottlesReturnedController.dispose();
    _collectedAmountController.dispose();
    for (var controller in _serialNumberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSerialNumberField() {
    setState(() {
      _serialNumberControllers.add(TextEditingController());
    });
  }

  void _removeSerialNumberField(int index) {
    if (_serialNumberControllers.length > 1) {
      setState(() {
        _serialNumberControllers[index].dispose();
        _serialNumberControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      List<String> serialNumbers =
          _serialNumberControllers.map((c) => c.text).where((s) => s.isNotEmpty).toList();

      Map<String, dynamic> updatedData = {
        "Status": "Delivered",
        "TotalCollectedAmount": _collectedAmountController.text,
        "TotalCollectedBottles": _bottlesReturnedController.text,
        "serialNumberProvided": serialNumbers,
      };

      print('Data:$updatedData');

      try {

      bool success = await AuthService().updateOrderData(widget.order['OrderID'], updatedData);

      if (success) {
        Navigator.pop(context,true);
        
        
          Fluttertoast.showToast(
            msg: 'Order Delivered',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.5),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
        
          Fluttertoast.showToast(
            msg: 'Failed to delivered order. Please try again.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.5),
            textColor: Colors.white,
            fontSize: 16.0,
        );
      }
      } catch (e) {

        Fluttertoast.showToast(
          msg: e.toString().replaceAll('Exception: ', ''),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }

     
    }
  }

  Widget _buildStyledTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow("Customer Name:", widget.order['CustomerID']?['Name'] ?? 'N/A'),
              _buildInfoRow("Pending Amount:", (widget.order['TotalPendingAmount'] ?? 'N/A').toString()),
              _buildInfoRow("Pending Bottles:", (widget.order['TotalPendingBottles'] ?? 'N/A').toString()),
              _buildInfoRow("Current Bill:", (widget.order['TotalPrice'] ?? 'N/A').toString()),
              _buildInfoRow("Current Bottle:", (widget.order['Bottles'][0]['NumberOfBottles'] ?? 'N/A').toString()),

              const SizedBox(height: 10),
              _buildStyledTextField(_bottlesReturnedController, "Bottles Returned", isNumeric: true),
              const SizedBox(height: 10),
              _buildStyledTextField(_collectedAmountController, "Collected Amount", isNumeric: true),
              const SizedBox(height: 10),

              Text("Serial Numbers", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),

          

              Column(
                    children:
                        List.generate(_serialNumberControllers.length, (index) {
                      return Column(
                    children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStyledTextField(
                                  _serialNumberControllers[index],
                                  "Serial Number",
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    _removeSerialNumberField(index),
                              ),
                            ],
                          ),
                          // Add vertical spacing between serial number fields
                          if (index <
                              _serialNumberControllers.length -
                                  1) // Avoid adding space after the last field
                            const SizedBox(height: 10),
                    ],
                  );
                }),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  label: const Text("Add Serial"),
                  onPressed: _addSerialNumberField,
                ),
              ),

              const SizedBox(height: 10),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Update"),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    ),
            ],
          ),
        ),
      ),

        ));
    
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }


}

// Function to show the modal
void showDeliveredStatusModal(BuildContext context, Map<String, dynamic> order) async {
  final result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return DeliveredStatusModal(order: order);
    },
  );

  if (result != null) {
    print("Updated Delivered Status: $result");
  }
}
