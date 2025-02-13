import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/super_admin_widget/add_edit_deliveryboy_modal.dart';

class DeliveryboyScreen extends StatefulWidget {
   final String role;
  const DeliveryboyScreen({Key? key,required this.role}) : super(key: key);



  @override
  _DeliveryboyScreenState createState() =>
      _DeliveryboyScreenState();
}

class _DeliveryboyScreenState
    extends State<DeliveryboyScreen> {
  late Future<List<Map<String, dynamic>>> _deliveryboysFuture;
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> deliveryboys = [];
  int _currentPage = 0; // Track the current page
  final int _itemsPerPage = 4; // Number of items per page

final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';
List<Map<String, dynamic>> filteredDeliveryboys = [];

  @override
  void initState() {
    super.initState();
    _fetchDeliveryboy();
  }

  // void _fetchDeliveryboy() {
  //   setState(() {
  //     _deliveryboysFuture = _authService.fetchDeliveryBoys();
  //   });
  // }
  void _fetchDeliveryboy() {
  setState(() {
    _deliveryboysFuture = _authService.fetchDeliveryBoys().then((data) {
      // Reverse the list to show the newest delivery boy first
      deliveryboys = data.reversed.toList();
      return deliveryboys;
    });
  });
}


  String formatPhoneNumber(String phone) {
  // Remove any non-digit characters
  phone = phone.replaceAll(RegExp(r'\D'), '');
  // Format the phone number to "0300-0000000"
  if (phone.length == 11) {
    return '${phone.substring(0, 4)}-${phone.substring(4)}';
  }
  return phone; // Return as is if it's not in the correct format
}

String _formatCnic(String cnic) {
  if (cnic.length == 13) {
    return '${cnic.substring(0, 5)}-${cnic.substring(5, 11)}-${cnic.substring(11, 13)}';
  }
  return 'Invalid CNIC';  // Return a default or error message if the CNIC is not valid
}


void _filterDeliveryboys(String query) {
  setState(() {
    _searchQuery = query.toLowerCase();
    filteredDeliveryboys = deliveryboys.where((deliveryboy) {
      final name = deliveryboy['Name']?.toString().toLowerCase() ?? '';
      final email = deliveryboy['Email']?.toString().toLowerCase() ?? '';
      final phone = deliveryboy['Phone']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          phone.contains(_searchQuery);
    }).toList();
    _currentPage = 0; // Reset to first page when search changes
  });
}
  // List<Map<String, dynamic>> _getPaginatedDeliveryBoys() {
  //   final startIndex = _currentPage * _itemsPerPage;
  //   final endIndex = startIndex + _itemsPerPage;
  //   return deliveryboys.sublist(
  //     startIndex,
  //     endIndex > deliveryboys.length ? deliveryboys.length : endIndex,
  //   );
  // }
  List<Map<String, dynamic>> _getPaginatedDeliveryBoys() {
  final listToUse = _searchQuery.isEmpty ? deliveryboys : filteredDeliveryboys;
  final startIndex = _currentPage * _itemsPerPage;
  final endIndex = startIndex + _itemsPerPage;
  return listToUse.sublist(
    startIndex,
    endIndex > listToUse.length ? listToUse.length : endIndex,
  );
}


int get totalPages {
  final listToUse = _searchQuery.isEmpty ? deliveryboys : filteredDeliveryboys;
  return (listToUse.length / _itemsPerPage).ceil();
}

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).role;
    final totalItems = _searchQuery.isEmpty 
    ? deliveryboys.length 
    : filteredDeliveryboys.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == 'super-admin' ? 'Super Admin Deliveryboy' : 'Admin Deliveryboy'),
        centerTitle: true,
      ),
      drawer: Sidebar(
        role: role,
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },
      ),


      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _deliveryboysFuture,
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
            return const Center(child: Text('No delivery boys found.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No delivery boys found.'));
          } else {
            deliveryboys = snapshot.data!;
            final paginatedDeliveryboys = _getPaginatedDeliveryBoys();
            return Column(
              children: [


                Padding(
  padding: const EdgeInsets.all(12.0),
  child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Search by name, email, or phone...',
      prefixIcon: Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    onChanged: _filterDeliveryboys,
  ),
),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),





                    
                    
                    itemCount: _getPaginatedDeliveryBoys().length,
                    itemBuilder: (context, index) {
                    
                       final deliveryboy = _getPaginatedDeliveryBoys()[index];


                      bool shouldHideDeleteButton = widget.role == 'admin';

                      return Container(
                        
  margin: const EdgeInsets.only(bottom: 10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border(
      top: BorderSide(color: Colors.black, width: 1),  // Normal border on top
      left: BorderSide(color: Colors.black, width: 1), // Normal border on left
      right: BorderSide(color: Colors.black, width: 3), // Thicker border on the right for 3D effect
      bottom: BorderSide(color: Colors.black, width: 3), // Thicker border on the bottom for 3D effect
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(3, 3), // Shadow on bottom right
      ),
    ],
  ),

  
  child:Card(
  color:  Color(0xFFFCFCF7),
  margin: EdgeInsets.zero, // No additional margin here as we handle it in the outer container
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  elevation: 0, // We don't need the card's internal shadow since we are using BoxShadow
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile icon and Name
        Row(
          children: [
          
            SizedBox(width: 12),
            Expanded(
              child: Text(
                deliveryboy['Name'] ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8), // Space after profile section

        // Customer details with key-value pairs on the same line
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "Email: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    deliveryboy['Email'] ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
            SizedBox(height: 4),


            

            // Phone
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "Phone: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    formatPhoneNumber(deliveryboy['Phone'].toString() ?? 'N/A'),
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
           ),
            SizedBox(height: 4),

            // Remaining Balance
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "CNIC: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    deliveryboy['CNIC'].toString() ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
                  ),
            SizedBox(height: 4),

            //
            //// Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child: Row(
              children: [
                Text(
                  "Assigned Area: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    deliveryboy['AssignedArea'].toString()?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
                  ),
            SizedBox(height: 10),

            // Price Per Liter
           
             // Add space before buttons
          ],
        ),





        // Action Buttons (Edit and Delete)
   Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // Edit Button
    SizedBox(
      width: 100,
      height: 40, // Set width for the button
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.white, // Button background color
          onPrimary: Colors.blue, // Text and icon color
          elevation: 5, // Add shadow
          shadowColor: Colors.blueAccent.withOpacity(1), // Shadow color with opacity
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          //side: BorderSide(color: Colors.blueAccent, width: 1), // Border style
          padding: const EdgeInsets.symmetric(vertical: 12), // Padding inside the button
        ),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return DeliveryboyModal(
                isEditing: true,
                deliveryboy: deliveryboy,
                deliveryboyId: deliveryboy['DeliveryBoyID'].toString(),
              );
            },
          );
          if (result == true) {
            _fetchDeliveryboy();
          }
        },
        icon: Icon(Icons.edit, size: 18), // Icon for the button
        label: Text(
          'Edit',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const SizedBox(width: 20), // Space between buttons

    // Delete Button
                                      if (!shouldHideDeleteButton)
    SizedBox(
      width: 100,
      height: 40, // Set width for the button
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.white, // Button background color
          onPrimary: Colors.red, // Text and icon color
          elevation: 5, // Add shadow
          shadowColor: Colors.redAccent.withOpacity(1), // Shadow color with opacity
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          //side: BorderSide(color: Colors.redAccent, width: 1), // Border style
          padding: const EdgeInsets.symmetric(vertical: 12), // Padding inside the button
        ),
        onPressed: () async {
          final bool? confirmDelete = await _showDeleteConfirmationDialog(context);
          if (confirmDelete == true) {
            final deliveryboyId = deliveryboy['DeliveryBoyID'].toString();
            final success = await AuthService().deleteDeliveryboy(deliveryboyId);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery Boy deleted successfully'),
                ),
              );
              _fetchDeliveryboy();

              
                 // Remove the deleted admin from both lists and update state
      setState(() {
        deliveryboys.removeWhere((element) => element['DeliveryBoyID'].toString() == deliveryboyId);
        filteredDeliveryboys.removeWhere((element) => element['DeliveryBoyID'].toString() == deliveryboyId);
      });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to delete Delivery Boy'),
                ),
              );
            }
          }
        },
        icon: Icon(Icons.delete, size: 18), // Icon for the button
        label: Text(
          'Delete',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ],
),



      ],
    ),
  ),
)



);


                    },
                  ),
                ),
                // Pagination Controls
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
              int totalPages = (((_searchQuery.isEmpty ? deliveryboys.length : filteredDeliveryboys.length) - 1) / _itemsPerPage).ceil();
              
              // Calculate remaining pages
              int remainingPages = totalPages - _currentPage;

              // Determine the chunk size (5 pages at a time, but adjust for remaining pages)
              int chunkSize = remainingPages < 5 ? remainingPages : 5;

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
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentPage = pageToShow;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: _currentPage == pageToShow
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: _currentPage == pageToShow
                                    ? Colors.blue
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              (pageToShow + 1).toString(),
                              style: TextStyle(
                                color: _currentPage == pageToShow
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
              (((_searchQuery.isEmpty ? deliveryboys.length : filteredDeliveryboys.length) - 1) / _itemsPerPage)
                  .ceil() - 1
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




// Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [

    
//     IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: _currentPage > 0
//           ? () => setState(() => _currentPage--)
//           : null,
//     ),
//     SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: List.generate(
//           ((totalItems - 1) / _itemsPerPage + 1).ceil(),
//           (index) => GestureDetector(
//             onTap: () => setState(() => _currentPage = index),
//             child: Container(
//               padding: EdgeInsets.all(8),
//               margin: EdgeInsets.symmetric(horizontal: 4),
//               decoration: BoxDecoration(
//                 color: _currentPage == index 
//                     ? Colors.blue 
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 '${index + 1}',
//                 style: TextStyle(
//                   color: _currentPage == index 
//                       ? Colors.white 
//                       : Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//     IconButton(
//       icon: const Icon(Icons.arrow_forward),
//       onPressed: _currentPage < ((totalItems - 1) ~/ _itemsPerPage)
//           ? () => setState(() => _currentPage++)
//           : null,
//     ),
//   ],
// )
              ],
            );
          }
        },
      ),
      


         
 floatingActionButton: SafeArea(
  child: Padding(
    padding: const EdgeInsets.only(bottom: 30), // Adjust for upward movement
    child: FloatingActionButton(
      tooltip: 'Add New Delivery Boy',
      onPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeliveryboyModal(isEditing: false);
          },
        );
        if (result == true) {
          _fetchDeliveryboy();
        }
      },
      child: const Icon(Icons.add),
    ),
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete this delivery boy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
