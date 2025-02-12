import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

String? _emailError;
String? _passwordError;


 void _login() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final data = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    final String role = data['role'];
    final String token = data['token'];
    final String? deliveryBoyId = data['DeliveryBoyID']?.toString();
    final String? customerId = data['Profile']?['CustomerID']?.toString();
    

    // Login successful, update state using Provider
    await Provider.of<AuthProvider>(context, listen: false).login(token, role,deliveryboyId: deliveryBoyId,customerId: customerId);

    // Navigate to the appropriate screen based on the role
    if (role == 'super-admin') {
      Navigator.pushReplacementNamed(context, '/super-admin-home-screen');
    } else if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-home-screen');
    } else if (role == 'customer') {
      Navigator.pushReplacementNamed(context, '/customer-home-screen');
    } else if (role == 'deliveryboy') {
      Navigator.pushReplacementNamed(context, '/delivery-boy-home-screen');
    }
  } catch (e) {
    // Show only the error message without "Exception:"
    final errorMessage = e.toString().replaceAll('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}




@override
Widget build(BuildContext context) {

  
  return Scaffold(
    backgroundColor: Colors.blueGrey[900],
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60),

          // Animated Logo
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: 2),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * -20),
                  child: child,
                ),
              );
            },
            child: Image.asset(
              "assets/login-logo.png",
              height: 200,
              width: 200,
            ),
          ),

          SizedBox(height: 30),

   

Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Email Field
    Column(
  children: [
    Container(
      height: 60, // Fixed height
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        onChanged: (value) => setState(() => _emailError = null),
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
          prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _emailError = 'Please enter an email');
            });
            return '';
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _emailError = null);
          });
          return null;
        },
      ),
    ),
    if (_emailError != null)
      Padding(
        padding: EdgeInsets.only(top: 5), // Space for the error message
        child: Text(
          _emailError!,
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
  ],
),

SizedBox(height: 25),

Column(
  children: [
    Container(
      height: 60, // Fixed height
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        onChanged: (value) => setState(() => _passwordError = null),
        obscureText: !_isPasswordVisible,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
          prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _passwordError = 'Please enter a password');
            });
            return '';
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _passwordError = null);
          });
          return null;
        },
      ),
    ),
    if (_passwordError != null)
      Padding(
        padding: EdgeInsets.only(top: 5), // Space for the error message
        child: Text(
          _passwordError!,
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
  ],
),


  SizedBox(height: 20),
        // Login Button with Neon Glow
      AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.cyanAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: _isLoading
            ? Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),

      // Rest of your code (e.g., login button, etc.)
    ],
  ),
)






        ],
      ),
    ),
  );
}

}
