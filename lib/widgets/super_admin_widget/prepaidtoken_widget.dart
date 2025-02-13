import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/widgets/prepaidtoken_widget/add_edit_prepaidtoken_modal.dart';

class PrepaidTokenScreen extends StatefulWidget {
  final String role;

  const PrepaidTokenScreen({Key? key, required this.role}) : super(key: key);

  @override
  _PrepaidTokenScreenState createState() => _PrepaidTokenScreenState();
}

class _PrepaidTokenScreenState extends State<PrepaidTokenScreen> {
  final AuthService _authService = AuthService();
  late Future<List<Map<String, dynamic>>> _customersFuture;
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = []; // New filtered list
  int _currentPage = 0; // Track the current page
  final int _itemsPerPage = 4; // Number of items per page

  @override
  void initState() {
    super.initState();
    _fetchCustomers(); // Fetch customer data when the screen initializes
  }

  // General function to fetch customers
  void _fetchCustomers() {
    setState(() {
      _customersFuture = _authService.fetchCustomers();
    });
  }

  // Filter customers who have PrepaidTokens
  void _filterCustomers() {
    filteredCustomers = customers.where((customer) {
      return customer['PrepaidTokens'] != null &&
          customer['PrepaidTokens'].isNotEmpty;
    }).toList();
  }

// Helper method to show Used Tokens dialog
  void _showUsedTokensDialog(List<Map<String, dynamic>> usedTokens) {
    // Collect and combine all tokens
    Set<int> allTokens = {}; // Using a Set to ensure uniqueness
    for (var token in usedTokens) {
      allTokens.addAll(token['Tokens'].cast<int>());
    }

    // Convert Set back to List and sort for better readability
    //List<int> sortedTokens = allTokens.toList()..sort();

    // Show dialog with combined tokens
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Used Tokens"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allTokens.map((token) {
                return Text("$token");
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

// Helper method to show Prepaid Tokens dialog
  void _showPrepaidTokensDialog(List<Map<String, dynamic>> prepaidTokens) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Prepaid Token Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: prepaidTokens.map((token) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Token ID: ${token['_id']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                        "Start Serial Number: ${token['serialNumberStarting']}"),
                    Text("End Serial Number: ${token['serialNumberEnding']}"),
                    Text("Price Per Book: \$${token['PricePerBook']}"),
                    Text("Number of Tokens: ${token['numberoftokens']}"),
                    Divider(), // Add a divider between tokens for better readability
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

// Helper method to show Unused Tokens dialog in Grid format
  void _showUnusedTokensDialog(Map<String, dynamic> token) {
    int start = token['serialNumberStarting'];
    int end = token['serialNumberEnding'];
    List<int> unusedTokens =
        List.generate(end - start + 1, (index) => start + index);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Unused Tokens"),
          content: SizedBox(
            width: double.maxFinite, // Ensures the grid adapts to content
            height: 300, // Set a fixed height for scrollable grid
            child: GridView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Adjust to set number of columns
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5, // Adjust for token display size
              ),
              itemCount: unusedTokens.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(6),
                  child: Text(
                    "${unusedTokens[index]}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 4),
      child: Row(
        children: [
          Text(
            "$label ",
            style: GoogleFonts.sourceCodePro(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.sourceCodePro(
                  fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPaginatedCustomers() {
    if (filteredCustomers.isEmpty) return [];

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, filteredCustomers.length);

    if (startIndex >= filteredCustomers.length) return [];

    return filteredCustomers.sublist(startIndex, endIndex);
  }

  // Calculate total pages based on filtered customers
  int get totalPages {
    return (filteredCustomers.length / _itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch role from the AuthProvider
    final role = Provider.of<AuthProvider>(context).role;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Admin Prepaid Tokens"),
        centerTitle: true,
      ),
      drawer: Sidebar(
        role: role,
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('No customers found.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No customers found.'));
          } else {
            customers = snapshot.data!;
            _filterCustomers(); // Filter customers after fetching data

            if (filteredCustomers.isEmpty) {
              return const Center(
                  child: Text('No customers with tokens found.'));
            }

            final paginatedCustomers = _getPaginatedCustomers();
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: paginatedCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = paginatedCustomers[index];
                      final token = (customer['PrepaidTokens'] != null &&
                              customer['PrepaidTokens'].isNotEmpty)
                          ? customer['PrepaidTokens'].last
                          : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Card(
                          color: Color(0xFFFCFCF7),
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Customer Name
                                Text(
                                  customer['Name'] ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Customer ID
                                _buildRow("Customer ID:",
                                    customer['CustomerID'].toString()),

                                // Active Serial Number
                                _buildRow(
                                    "Active Serial:",
                                    token != null
                                        ? "${token['serialNumberStarting']} - ${token['serialNumberEnding']}"
                                        : "N/A"),

                                // Used Tokens
                                _buildRow(
                                    "Used Tokens:",
                                    customer['UsedPrepaidTokens']
                                            ?.length
                                            .toString() ??
                                        '0'),

                                // Unused Tokens
                                _buildRow(
                                  "Unused Tokens:",
                                  ((token['numberoftokens'] ?? 0) -
                                          ((customer['UsedPrepaidTokens']
                                                  ?.length ??
                                              0)))
                                      .toString(),
                                ),

                                // Token Book Price
                                _buildRow("Token Book Price:",
                                    "\$${token['PricePerBook'].toString()}"),

                                // Price Per Book
                                _buildRow("Price Per Book:",
                                    "\$${customer['PricePerBook'].toString()}"),

                                SizedBox(height: 18),

// Inside the Row widget where the action buttons are defined
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing:
                                      2, // Horizontal spacing between buttons
                                  runSpacing:
                                      8, // Vertical spacing when wrapping to a new line
                                  children: [
                                    // Used Button

                                    // Edit Button
                                    SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          onPrimary: Colors.orange,
                                          elevation: 5,
                                          shadowColor: Colors.orangeAccent
                                              .withOpacity(1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        onPressed: () async {
                                          if (customer['PrepaidTokens'] !=
                                                  null &&
                                              customer['PrepaidTokens']
                                                  .isNotEmpty) {
                                            final result = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return PrepaidTokenModal(
                                                  isEditing: true,
                                                  customerId:
                                                      customer['CustomerID']
                                                          .toString(),
                                                  customerData: customer,
                                                );
                                              },
                                            );
                                            if (result == true) {
                                              _fetchCustomers();
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "No prepaid tokens found.")),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.edit, size: 18),
                                        label: Text(
                                          'Edit',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.blue,
                                          elevation: 5,
                                          shadowColor:
                                              Colors.blueAccent.withOpacity(1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        onPressed: () async {
                                          if (customer['UsedPrepaidTokens'] !=
                                                  null &&
                                              customer['UsedPrepaidTokens']
                                                  .isNotEmpty) {
                                            _showUsedTokensDialog(
                                                List<Map<String, dynamic>>.from(
                                                    customer[
                                                        'UsedPrepaidTokens']));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "No used tokens found.")),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.visibility, size: 18),
                                        label: Text(
                                          'Used',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 5),

                                    // Prepaid Button
                                    SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          onPrimary: Colors.red,
                                          elevation: 5,
                                          shadowColor:
                                              Colors.redAccent.withOpacity(1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        onPressed: () {
                                          if (customer['PrepaidTokens'] !=
                                                  null &&
                                              customer['PrepaidTokens']
                                                  .isNotEmpty) {
                                            _showPrepaidTokensDialog(
                                                List<Map<String, dynamic>>.from(
                                                    customer['PrepaidTokens']));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "No prepaid tokens found.")),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.visibility, size: 18),
                                        label: Text(
                                          'Prepaid',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),

                                    // Unused Button
                                    SizedBox(
                                      width: 80,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          onPrimary: Colors.green,
                                          elevation: 5,
                                          shadowColor:
                                              Colors.greenAccent.withOpacity(1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        onPressed: () async {
                                          if (customer['PrepaidTokens'] !=
                                                  null &&
                                              customer['PrepaidTokens']
                                                  .isNotEmpty) {
                                            _showUnusedTokensDialog(
                                                customer['PrepaidTokens'].last);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "No prepaid tokens found.")),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.visibility, size: 18),
                                        label: Text(
                                          'Unused',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                // Move to the previous chunk of pages (e.g., 0-4 to 5-9)
                                if (_currentPage % 5 == 0) {
                                  _currentPage -= 5;
                                } else {
                                  _currentPage--;
                                }
                              });
                            }
                          : null, // Disable if on the first page
                    ),

                    // Scrollable List of Page Numbers
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Calculate the total pages based on filtered or all data
                          Builder(
                            builder: (context) {
                              int totalPages =
                                  (((filteredCustomers.length) - 1) /
                                          _itemsPerPage)
                                      .ceil();

                              // Calculate remaining pages
                              int remainingPages = totalPages - _currentPage;

                              // Determine the chunk size (5 pages at a time, but adjust for remaining pages)
                              int chunkSize =
                                  remainingPages < 5 ? remainingPages : 5;

                              // Generate the visible pages (show pages in chunks of 5 or remaining pages)
                              return Row(
                                children: List.generate(
                                  chunkSize,
                                  (index) {
                                    // Determine which page to show based on the current chunk
                                    int pageToShow = _currentPage + index;

                                    // Ensure the page number is within the valid range
                                    if (pageToShow < totalPages) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _currentPage = pageToShow;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              color: _currentPage == pageToShow
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color:
                                                    _currentPage == pageToShow
                                                        ? Colors.blue
                                                        : Colors.grey
                                                            .withOpacity(0.5),
                                              ),
                                            ),
                                            child: Text(
                                              (pageToShow + 1).toString(),
                                              style: TextStyle(
                                                color:
                                                    _currentPage == pageToShow
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(); // Skip out-of-range pages
                                  },
                                ).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Forward Button
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage <
                              (((filteredCustomers.length) - 1) / _itemsPerPage)
                                      .ceil() -
                                  1
                          ? () {
                              setState(() {
                                // Move to the next chunk of pages (e.g., 5-9 to 10-14)
                                if ((_currentPage + 1) % 5 == 0) {
                                  _currentPage += 5;
                                } else {
                                  _currentPage++;
                                }
                              });
                            }
                          : null, // Disable if on the last page
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
      floatingActionButton: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 30), // Adjust for upward movement
          child: FloatingActionButton(
            tooltip: 'Add New Token',
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PrepaidTokenModal(
                    isEditing: false,
                    customerId: '',
                  );
                },
              );
              if (result == true) {
                _fetchCustomers();
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
