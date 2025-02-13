import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/providers/auth_provider.dart';

class AuthService {
  final String baseUrl = 'https://staging-water-management-system.vercel.app/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /////////////////////////////////////// Login Request////////////////////////////////////////////////////////////////
  Future<Map<String, dynamic>> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/login');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'Email': email, 'Password': password}),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token']; // Replace with the actual key for the token
      // final deliveryBoyId=data['DeliveryBoyID'].toString();
      // final customerId=data['Profile']['CustomerID'].toString();
      final String? deliveryBoyId = data['DeliveryBoyID']?.toString();
      final String? customerId = data['Profile']?['CustomerID']?.toString();

      await _storage.write(key: 'authToken', value: token); // Save token securely
      await _storage.write(key: 'deliveryboyId',value: deliveryBoyId);
      await _storage.write(key: 'customerId',value: customerId);

      // Debug: Log the token and the response data
      print('Login successful, token: $token');
      print('Response data: $data');

      return data; // Return user data
    } else if (response.statusCode == 401) {
      // Unauthorized: Invalid email or password
      throw Exception('Invalid email or password. Please try again.');
    } else if (response.statusCode >= 500) {
      // Server error
      throw Exception('Server error. Please try again later.');
    } else {
      // Other errors
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error occurred.';
      throw Exception(errorMessage);
    }
  } on SocketException {
    // Handle no internet connection
    throw Exception('No internet connection. Please check your connection and try again.');
  } catch (e) {
    // General error handling
    throw Exception('$e');
  }
}


  

//////////////////////////////////////// Super Admin Home Screen //////////////////////////////////////////////////////

 Future<dynamic> getDashboardData(String rangeType, {String? from, String? to, required String filterType}) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

  Uri url;

  // Check if it's a custom range and both from and to are provided
  if (rangeType == 'Custom Range' && from != null && to != null) {
    url = Uri.parse('$baseUrl/statistics/orders?from=$from&to=$to');
  } else {
    // For predefined ranges (Today, 7 days, 30 days)
    url = Uri.parse('$baseUrl/statistics/orders?rangeType=$rangeType&filterType=$filterType');
  }

  // Print the final URL for debugging
  // print('Fetching data with URL: $url');
  // print('Fetching data with From Date: $from');
  // print('Fetching data with From Date: $to');

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    //print('getDashboardData Response: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body); // Return fetched data
    } else {
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      throw Exception('Failed to fetch data: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching dashboard data: $e');
  }
}



  ////////////////////////////////////// Fetch Customer Data//////////////////////////////////////////////////////////
  
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$baseUrl/customers');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('getCustomersData:${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch customer data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching customer data: $e');
    }
  }


 /////////////////////////////// Update Customer Data////////////////////////////////////////////////////////////////
 
Future<bool> updateCustomerData(String customerId, Map<String, dynamic> updatedData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/customers/$customerId');
  print("URL being called: $url");

  try {
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedData),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Bad Request: Invalid data sent');
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found');
    } else {
      throw Exception('Failed to update customer data: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
     throw Exception('$e');
  }
}




/////////////////////////////// Add a new Customer Data///////////////////////////////////////////////////////////////
Future<bool> addNewCustomer(Map<String, dynamic> newCustomerData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(newCustomerData),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Customer with this Email already exists');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Failed to add customer: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}


////////////////////////////////Delete a customer/////////////////////////////////////////////////////////////////////
   Future<bool> deleteCustomer(String customerId) async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
   if (token == null) {
    throw Exception('No authentication token found');
      }
    final url = Uri.parse('$baseUrl/customers/$customerId');
    final response = await http.delete(
      url,
       headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        
      });
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

    if (response.statusCode == 204) {
      return true; // Successfully deleted
    } else {
      return false; // Failed to delete
    }
  }
 



 ////////////////////////////////////// Fetch DeliveryBoy Data////////////////////////////////////////////////////////
  
  Future<List<Map<String, dynamic>>> fetchDeliveryBoys() async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$baseUrl/delieveryboy');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to deliveryboy data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deliveryboy data: $e');
    }
  }






/////////////////////////////// Update Deliveryboy Data///////////////////////////////////////////////////////////////
 
Future<bool> updateDeliveryboyData(String deliveryboyId, Map<String, dynamic> deliveryboyData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/delieveryboy/$deliveryboyId');
  print("URL being called: $url");

  try {
    final response = await http.put(
      url,
      headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json', // Add Content-Type header
      },
      body: json.encode(deliveryboyData),
    );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(deliveryboyData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}'); // Print the full response body

   if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Bad Request: Invalid data sent');
    } else if (response.statusCode == 404) {
      throw Exception('Deliveryboy not found');
    } else {
      throw Exception('Failed to update deliveryboy data: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
     throw Exception('$e');
  }
}




////////////////////////////// Add a new Deliveryboy Data/////////////////////////////////////////////////////////////
 Future<bool> addNewDeliveryboy(Map<String, dynamic> deliveryboyData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delieveryboy'),
        headers: {
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json',
        },
        body: json.encode(deliveryboyData),
      );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(deliveryboyData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}'); // Print the full response body

     if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 409) {
      throw Exception('Deliveryboy with this Name/Email already exists');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Failed to add customer: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
  }



  ////////////////////////////////Delete a customer///////////////////////////////////////////////////////////////////
   Future<bool> deleteDeliveryboy(String deliveryboyId) async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
   if (token == null) {
    throw Exception('No authentication token found');
      }
    final url = Uri.parse('$baseUrl/delieveryboy/$deliveryboyId');
    final response = await http.delete(
      url,
       headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        
      });
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      return false; // Failed to delete
    }
  }



  ////////////////////////////////////// Fetch DeliveryBoy Data///////////////////////////////////////////////////////
  
  Future<List<Map<String, dynamic>>> fetchAdmin() async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$baseUrl/admin');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to admin data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error admin data: $e');
    }
  }

 


/////////////////////////////// Update Admin Data///////////////////////////////////////////////////////////////////
 
Future<bool> updateAdminData(String deliveryboyId, Map<String, dynamic> deliveryboyData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/admin/$deliveryboyId');
  print("URL being called: $url");

  try {
    final response = await http.put(
      url,
      headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json', // Add Content-Type header
      },
      body: json.encode(deliveryboyData),
    );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(deliveryboyData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}'); // Print the full response body

   
     if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Admin with this Email/Phone already exists');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Failed to add admin: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}



////////////////////////////// Add a new Admin Data/////////////////////////////////////////////////////////////////
 Future<bool> addNewAdmin(Map<String, dynamic> deliveryboyData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin'),
        headers: {
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json',
        },
        body: json.encode(deliveryboyData),
      );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(deliveryboyData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}'); // Print the full response body



      
     if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 409) {
      throw Exception('Admin with this Email/Phone already exists');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Failed to add admin: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
  }



////////////////////////////////////////Delete a customer////////////////////////////////////////////////////////////
   Future<bool> deleteAdmin(String adminId) async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
   if (token == null) {
    throw Exception('No authentication token found');
      }
    final url = Uri.parse('$baseUrl/admin/$adminId');
    final response = await http.delete(
      url,
       headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        
      });
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      return false; // Failed to delete
    }
  }


////////////////////////////////////// Fetch Order Data///////////////////////////////////////////////////////
  
  Future<List<Map<String, dynamic>>> fetchOrder() async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$baseUrl/order');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to order data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error order data: $e');
    }
  }


  /////////////////////////////// Update Admin Data///////////////////////////////////////////////////////////////////
 
Future<bool> updateOrderData(String orderId, Map<String, dynamic> orderData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/order/$orderId');
  print("URL being called: $url");

  try {
    final response = await http.put(
      url,
      headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json', // Add Content-Type header
      },
      body: json.encode(orderData),
    );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(orderData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}'); // Print the full response body


 if (response.statusCode == 200) {
      return true;
    }  else {
      throw Exception('Failed to update order: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}




////////////////////////////// Add a new Order Data/////////////////////////////////////////////////////////////////
 Future<bool> addNewOrder(Map<String, dynamic> orderData) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/order'),
        headers: {
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(orderData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}'); // Print the full response body



 if (response.statusCode == 201) {
      return true;
    }  else {
      throw Exception('Failed to add order: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
  }




////////////////////////////////////////Delete a order////////////////////////////////////////////////////////////
   Future<bool> deleteOrder(String orderId) async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
   if (token == null) {
    throw Exception('No authentication token found');
      }
    final url = Uri.parse('$baseUrl/order/$orderId');
    try{
    final response = await http.delete(
      url,
       headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        
      });
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      return false; // Failed to delete
    }
    }on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
  }


 
////////////////////////////////////////Update a address of specific customer////////////////////////////////////////////////////////////

Future<bool> updateCustomerAddress(String customerId, String addressId, Map<String, dynamic> updatedAddress) async {
  // if (customerId.isEmpty || addressId.isEmpty) {
  //   throw Exception('Customer ID or Address ID is empty');
  // }

  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null || token.isEmpty) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/customers/$customerId/address/$addressId');
  print("URL being called: $url");

  try{

  final response = await http.patch(
    url,
    headers: {
      'Authorization': 'Bearer $token', // Add the Authorization header
      'Content-Type': 'application/json',
    },
    body: json.encode(updatedAddress),
  );
print('Response status: ${response.statusCode}');
 print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to update address');
  }
  }on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}

////////////////////////////////////////Add a address of specific customer////////////////////////////////////////////////////////////

// Function to add a new address with the new format
Future<bool> addCustomerAddress(String customerId, Map<String, dynamic> address) async {
  // if (customerId.isEmpty) {
  //   throw Exception('Customer ID is empty');
  // }

  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null || token.isEmpty) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/customers/$customerId/address');
  
  print("URL being called: $url");


  // Wrapping the address in the required format
  final addressData = {
    'address': address,
  };

  // Sending the request to add the address
  try{
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token', // Add the Authorization header
      'Content-Type': 'application/json',
    },
    body: json.encode(addressData), // Send the formatted address data
  );
  print('Response status: ${response.statusCode}');
   print('Response body: ${response.body}');
 print('Updated data before sending: ${json.encode(addressData)}');
  if (response.statusCode == 200) {
    return true;
  }else if (response.statusCode == 400) {
      throw Exception('Address already exists for Customer');
    } else {
    throw Exception('Failed to add address');
  }
  }on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}

////////////////////////////////////////Delete a specific customer////////////////////////////////////////////////////////////
   Future<bool> deleteCustomerAddress(String customerId, String addressId,) async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token
   if (token == null) {
    throw Exception('No authentication token found');
      }
    final url = Uri.parse('$baseUrl/customers/$customerId/address/$addressId');
    try{
    final response = await http.delete(
      url,
       headers: {
       
        'Authorization': 'Bearer $token', // Add the Authorization header
        
      });
     print('Response body: ${token}');
     print('Response body: ${response.body}');
     print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true; // Successfully deleted
    } else {
      return false; // Failed to delete
    }
    }on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
  }
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
////////////////////////////////////// Fetch Deliveryboy Orders Data///////////////////////////////////////////////////////
  
 

  Future<List<Map<String, dynamic>>> fetchDeliveryboyOrder(BuildContext context) async {
 final token = await _storage.read(key: 'authToken'); // Retrieve token
 final deliveryboyId= await _storage.read(key:'deliveryboyId');



 
 

   if (token == null) {
    throw Exception('No authentication token found');
      }
    
  final url = Uri.parse('$baseUrl/order/delivery_boy/$deliveryboyId');
  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Token: $token');
     print("URL being called: $url");
    print('Response body: ${response.body}');
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch order data: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}





 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
////////////////////////////////////// Fetch Customers Orders Data///////////////////////////////////////////////////////
  
 

  Future<List<Map<String, dynamic>>> fetchCustomerOrder(BuildContext context) async {
 final token = await _storage.read(key: 'authToken'); // Retrieve token
 final customerId= await _storage.read(key:'customerId');



 
 

   if (token == null) {
    throw Exception('No authentication token found');
      }
    
  final url = Uri.parse('$baseUrl/order/customer_id/$customerId');
  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Token: $token');
     print("URL being called: $url");
    print('Response body: ${response.body}');
    print('Response status: ${response.statusCode}');
    print('CustomerID: $customerId');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch order data: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}

 
////////////////////////////////////// Fetch Customers Address Data///////////////////////////////////////////////////////

Future<List<Map<String, dynamic>>> fetchCustomerAddresses(String customerId) async {
   final token = await _storage.read(key: 'authToken'); // Retrieve token
    final url = Uri.parse('$baseUrl/customers/$customerId/addresses');

     try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Token: $token');
     print("URL being called: $url");
    print('Response body: ${response.body}');
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch order data: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}


////////////////////////////////////// Fetch Specific Customers Data///////////////////////////////////////////////////////

Future<Map<String, dynamic>> fetchSpecificCustomer(String customerId) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  final url = Uri.parse('$baseUrl/customers/$customerId');

  try {
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Token: $token');
    print("URL being called: $url");
    print('Response body: ${response.body}');
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch customer data: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}

////////////////////////////// Add a new Customer Token Data/////////////////////////////////////////////////////////////
 Future<bool> addNewToken(Map<String, dynamic> tokenData,String customerId) async {
  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null) {
    throw Exception('No authentication token found');
  }

    final url = Uri.parse('$baseUrl/customers/$customerId/token');

    try {
      final response = await http.post(
        url,
        headers: {
        'Authorization': 'Bearer $token', // Add the Authorization header
        'Content-Type': 'application/json',
        },
        body: json.encode(tokenData),
      );
    print('Response status: ${response.statusCode}');
    print('Updated data before sending: ${json.encode(tokenData)}');
    print('Response body: ${response.body}');
    print('Response body: ${token}');
     print("URL being called: $url"); // Print the full response body

     if (response.statusCode == 201) {
      return true;
      } else if (response.statusCode == 400) {
        throw Exception(
            'Prepaid token with overlapping serial numbers already exists for this customer');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Failed to add token: ${response.body}');
    }
  } on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
  }





  
Future<bool> updateToken(String customerId, int index, Map<String, dynamic> updatedToken) async {
  // if (customerId.isEmpty || addressId.isEmpty) {
  //   throw Exception('Customer ID or Address ID is empty');
  // }

  final token = await _storage.read(key: 'authToken'); // Retrieve token
  if (token == null || token.isEmpty) {
    throw Exception('No authentication token found');
  }

  final url = Uri.parse('$baseUrl/customers/$customerId/token/$index');
  print("URL being called: $url");

  try{

  final response = await http.patch(
    url,
    headers: {
      'Authorization': 'Bearer $token', // Add the Authorization header
      'Content-Type': 'application/json',
    },
    body: json.encode(updatedToken),
  );
print('Response status: ${response.statusCode}');
 print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to update token');
  }
  }on SocketException {
    throw Exception('No internet connection');
  } catch (e) {
    print("Error: $e");
    throw Exception('$e');
  }
}



//////////////////////////////////////// Deliveryboy Home Screen //////////////////////////////////////////////////////

  Future<dynamic> getDeliveryBoyDashboardData(String rangeType,
      {String? from, String? to, required String filterType}) async {
    final token = await _storage.read(key: 'authToken'); // Retrieve token

    if (token == null) {
      throw Exception('No authentication token found');
    }
    final deliveryboyId = await _storage.read(key: 'deliveryboyId');

    Uri url;

    // Check if it's a custom range and both from and to are provided
    if (rangeType == 'Custom Range' && from != null && to != null) {
      url = Uri.parse(
          '$baseUrl/statistics/delivery-boy/$deliveryboyId?from=$from&to=$to');
    } else {
      // For predefined ranges (Today, 7 days, 30 days)
      url = Uri.parse(
          '$baseUrl/statistics/delivery-boy/$deliveryboyId?rangeType=$rangeType&filterType=$filterType');
    }

    // Print the final URL for debugging

    print('Fetching delivery boy data with URL: $url');
    print('Fetching delivery boy data with From Date: $from');
    print('Fetching delivery boy data with To Date: $to');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print('getDeliveryBoyDashboardData Response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return fetched data
      } else {
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to fetch delivery boy data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching delivery boy dashboard data: $e');
    }
  }



















}











