import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    } else {
      // Reset the filter to the previous value if no date range is selected
      setState(() {
        _selectedFilter = '7days';
        _fromDate = null; // Reset custom date range
        _toDate = null; // Reset custom date range
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            14), // Slightly larger radius for outer border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Subtle shadow effect
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(
            2), // The space between the outer and inner container
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(12), // Inner container's border radius

          gradient: LinearGradient(
            colors: [
              // Color(0xFF00C6FB), // Light blue
              // Color(0xFF005BEA), // Reddish shade
              Color(0xFF14557B), // Light blue
              Color(0xFF7FCEC5),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          // color:

          //     Color(0xFFc67763),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.1), // Light shadow for inner card
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Wave Design

            // Card Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget buildStatisticsCardWithIcon(
      String title, double value, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // Color(0xFF00C6FB), // Light blue
            // Color(0xFF005BEA), // Reddish shade
            Color(0xFF14557B), // Light blue
            Color(0xFF7FCEC5),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.3), // Slightly stronger shadow color
            blurRadius: 16, // Increased blur radius for stronger effect
            offset:
                Offset(4, 8), // Increased offset for a more pronounced shadow
          ),
          BoxShadow(
            color: Colors.black
                .withOpacity(0.1), // Second shadow for additional depth
            blurRadius: 8, // Smaller blur radius for a subtler shadow
            offset: Offset(2, 4), // Slightly offset to enhance the effect
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon inside a round circle on the left
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Circle color
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(8), // Padding inside the circle
              child: Icon(
                icon,
                size: 30, // Adjust icon size
                color: Color(0xFF355C7D), // Icon color
              ),
            ),
            SizedBox(width: 16), // Spacing between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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

        appBar: AppBar(
          title: Text('Dashboard',
              style:
                  GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
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
        appBar: AppBar(
          title: Text('Dashboard',
              style:
                  GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
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
      appBar: AppBar(
        title: Text('Dashboard',
            style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
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
            // Filter Dropdown
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Ensures proper spacing
              children: [
                // Left-aligned text
                Text(
                  'Current Range Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                // Right-aligned dropdown
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade100,
                        Color.fromARGB(255, 218, 217, 217),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.1, 0.9],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color.fromARGB(255, 41, 42, 42),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    itemBuilder: (context) => filterOptions.map((filter) {
                      return PopupMenuItem<String>(
                        value: filter,
                        child: Row(
                          children: [
                            Icon(
                              _getFilterIcon(
                                  filter), // Add an icon for each filter
                              color: Colors.blue.shade800, // Icon color
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
                    onSelected: (newValue) {
                      setState(() {
                        _selectedFilter = newValue;
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedFilter,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87, // Text color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue.shade800, // Icon color
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),








           

            SizedBox(height: 16),

            // GridView for Statistics
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 0, // Space between columns
                mainAxisSpacing: 12, // Space between
                childAspectRatio:
                    2 / 1.2, // Adjust card aspect ratio for better visibility
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
