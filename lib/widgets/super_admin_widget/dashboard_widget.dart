import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
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
    firstDate: DateTime(2000),  // Earliest selectable date
    lastDate: now,  // Restrict selection to current and past dates
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


  List<BarChartGroupData> _buildChartData() {
    final List<int> amounts = [
      totalAmountReceived.toInt(),
      totalAmountPending.toInt(),
      totalBottlesSent.toInt(),
      totalEmptyBottlesReceived.toInt(),
      totalPendingBottles.toInt(),
      totalOrders.toInt(),
    ];

    while (amounts.length < 10) {
      amounts.add(0);
    }

    final List<DateTime> dateLabels = List.generate(10, (index) {
      return DateTime.now().subtract(Duration(days: index));
    });

    return List.generate(10, (index) {
      final double clampedValue = _clampValue(amounts[index].toDouble());
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: clampedValue,
            color: _getBarColor(index), // Dynamically get the color based on the index
            width: 16,
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
        appBar: AppBar(title: Text(widget.role == 'super-admin' ? 'Super Admin Dashboard' : 'Admin Dashboard')),
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
                : 'Admin Dashboard')),
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
              : 'Admin Dashboard')),
      drawer: Sidebar(
        role: widget.role,
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
            SizedBox(height: 15),
            Text(
              'Lifetime Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),

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
              itemBuilder: (context, index) {
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
                return buildStatisticsCard(titles[index], values[index])
                    .animate()
                    .slideY // Add animation
                    (
                        duration: 1000.ms,
                        curve: Curves.easeInOut) // Rotate animation
                    .fadeIn(duration: 1000.ms);
              },
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
                    style: TextStyle(
                      fontSize: 20, // Customize font size for heading
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Customize text color
                    ),
                  ),
                  SizedBox(height: 5), // Customize spacing

                  // Legends and Pie Chart
                  Row(
                    children: [
                      // Legends on the left
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegend('Delivered', Colors.green),
                            _buildLegend('Canceled', Colors.orange),
                            _buildLegend('Out For Delivery', Colors.blue),
                            _buildLegend('Processing', Colors.yellow),
                          ],
                        ),
                      ),

                      // Pie Chart on the right
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 250, // Customize graph size
                          child: PieChart(
                            PieChartData(
                              sections: pieChartSections,
                              centerSpaceRadius:
                                  50, // Customize center space radius
                              sectionsSpace: 2,
                            ),
                          )
                              .animate()
                              .rotate // Add animation
                              (
                                  duration: 1000.ms,
                                  curve: Curves.easeInOut) // Rotate animation
                              .fadeIn(duration: 1000.ms), // Fade-in animation
                        ),
                      ),
                    ],
                  ),
                  // Customize spacing
                ],
              ),
            ),
            SizedBox(height: 5),

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
                 childAspectRatio: 2 / 1.5, // Adjust card aspect ratio for better visibility
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
            SizedBox(height: 16),
SizedBox(
              height: 350,
  child: Column(
    children: [
                  // Bar chart
Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildLegend('Amount Received', Colors.blue),
                            SizedBox(width: 8),
                            _buildLegend('Amount Pending', Colors.red),
                            SizedBox(width: 8),
                            _buildLegend('Bottle Shipped', Colors.green),
                          ],
                        ),
                        SizedBox(height: 4), // Space between rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildLegend('Empty Bottles', Colors.orange),
                            SizedBox(width: 8),
                            _buildLegend('Pending Bottles', Colors.purple),
                            SizedBox(width: 8),
                            _buildLegend('Orders', Colors.teal),
                          ],
                        ),
                      ],
                    ),
                  ),



 SizedBox(height: 32),


                  AspectRatio(
                    aspectRatio: 1.5, // Change ratio as needed
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final reversedIndex = 9 - value.toInt();
                                if (reversedIndex % 2 == 0) {
                                  final dateFormat = DateFormat('dd MMM');
                                  final date = DateTime.now()
                                      .subtract(Duration(days: reversedIndex));
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      dateFormat.format(date),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1000,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black, width: 1)),
                        minY: -3000,
                        maxY: 3000,
                        barGroups: _buildChartData(),
                        // Your chart configuration here...
                      ),
                    ),
                  ),

 
      // Legend
      
    ],
  ),
)


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
  final numberFormat = NumberFormat("#,##0.00", "en_US");

  String formatValue(double value) {
    if (value >= 1e12) {
      return (value / 1e12).toStringAsFixed(2) + " T";
    } else if (value >= 1e9) {
      return (value / 1e9).toStringAsFixed(2) + " B";
    } else if (value >= 1e6) {
      return (value / 1e6).toStringAsFixed(2) + " M";
    } else if (value >= 1e3) {
      return (value / 1e3).toStringAsFixed(2) + " K";
    } else {
      return numberFormat.format(value);
    }
  }

  return Card(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF3A6186).withOpacity(0.7),
            Colors.white,
            //Colors.blueAccent.withOpacity(0.5), Color(0xFF18FFFF)
          ], // Gradient colors
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(12), // Matches Card's shape
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Updated for contrast
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    formatValue(value),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Updated for contrast
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
    ),
  );
}

  Widget _buildLegend(String label, Color color) {

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
        Text(label, style: TextStyle(fontSize: 12)),
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