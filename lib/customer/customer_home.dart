import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  
  const CustomerHomeScreen({Key? key}) : super(key: key);

  static const routeName = '/customer-order-screen';

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<Map<String, dynamic>> _customerFuture;
  final AuthService _authService = AuthService();

  String? _currentCustomer;
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Secure storage instance

  @override
  void initState() {
    super.initState();
    _fetchCustomerId(); // Fetch data when screen initializes
  }

  Future<void> _fetchCustomerId() async {
    final customerId = await _storage.read(key: 'customerId');
    setState(() {
      _currentCustomer = customerId ?? ''; // Ensure it's never null
    });
  }


Widget _buildShimmerEffect() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child:SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 480,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
    )
  );
}
  

Widget _buildProfileCard(customer, addresses) => Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Colors.blue.shade100, width: 1),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      
      children: [
        Row(
          children: [
            Icon(Icons.person_pin, color: Colors.blue.shade800, size: 28),
            const SizedBox(width: 12),
            Text(
              'Customer Profile',
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.blue.shade900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black12, height: 32),
        _buildInfoRow(Icons.badge, 'Name', customer['Name']),
        _buildInfoRow(Icons.email, 'Email', customer['Email']),
        _buildInfoRow(Icons.phone, 'Phone', customer['Phone']),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _buildDetailChip('Subscription', customer['SubscriptionType']),
            _buildDetailChip('Payment', customer['PaymentMethod']),
            _buildDetailChip('Security', '${customer['SecurityAmount'].toString()}'),
            _buildDetailChip('Bottles', customer['SecurityNumberofBottle'].toString()),
          ],
        ),
        if (addresses.isNotEmpty) ...[
          const Divider(color: Colors.black12, height: 32),
          _buildInfoRow(
            Icons.location_on,
            'Primary Address',
            '${addresses[0]['AddressLine']}, ${addresses[0]['City']}',
            multiLine: true,
          ),
        ],
      ],
    ),
  ),
);

Widget _buildBottleCard(customer) => Card(
  elevation: 4,
  color: Colors.orange.shade50,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Colors.orange.shade100, width: 1),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.local_drink, color: Colors.orange.shade800, size: 28),
            const SizedBox(width: 12),
            Text(
              'Bottle Status',
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.orange.shade900,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black12, height: 32),
        _buildMetricDisplay(
          'Total Remaining Balance',
          '${customer['TotalRemainingBalance'].toString()}',
          Colors.orange.shade700,
        ),
      ],
    ),
  ),
);

Widget _buildBalanceCard(customer) => Card(
  elevation: 4,
  color: Colors.green.shade50,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Colors.green.shade100, width: 1),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.green.shade800, size: 28),
            const SizedBox(width: 12),
            Text(
              'Balance Overview',
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black12, height: 32),
        _buildMetricDisplay(
          'Empty Bottles Remaining',
          '${customer['TotalRemainingEmptyBottles'].toString()}',
          Colors.green.shade700,
        ),
      ],
    ),
  ),
);

// Reusable Components
Widget _buildInfoRow(IconData icon, String label, String value, {bool multiLine = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.blueGrey.shade600, size: 22),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              maxLines: multiLine ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  ),
);

Widget _buildDetailChip(String label, String value) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue.shade100),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.blue.shade800,
        ),
      ),
    ],
  ),
);

Widget _buildMetricDisplay(String title, String value, Color color) => Column(
  children: [
    Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 8),
    Text(
      value,
      style: GoogleFonts.robotoMono(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  ],
);

  @override
  Widget build(BuildContext context) {
    // Fetch role from the AuthProvider
    final role = Provider.of<AuthProvider>(context).role;

    // Ensure _currentCustomer is not null before calling the fetch function
    if (_currentCustomer != null && _currentCustomer!.isNotEmpty) {
      _customerFuture = _authService.fetchSpecificCustomer(_currentCustomer!) as Future<Map<String, dynamic>>;
    } else {
      // If customer ID is null or empty, show a message or handle error
      return const Center(child: Text('Customer ID not found.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        centerTitle: true,
      ),
      drawer: Sidebar(
        role: role,
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      body:FutureBuilder<Map<String, dynamic>>(
  future: _customerFuture,
  builder: (ctx, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildShimmerEffect();
    } else if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 40),
            const SizedBox(height: 16),
            Text(
              'Failed to load customer data',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (snapshot.hasData) {
      final customer = snapshot.data!;
      final addresses = customer['Addresses'] ?? [];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(customer, addresses),
            const SizedBox(height: 20),
            _buildBottleCard(customer),
            const SizedBox(height: 20),
            _buildBalanceCard(customer),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          'No customer data available',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
  },
)





    );
  }
}

