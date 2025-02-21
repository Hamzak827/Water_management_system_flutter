import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/theme_provider.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:water_management_system/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({Key? key, required this.role}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  bool loading = true;
  Map<String, dynamic> data = {};

  double totalAmountReceived = 0;
  double totalAmountPending = 0;
  double totalBottlesSent = 0;
  double totalEmptyBottlesReceived = 0;
  double totalPendingBottles = 0;
  double totalOrders = 0;

  double totalTillDateCredit = 0;
  double totalTillDateIncome = 0;
  double totalTillDateSales = 0;
  double totalTillDatePendingBottles = 0;

  int deliveredCount = 0;
  int canceledCount = 0;
  int outForDeliveryCount = 0;
  int processingCount = 0;

  String _selectedFilter = '7days'; // Default filter type
  String? _fromDate;
  String? _toDate;

  

  // Dropdown options for date filter
  final List<String> filterOptions = ['7days', '30days', 'today', 'Custom Range'];

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
      print("Fetching data with filter: $_selectedFilter");
      print("From Date: $_fromDate, To Date: $_toDate");

      // Simulate data fetching to demonstrate the shimmer effect
      await Future.delayed(Duration(seconds: 2));

      final data = await _authService.getDashboardData(
        _selectedFilter,
        from: _fromDate,
        to: _toDate,
        filterType: _selectedFilter,
      );

      print("Data: $data");
      setState(() {
        this.data = data;
        loading = false; // Hide shimmer once data is fetched
        processStatistics(data);
      });
    } catch (error) {
      setState(() {
        loading = false; // Hide shimmer in case of an error
      });
      print("Error fetching data: $error");
    }
  }

  void processStatistics(Map<String, dynamic> data) {
    // Reset all statistics to avoid accumulation
    totalAmountReceived = 0;
    totalAmountPending = 0;
    totalBottlesSent = 0;
    totalEmptyBottlesReceived = 0;
    totalPendingBottles = 0;
    totalOrders = 0;

    totalTillDateCredit = 0;
    totalTillDateIncome = 0;
    totalTillDateSales = 0;
    totalTillDatePendingBottles = 0;

    deliveredCount = 0;
    canceledCount = 0;
    outForDeliveryCount = 0;
    processingCount = 0;

    // Access the relevant data
    Map<String, dynamic> rangeStatistics = data['data']['rangeStatistics'];
    Map<String, dynamic> tillDateStatistics = data['data']['tillDateStatistics'];

    // Process rangeStatistics
    totalAmountReceived += rangeStatistics['totalAmountReceived'] ?? 0;
    totalAmountPending += rangeStatistics['totalAmountPending'] ?? 0;
    totalBottlesSent += rangeStatistics['totalBottlesSent'] ?? 0;
    totalEmptyBottlesReceived += rangeStatistics['totalEmptyBottlesReceived'] ?? 0;
    totalPendingBottles += rangeStatistics['totalPendingBottles'] ?? 0;
    totalOrders += rangeStatistics['totalOrders'] ?? 0;

    // Process statuses
    rangeStatistics['statuses']?.forEach((status, count) {
      int statusCount = count is int ? count : count?.toInt() ?? 0;
      switch (status) {
        case 'Delivered':
          deliveredCount += statusCount;
          break;
        case 'Canceled':
          canceledCount += statusCount;
          break;
        case 'Out For Delivery':
          outForDeliveryCount += statusCount;
          break;
        case 'Processing':
          processingCount += statusCount;
          break;
        default:
          break;
      }
    });

    // Process tillDateStatistics
    totalTillDateCredit += tillDateStatistics['totalTillDateCredit'] ?? 0;
    totalTillDateIncome += tillDateStatistics['totalTillDateIncome'] ?? 0;
    totalTillDateSales += tillDateStatistics['totalTillDateSales'] ?? 0;
    totalTillDatePendingBottles += tillDateStatistics['totalTillDatePendingBottles'] ?? 0;
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
      // If the user selects a date range
      setState(() {
        _fromDate = DateFormat('yyyy-MM-dd').format(selectedRange.start);
        _toDate = DateFormat('yyyy-MM-dd').format(selectedRange.end);
      });

      // Fetch data after date selection
      fetchData();
    } else {
      // If the user closes the date picker without selecting a date
      setState(() {
        _selectedFilter = '7days'; // Apply default filter
        _fromDate = null; // Reset custom date range
        _toDate = null; // Reset custom date range
      });

      // Fetch data with the default filter
      fetchData();
  }
}

  Set<String> hiddenLegends = {}; // Track disabled legends

  void _toggleLegend(String label) {
    setState(() {
      if (hiddenLegends.contains(label)) {
        hiddenLegends.remove(label);
      } else {
        hiddenLegends.add(label);
      }
    });
  }

  Widget _buildLegend(String label, Color color) {
    return GestureDetector(
      onTap: () => _toggleLegend(label),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: hiddenLegends.contains(label) ? Colors.grey : color,
                  fontSize: 12)),
        ],
      ),
    );
  }




List<BarChartGroupData> _buildChartData() {
    final List<Map<String, dynamic>> data = [
      {
        'label': 'Amount Received',
        'value': totalAmountReceived.toInt(),
        'color': Colors.blue
      },
      {
        'label': 'Amount Pending',
        'value': totalAmountPending.toInt(),
        'color': Colors.red
      },
      {
        'label': 'Bottle Shipped',
        'value': totalBottlesSent.toInt(),
        'color': Colors.green
      },
      {
        'label': 'Empty Bottles',
        'value': totalEmptyBottlesReceived.toInt(),
        'color': Colors.orange
      },
      {
        'label': 'Pending Bottles',
        'value': totalPendingBottles.toInt(),
        'color': Colors.purple
      },
      {'label': 'Orders', 'value': totalOrders.toInt(), 'color': Colors.teal},
    ];

    return List.generate(data.length, (index) {
      final item = data[index];
      final isHidden = hiddenLegends.contains(item['label']);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: isHidden
                ? 0
                : _clampValue(item['value']
                    .toDouble()), // Keep bar position but hide value
            color: isHidden
                ? Colors.transparent
                : item['color'], // Make invisible if hidden
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 3000,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
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

  Color _getBarColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue; // Amount Received
      case 1:
        return Colors.red;  // Amount Pending
      case 2:
        return Colors.green; // Bottles Sent
      case 3:
        return Colors.orange; // Empty Bottles Received
      case 4:
        return Colors.purple; // Pending Bottles
      case 5:
        return Colors.teal; // Orders
      default:
        return Colors.blue;
    }
  }

  double _clampValue(double value) {
    final double minY = -3000;
    final double maxY = 3000;
    if (value < minY) return minY;
    if (value > maxY) return maxY;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.role == 'super-admin'
                    ? 'Super Admin Dashboard'
                    : 'Admin Dashboard',
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.bold))),
        drawer: Sidebar(
          role: widget.role,
          onMenuItemClicked: (route) {
            Navigator.pushNamed(context, route);
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lifetime Statistics
                    Text('Lifetime Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      itemCount: 3,
                      itemBuilder: (context, index) => buildShimmerCard(),
                    ),
                    SizedBox(height: 32),

                    // Order Status Distribution
                    Text('Order Status Distribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Container(height: 200, color: Colors.grey[300]), // Placeholder for the Pie Chart
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerLegend(),
                          _buildShimmerLegend(),
                          _buildShimmerLegend(),
                          _buildShimmerLegend(),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Current Range Statistics
                    Text('Current Range Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      itemBuilder: (context, index) => buildShimmerCard(),
                    ),
                    SizedBox(height: 32),

                    // Statistics Trends
                    Text('Statistics Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: List.generate(6, (_) => _buildShimmerLegend()),
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      height: 250,
                      color: Colors.grey[300], // Placeholder for Bar Chart
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(widget.role == 'super-admin'
                ? 'Super Admin Dashboard'
                    : 'Admin Dashboard',
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.bold))),
        drawer: Sidebar(
          role: widget.role,
          onMenuItemClicked: (route) {
            Navigator.pushNamed(context, route);
          },
        ),
        body: Center(child: Text("No data available")),
      );
    }

    final totalStatusCount =
        deliveredCount + canceledCount + outForDeliveryCount + processingCount;

    // Determine whether all statuses are zero
    bool allStatusesAreZero = (processingCount == 0 &&
        outForDeliveryCount == 0 &&
        deliveredCount == 0 &&
        canceledCount == 0);

    // Default pie chart data if all statuses are zero
    List<PieChartSectionData> defaultPieChartSections = [
      PieChartSectionData(
        value: 1,
        color: Colors.grey,
        title: 'No Data',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    // Define pie chart sections dynamically based on the condition
    final pieChartSections = allStatusesAreZero
        ? [
            PieChartSectionData(
              value: 1,
              color: Colors.grey,
              title: 'No Data',
              radius: 30,
              titleStyle: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ]
        : [
            PieChartSectionData(
              value: deliveredCount.toDouble(),
              color: Colors.green,
              
              title: '${(deliveredCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              radius: 30, // Adjust thickness
              titleStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            PieChartSectionData(
              value: canceledCount.toDouble(),
              color: Colors.orange,
              title: '${(canceledCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              radius: 30, // Adjust thickness
              titleStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            PieChartSectionData(
              value: outForDeliveryCount.toDouble(),
              color: Colors.blue,
              title: '${(outForDeliveryCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              radius: 30, // Adjust thickness
              titleStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            PieChartSectionData(
              value: processingCount.toDouble(),
              color: Colors.yellow,
              title: '${(processingCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              radius: 30, // Adjust thickness
              titleStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ];

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.role == 'super-admin'
              ? 'Super Admin Dashboard'
            : 'Admin Dashboard',
        style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
      )),
      drawer: Sidebar(
        role: widget.role,
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
          iconColor:
          Colors.white; 
        },
        
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [





            // Filter Dropdown
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Ensures proper spacing
              children: [
                // Left-aligned text
                Text(
                  'Lifetime Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                // Right-aligned dropdown
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade100,
                        Color.fromARGB(255, 218, 217, 217)
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
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    itemBuilder: (context) => filterOptions.map((filter) {
                      return PopupMenuItem<String>(
                        value: filter,
                        child: Row(
                          children: [
                            Icon(
                              _getFilterIcon(filter),
                              color: Colors.blue.shade800,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              filter,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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
                        _fromDate = null;
                        _toDate = null;
                      });
                      if (newValue == 'Custom Range') {
                        Future.delayed(Duration.zero,
                            () => _showFullScreenDatePicker(context));
                      } else {
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
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue.shade800,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Column(
              children: List.generate(3, (index) {
                final titles = [
                  'Total Sales',
                  'Total Incomes',
                  'Total Credit',
                ];
                final values = [
                  totalTillDateSales,
                  totalTillDateIncome,
                  totalTillDateCredit,
                ];
                final icons = [
                  Icons.shopping_cart, // Icon for Total Sales
                  Icons.attach_money, // Icon for Total Incomes
                  Icons.credit_card, // Icon for Total Credit
                ];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0), // Spacing between cards
                  child: SizedBox(
                    width: double.infinity, // Full width
                    height: 100, // Set the height you want
                    child: buildStatisticsCardWithIcon(
                            titles[index], values[index], icons[index])
                        .animate()
                        .slideY(duration: 1000.ms, curve: Curves.easeInOut)
                        .fadeIn(duration: 1000.ms),
                  ),
                );
              }),
            ),



            SizedBox(height: 20),

        
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                
                  Text(
                    'Order Status Distribution',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 25), // Customize spacing

                  // Legends and Pie Chart
                  // Legends and Pie Chart Section with Background and Styling
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade100,
                          Color.fromARGB(255, 218, 217, 217)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [
                          0.1,
                          0.9
                        ], // Adjust gradient stops for smoother transitions
                      ),
                      borderRadius:
                          BorderRadius.circular(20), // Increased border radius
                      border: Border.all(
                        color: const Color.fromARGB(
                            255, 41, 42, 42), // More vibrant border color
                        width: 1, // Slightly thicker border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 68, 68, 68)
                              .withOpacity(0.3), // Subtle shadow
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(
                              0, 4), // Shadow positioned below the container
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegends(
                                      context, 'Delivered', Colors.green),
                                  _buildLegends(
                                      context, 'Canceled', Colors.orange),
                                  _buildLegends(
                                      context, 'Out For Delivery', Colors.blue),
                                  _buildLegends(
                                      context, 'Processing', Colors.yellow),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 180,
                                child: PieChart(
                                  PieChartData(
                                    sections: pieChartSections,
                                    centerSpaceRadius: 50,
                                    sectionsSpace: 2,
                                  ),
                                )
                                    .animate()
                                    .rotate(
                                        duration: 1000.ms,
                                        curve: Curves.easeInOut)
                                    .fadeIn(duration: 1000.ms),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Customize spacing
                ],
              ),
            ),
            SizedBox(height: 32),

            // Current Range Statistics
            Text(
              'Current Range Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 18),

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
      'Amount Received',
      'Pending Amount',
      'Bottles Shipped',
      'Empty Bottles Received',
      'Pending Bottles',
    ];
    final values = [
      totalOrders,
      totalAmountReceived,
      totalAmountPending,
      totalBottlesSent,
      totalEmptyBottlesReceived,
      totalPendingBottles,
    ];
                return buildStatisticsCard(titles[index], values[index])
                    .animate()
                    .slideY // Add animation
                    (
                        duration: 1000.ms,
                        curve: Curves.easeInOut) // Rotate animation
                    .fadeIn(duration: 1000.ms);
                ;
  },
),

          SizedBox(height: 32),
            Text(
              'Statistics Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            SizedBox(
              height: 300,
              child: Column(
                children: [
                  // Bar chart
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        // First Row with two items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child:
                                  _buildLegend('Amount Received', Colors.blue),
                            ),
                          
                            SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: _buildLegend('Amount Pending', Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(height: 4), // Space between rows

                        // Second Row with two items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child:
                                  _buildLegend('Bottle Shipped', Colors.green),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child:
                                  _buildLegend('Empty Bottles', Colors.orange),
                            ),
                           
                          ],
                        ),
                        SizedBox(height: 4), // Space between rows

                        // Third Row with two items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: _buildLegend(
                                  'Pending Bottles', Colors.purple),
                            ),
                           
                            SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: _buildLegend('Orders', Colors.teal),
                            ),
                           
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final dateFormat = DateFormat('dd MMM');
                                final date = DateTime.now().subtract(
                                    Duration(days: (9 - value.toInt())));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    dateFormat.format(date),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1000,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text('${value.toInt()}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey));
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 1000,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1),
                          getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                        ),
                        minY: -3000,
                        maxY: 3000,
                        barGroups: _buildChartData(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem('${rod.toY.toInt()}',
                                  const TextStyle(color: Colors.white));
                            },
                          ),
                        ),
                      ),
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



  Widget buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey,
      ),
    );
  }
}
Widget buildStatisticsCard(String title, double value) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(14), // Slightly larger radius for outer border
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), // Subtle shadow effect
          blurRadius: 8,
          offset: Offset(2, 4),
        ),
      ],
    ),
    child: Container(
      margin:
          EdgeInsets.all(2), // The space between the outer and inner container
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
            color: Colors.black.withOpacity(0.1), // Light shadow for inner card
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

Widget buildStatisticsCardWithIcon(String title, double value, IconData icon) {
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
          offset: Offset(4, 8), // Increased offset for a more pronounced shadow
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






Widget _buildLegends(BuildContext context, String label, Color color) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0), // Set the top margin here
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                Colors.black, // Adapts to theme, // Get text color from theme
          ),
        ),
      ],
    ),
  );
}



Widget _buildShimmerLegend() {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: 8),
      Container(
        width: 100,
        height: 16,
        color: Colors.grey[300],
      ),
    ],
  );
}
