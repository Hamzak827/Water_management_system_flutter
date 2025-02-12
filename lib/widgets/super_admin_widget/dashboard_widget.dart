import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
        appBar: AppBar(title: Text('Dashboard')),
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
              radius: 40,
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
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            PieChartSectionData(
              value: canceledCount.toDouble(),
              color: Colors.orange,
              title: '${(canceledCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            PieChartSectionData(
              value: outForDeliveryCount.toDouble(),
              color: Colors.blue,
              title: '${(outForDeliveryCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            PieChartSectionData(
              value: processingCount.toDouble(),
              color: Colors.yellow,
              title: '${(processingCount / totalStatusCount * 100).toStringAsFixed(1)}%',
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ];

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
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
              alignment: Alignment.centerRight,  // Align to the right
              child: DropdownButton<String>(
                value: _selectedFilter,
                items: filterOptions.map((filter) {
                  return DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                    loading = true;
                    _fromDate = null; // Reset custom date range
                    _toDate = null;  // Reset custom date range
                  });

                  if (newValue == 'Custom Range') {
                    // Directly show the full-screen date picker modal
                    Future.delayed(Duration.zero, () => _showFullScreenDatePicker(context));
                  } else {
                    // Fetch data for other filters
                    fetchData();
                  }
                },
              ),
            ),

            Text(
              'Lifetime Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                return buildStatisticsCard(titles[index], values[index]);
              },
            ),

            SizedBox(height: 32),

            // Order Status Distribution
            Text(
              'Order Status Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
            SizedBox(height: 32),

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
    return buildStatisticsCard(titles[index], values[index]);
  },
),

          SizedBox(height: 32),
            Text(
              'Statistics Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
SizedBox(
  height: 500,
  child: Column(
    children: [
      // Bar chart

Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Wrap(
        spacing: 8.0, // Space between items
        runSpacing: 4.0, // Space between lines
        children: [
          _buildLegend('Amount Received',Colors.blue),
          _buildLegend( 'Amount Pending',Colors.red),
          _buildLegend('Bottle Shipped',Colors.green),
          _buildLegend('Empty Bottles',Colors.orange),
          _buildLegend('Pending Bottles',Colors.purple),
          _buildLegend('Orders',Colors.teal),
        ],
      ),
      ),

 SizedBox(height: 32),
      Expanded(
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
                      final date = DateTime.now().subtract(Duration(days: reversedIndex));
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
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black, width: 1)),
            minY: -3000,
            maxY: 3000,
            barGroups: _buildChartData(),
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

  Widget buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStatCard('Total Sales', totalTillDateSales),
        buildStatCard('Total Income', totalTillDateIncome),
        buildStatCard('Total Credit', totalTillDateCredit),
        buildStatCard('Total Orders', totalOrders),
        buildStatCard('Amount Received', totalAmountReceived),
        buildStatCard('Pending Amount', totalAmountPending),
        buildStatCard('Bottles Shipped', totalBottlesSent),
        buildStatCard('Empty Bottles Received', totalEmptyBottlesReceived),
        buildStatCard('Pending Bottles', totalPendingBottles),
       
        
      ],
    );
  }

  Widget buildStatCard(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value.toStringAsFixed(2)),
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
      return numberFormat.format(value); // Default formatting for smaller numbers
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
              overflow: TextOverflow.ellipsis, // Ensure title doesn't overflow
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

  Widget _buildLegend(String label, Color color) {

  return Padding(
  padding: const EdgeInsets.only(top: 10.0), // Set the top margin here
  child: Row(
    
   children: [
     
      Container(
        width: 16,
        height: 16,
        color: color,
      ),
      SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 16)),
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