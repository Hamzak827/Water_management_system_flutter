import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderPreviewModal extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderPreviewModal({Key? key, required this.order}) : super(key: key);

  String _formatDate(String isoDate) {
    DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final address = order['Address'] ?? {};
    final formattedAddress =
        '${address['AddressLine'] ?? 'N/A'}, ${address['City'] ?? 'N/A'}, ${address['PostalCode'] ?? 'N/A'}, ${address['Country'] ?? 'N/A'}';

    final bottles = List<Map<String, dynamic>>.from(order['Bottles'] ?? []);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),
                  Text(
                    'Order Preview',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailRow('Customer', order['CustomerID']?['Name'] ?? 'N/A'),
                  _buildDetailRow('Address', formattedAddress),
                  _buildDetailRow('Delivery Date', _formatDate(order['DeliveryDate'] ?? '')),
                  _buildDetailRow('Collected Amount', order['TotalCollectedAmount']?.toString() ?? '0'),
                  _buildDetailRow('Collected Bottles', order['TotalCollectedBottles']?.toString() ?? '0'),
                  _buildDetailRow('Delivery Boy', order['DeliveryBoyID']?['Name'] ?? 'N/A'),
                  _buildDetailRow('Status', order['Status'] ?? 'N/A'),
                  const SizedBox(height: 16.0),
                  Text(
                    'Bottles:',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  bottles.isNotEmpty
                      ? Column(
                          children: bottles
                              .map((bottle) => _buildBottleRow(
                                    bottle['NumberOfLiters']?.toString() ?? 'N/A',
                                    bottle['NumberOfBottles']?.toString() ?? 'N/A',
                                  ))
                              .toList(),
                        )
                      : Text('No bottles added',
                          style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
          // Cross icon for closing the modal inside a circle
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                radius: 18.0,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.close, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.sourceCodePro(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.sourceCodePro(
                fontSize: 15.0,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottleRow(String liters, String bottles) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Liters: $liters',
              style: GoogleFonts.sourceCodePro(fontSize: 15.0),
            ),
          ),
          Expanded(
            child: Text(
              'Bottles: $bottles',
              style: GoogleFonts.sourceCodePro(fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}
