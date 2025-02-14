import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart'; // Make sure the API service is correctly imported

class DeliveryboyModal extends StatefulWidget {
  final Map<String, dynamic>? deliveryboy; // Only needed for editing
  final String? deliveryboyId; // Only needed for editing
  final bool isEditing; // Flag to distinguish between edit and add mode

  const DeliveryboyModal({
    Key? key,
    this.deliveryboy,
    this.deliveryboyId,
    required this.isEditing,
  }) : super(key: key);

  @override
  _DeliveryboyModalState createState() => _DeliveryboyModalState();
}

class _DeliveryboyModalState extends State<DeliveryboyModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _assignedareaController;
  late TextEditingController _cnicController;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.deliveryboy != null) {
      // For editing, initialize controllers with existing values
      _nameController =
          TextEditingController(text: widget.deliveryboy!['Name']);
      _emailController =
          TextEditingController(text: widget.deliveryboy!['Email']);
      _passwordController =
          TextEditingController(text: widget.deliveryboy!['Password']);
      _phoneController =
          TextEditingController(text: widget.deliveryboy!['Phone']);
      _assignedareaController =
          TextEditingController(text: widget.deliveryboy!['AssignedArea']);
      _cnicController =
          TextEditingController(text: widget.deliveryboy!['CNIC']);
    } else {
      // For adding, initialize empty controllers
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _passwordController = TextEditingController();
      _phoneController = TextEditingController();
      _assignedareaController = TextEditingController();
      _cnicController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _assignedareaController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  void _submitDeliveryboy() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> deliveryboyData = {
        "Name": _nameController.text,
        "Email": _emailController.text,
        //"Password": widget.isEditing ? widget.deliveryboy!['Password'] : "defaultPassword",
        "Password": _passwordController.text,
        "Phone": _phoneController.text,
        "AssignedArea": _assignedareaController.text,
        "CNIC": _cnicController.text
      };

      try {
        bool success = false;
        if (widget.isEditing) {
          success = await AuthService()
              .updateDeliveryboyData(widget.deliveryboyId!, deliveryboyData);
        } else {
          success = await AuthService().addNewDeliveryboy(deliveryboyData);
        }

        if (success) {
          Navigator.pop(context, true);

          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Deliveryboy Updated Successfully'
                : 'Deliveryboy Added Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.3),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Failed to Updated Deliveryboy'
                : 'Failed to Add Deliveryboy',
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEditing ? "Edit Delivery Boy" : "Add Delivery Boy"),
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

                // Input Fields with Enhanced Styling
                _buildStyledTextField(_nameController, 'Name'),
                const SizedBox(height: 5),
                _buildStyledTextField(_emailController, 'Email', isEmail: true),
                const SizedBox(height: 3),
                _buildStyledTextField(_passwordController, 'Password',
                    isPassword: true),
                const SizedBox(height: 3),
                _buildStyledTextField(_phoneController, 'Phone', isPhone: true),
                const SizedBox(height: 3),
                _buildStyledTextField(_assignedareaController, 'AssignedArea'),
                const SizedBox(height: 3),
                _buildStyledTextField(_cnicController, 'CNIC', isCnic: true),
                const SizedBox(height: 15),

                const SizedBox(height: 5),

                // Submit Button
                Center(
                  child: SizedBox(
                    width: 130.0, // Set your desired width
                    height: 40.0,
                    child: ElevatedButton(
                      onPressed: _submitDeliveryboy,
                      child: Text(widget.isEditing
                          ? 'Save Changes'
                          : 'Add Delivery Boy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildStyledTextField(TextEditingController controller, String label,
      {bool isEmail = false,
      bool isNumeric = false,
      bool isPassword = false,
      bool isPhone = false,
      bool isName = false,
      bool isCnic = false}) {
    return SizedBox(
      height:
          60, // Increased height to accommodate error text without affecting layout
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          // Reserve space for error messages

          errorStyle: const TextStyle(
              height: 1, color: Colors.red), // Consistent height
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter a $label';
          }

          if (isEmail &&
              !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value!)) {
            return 'Please enter a valid email';
          }

          if (label == 'Password' && value!.length < 8) {
            return 'Password must be at least 8 characters';
          }

          if (isPhone && !RegExp(r"^03\d{9}$").hasMatch(value!)) {
            return 'Please enter 11 digits';
          }
          if (label == 'CNIC' && (!RegExp(r'^\d{13}$').hasMatch(value!))) {
            return 'CNIC must be exactly 13 digits';
          }

          return null;
        },
      ),
    );
  }
}
