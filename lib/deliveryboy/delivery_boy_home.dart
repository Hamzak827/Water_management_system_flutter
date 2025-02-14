import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';

class DeliveryBoyHomeScreen extends StatefulWidget {
  const DeliveryBoyHomeScreen({Key? key}) : super(key: key);

  static const routeName =
      '/delivery-boy-home-screen'; // Add a route name for navigation

  @override
  State<DeliveryBoyHomeScreen> createState() => _DeliveryBoyHomeScreenState();
}

class _DeliveryBoyHomeScreenState extends State<DeliveryBoyHomeScreen> {
  final AuthService _authService = AuthService();

  bool loading = true;
  Map<String, dynamic> data = {};

  double totalAmountCollected = 0;
  double totalAmountPending = 0;
  double totalBottlesDelivered = 0;
  double totalEmptyBottlesCollected = 0;
  double totalPendingBottles = 0;
  double totalOrders = 0;

  String _selectedFilter = '7days'; // Default filter type
  String? _fromDate;
  String? _toDate;

  // Dropdown options for date filter
  final List<String> filterOptions = [
    '7days',
    '30days',
    'today',
    'Custom Range'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _onFilterChanged(String selectedFilter) {
    setState(() {
      _selectedFilter = selectedFilter;
      _fromDate = null; // Reset custom range dates if any
      _toDate = null;
      loading = true; // Show shimmer while loading data
    });
    fetchData(); // Fetch data for the selected filter
  }

  Future<void> fetchData() async {
    try {
      print("Fetching delivery boy data with filter: $_selectedFilter");
      print("From Date: $_fromDate, To Date: $_toDate");

      // Simulate data fetching to demonstrate the shimmer effect
      await Future.delayed(Duration(seconds: 2));

      // Fetch data for delivery boy
      final data = await _authService.getDeliveryBoyDashboardData(
        // Replace with the actual delivery boy ID
        _selectedFilter,
        from: _fromDate,
        to: _toDate,
        filterType: _selectedFilter,
      );

      print("Delivery Boy Data: $data");
      setState(() {
        this.data = data;
        loading = false; // Hide shimmer once data is fetched
        processStatistics(data); // Process the fetched data
      });
    } catch (error) {
      setState(() {
        loading = false; // Hide shimmer in case of an error
      });
      print("Error fetching delivery boy data: $error");
    }
  }

  void processStatistics(Map<String, dynamic> data) {
    setState(() {
      totalOrders = (data['data']?['totalOrders'] ?? 0).toDouble();
      totalAmountCollected =
          (data['data']?['totalAmountCollected'] ?? 0).toDouble();
      totalAmountPending =
          (data['data']?['totalAmountPending'] ?? 0).toDouble();
      totalBottlesDelivered =
          (data['data']?['totalBottlesDelivered'] ?? 0).toDouble();
      totalEmptyBottlesCollected =
          (data['data']?['totalEmptyBottlesCollected'] ?? 0).toDouble();
      totalPendingBottles =
          (data['data']?['totalPendingBottles'] ?? 0).toDouble();
    });
  }

  // Show date range picker modal in fullscreen with only current & past dates
  void _showFullScreenDatePicker(BuildContext context) async {
    DateTime now = DateTime.now();

    DateTimeRange? selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: now, // Restrict selection to current and past dates
      initialDateRange: DateTimeRange(
        start: now.subtract(Duration(days: 7)), // Default start to a week ago
        end: now, // Default end to today
      ),
    );

    if (selectedRange != null) {
      setState(() {
        _fromDate = DateFormat('yyyy-MM-dd').format(selectedRange.start);
        _toDate = DateFormat('yyyy-MM-dd').format(selectedRange.end);
      });

      // Fetch data after date selection
      fetchData();
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Today':
        return Icons.today;
      case 'This Week':
        return Icons.calendar_view_week;
      case 'This Month':
        return Icons.calendar_today;
      case 'Custom Range':
        return Icons.date_range;
      default:
        return Icons.filter_list;
    }
  }

  Widget buildStatisticsCard(String title, double value) {
    // Create a number formatter for large numbers
    final numberFormat = NumberFormat("#,##0.00", "en_US");

    // Function to convert large values into more readable formats
    String formatValue(double value) {
      if (value >= 1e12) {
        return (value / 1e12).toStringAsFixed(2) + " T"; // Trillion
      } else if (value >= 1e9) {
        return (value / 1e9).toStringAsFixed(2) + " B"; // Billion
      } else if (value >= 1e6) {
        return (value / 1e6).toStringAsFixed(2) + " M"; // Million
      } else if (value >= 1e3) {
        return (value / 1e3).toStringAsFixed(2) + " K"; // Thousand
      } else {
        return numberFormat
            .format(value); // Default formatting for smaller numbers
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                overflow:
                    TextOverflow.ellipsis, // Ensure title doesn't overflow
              ),
              maxLines: 1, // Ensure title fits in one line
            ),
            SizedBox(height: 8), // Space between title and value
            Text(
              formatValue(value), // Use the formatted value
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Color for the value
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch role from the AuthProvider
    final role = Provider.of<AuthProvider>(context).role;

    if (loading) {
return Scaffold(

        appBar: AppBar(title: Text('Dashboard')),
        drawer: Sidebar(
          role: role,
          onMenuItemClicked: (route) {
            Navigator.pushNamed(context, route);
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight, // Move to the right
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('Current Range Statistics',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300])),
              SizedBox(height: 16),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2 / 1.5,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Dashboard')),
        drawer: Sidebar(
          role: role,
          onMenuItemClicked: (route) {
            Navigator.pushNamed(context, route);
          },
        ),
        body: Center(child: Text("No data available")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      drawer: Sidebar(
        role: role,
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Dropdown
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  border: Border.all(
                    color: Colors.grey[300]!, // Border color
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12, // Shadow color
                      blurRadius: 4,
                      offset: Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                value: _selectedFilter,
                items: filterOptions.map((filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                      child: Row(
                        children: [
                          Icon(
                            _getFilterIcon(
                                filter), // Add an icon for each filter
                            color: Colors.blue, // Icon color
                            size: 20,
                          ),
                          SizedBox(width: 8), // Space between icon and text
                          Text(
                            filter,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87, // Text color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                    loading = true;
                    _fromDate = null; // Reset custom date range
                    _toDate = null; // Reset custom date range
                  });

                  if (newValue == 'Custom Range') {
                    // Directly show the full-screen date picker modal
                    Future.delayed(Duration.zero,
                        () => _showFullScreenDatePicker(context));
                  } else {
                    // Fetch data for other filters
                    fetchData();
                  }
                },
                  icon: Icon(
                    Icons.arrow_drop_down, // Dropdown arrow icon
                    color: Colors.blue, // Icon color
                    size: 24,
                  ),
                  underline: SizedBox(), // Remove the default underline
                  dropdownColor: Colors.white, // Dropdown background color
                  elevation: 2, // Dropdown elevation
                  borderRadius:
                      BorderRadius.circular(8), // Rounded corners for dropdown
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87, // Text color
                    fontWeight: FontWeight.w500,
                  ),
                ),


              ),
            ),
            SizedBox(height: 16),

            // Current Range Statistics
            Text(
              'Current Range Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // GridView for Statistics
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 16, // Space between columns
                mainAxisSpacing: 16, // Space between
                childAspectRatio:
                    2 / 1.5, // Adjust card aspect ratio for better visibility
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final titles = [
                  'Total Orders',
                  'Amount Collected',
                  'Amount Pending',
                  'Bottles Delivered',
                  'Empty Bottles Collected',
                  'Pending Bottles',
                ];
                final values = [
                  totalOrders,
                  totalAmountCollected,
                  totalAmountPending,
                  totalBottlesDelivered,
                  totalEmptyBottlesCollected,
                  totalPendingBottles,
                ];
                return buildStatisticsCard(titles[index], values[index]);
              },
            ),

            SizedBox(height: 32),
            



          ],
        ),
      ),
    );
  }

}
