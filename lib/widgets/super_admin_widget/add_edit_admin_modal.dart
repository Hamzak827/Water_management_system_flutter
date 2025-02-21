import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/error_dialog.dart'; // Ensure the API service is correctly imported

class AdminModal extends StatefulWidget {
  final Map<String, dynamic>? admin; // Only needed for editing
  final String? adminId; // Only needed for editing
  final bool isEditing; // Flag to distinguish between edit and add mode

  const AdminModal({
    Key? key,
    this.admin,
    this.adminId,
    required this.isEditing,
  }) : super(key: key);

  @override
  _AdminModalState createState() => _AdminModalState();
}

class _AdminModalState extends State<AdminModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.admin != null) {
      // For editing, initialize controllers with existing values
      _nameController = TextEditingController(text: widget.admin!['Name']);
      _emailController = TextEditingController(text: widget.admin!['Email']);
      _passwordController = TextEditingController(text: widget.admin!['Password']);
      _phoneController = TextEditingController(text: widget.admin!['Phone']);
    } else {
      // For adding, initialize empty controllers
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _passwordController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  _submitCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> adminData = {
        "Name": _nameController.text,
        "Email": _emailController.text,
        "Password": _passwordController.text, // Use default for add
        "Phone": _phoneController.text,
      };

try{
      bool success = false;
      if (widget.isEditing) {
        // For editing
        success = await AuthService().updateAdminData(widget.adminId!, adminData);
      } else {
        // For adding
        success = await AuthService().addNewAdmin(adminData);
      }

      if (success) {
        Navigator.pop(context, true); // Close the modal
       
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Admin Updated Successfully'
                : 'Admin Added Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.3),
            textColor: Colors.white,
            fontSize: 16.0,
          );
      } else {
      
          Fluttertoast.showToast(
            msg: widget.isEditing
                ? 'Failed to Updated Admin'
                : 'Failed to Added Admin',
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
    }
  }






  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.isEditing ? "Edit Admin" : "Add Admin"),
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
           
              const SizedBox(height: 5),
               _buildStyledTextField(_nameController, 'Name', isNumeric: false),
               SizedBox(height: 5),
                _buildStyledTextField(_emailController, 'Email', isEmail: true),
                 SizedBox(height: 5),
                _buildStyledTextField(_passwordController, 'Password', isPassword: true),
                 SizedBox(height: 5),
                _buildStyledTextField(_phoneController, 'Phone', isPhone: true),
                SizedBox(height: 20),
              const SizedBox(height: 15),

             
              const SizedBox(height: 5),

              // Submit Button
              Center(
                child: SizedBox(
                  width: 130.0, // Set your desired width
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: _submitCustomer,
                    child: Text(widget.isEditing ? 'Save Changes' : 'Add Delivery Boy'),
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


  

  Widget _buildStyledTextField(TextEditingController controller, String label,
    {bool isEmail = false, bool isNumeric = false, bool isPassword = false, bool isPhone = false,bool isName = false, bool isCnic = false}) {
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
          fillColor: Colors.grey[200],
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
        if (label =='CNIC' && (!RegExp(r'^\d{13}$').hasMatch(value!))) {
         return 'CNIC must be exactly 13 digits';
           }

        return null;
      },
    ),

    
  );
}
  
}
