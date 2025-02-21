import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:water_management_system/services/auth_service.dart';

class CanceledStatusModal extends StatefulWidget {
    final Map<String, dynamic> order;

  CanceledStatusModal({required this.order});

  @override
  _CanceledStatusModalState createState() => _CanceledStatusModalState();
}

class _CanceledStatusModalState extends State<CanceledStatusModal> {
  final TextEditingController _reasonController = TextEditingController();
  
  bool _isLoading = false;
    final AuthService _authService = AuthService();

  Future<void> _saveReason() async {
    String reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a reason for cancellation")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await AuthService().updateOrderData(widget.order['OrderID'], {
        "OrderComment": reason,
        "Status": "Canceled",
      });

      if (success) {
        
        Fluttertoast.showToast(
          msg: 'Order successfully canceled',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context,true); // Close modal with reason
      } else {
        
        Fluttertoast.showToast(
          msg: 'Failed to cancel order',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.3),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.3),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Text(
        "Please specify the reason for your cancellation",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter cancellation reason...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _saveReason,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }
}
