// Model for parsing the payment details JSON
import 'package:flutter/material.dart';
import 'package:smart_parking/active_parking_provider.dart';
import 'package:smart_parking/home_screen.dart';
import 'package:smart_parking/models/active_parking.dart';
import 'package:smart_parking/models/payment_model.dart';
import 'package:smart_parking/services.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this package for QR code generation

class ParkingPaymentScreen extends StatefulWidget {
  final ParkingPayment payment;
  final ActiveParking activeParking;

  const ParkingPaymentScreen(
      {super.key, required this.payment, required this.activeParking});

  @override
  State<ParkingPaymentScreen> createState() => _ParkingPaymentScreenState();
}

class _ParkingPaymentScreenState extends State<ParkingPaymentScreen> {
  bool _isProcessing = false;

  // Format date for display without using intl package
  String _formatDateTime(DateTime dateTime) {
    // Convert to local time
    final localDateTime = dateTime.toLocal();

    // Get month name
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final String month = months[localDateTime.month - 1];

    // Get day with leading zero if needed
    final String day = localDateTime.day.toString().padLeft(2, '0');

    // Get year
    final String year = localDateTime.year.toString();

    // Get hour in 12-hour format
    int hour = localDateTime.hour;
    final String amPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final String hourString = hour.toString();

    // Get minute with leading zero
    final String minute = localDateTime.minute.toString().padLeft(2, '0');

    // Combine into formatted string
    return '$month $day, $year - $hourString:$minute $amPm';
  }

  // Process payment
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final res = await ApiServices().payment(widget.payment.licensePlate);

    ActiveParkingProvider.of(context)
        .activeParkings
        .remove(widget.activeParking);

    // Show success dialog
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      _showPaymentSuccessDialog();
    }
  }

  // Generate a unique QR code data
  String _generateQRData() {
    // Create a unique identifier for the QR code that includes:
    // - License plate
    // - Entry time
    // - Exit time
    // - Amount paid
    // - Transaction ID (we'll use a timestamp as a simple mock)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    return 'SMARTPARK:${widget.payment.licensePlate}:'
        '${widget.payment.entryTime.millisecondsSinceEpoch}:'
        '${widget.payment.exitTime.millisecondsSinceEpoch}:'
        '${widget.payment.amount}:'
        '$timestamp';
  }

  // Show success dialog with QR code
  void _showPaymentSuccessDialog() {
    final qrData = _generateQRData();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your payment has been processed successfully. Please show this QR code when exiting the parking area.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'License: ${widget.payment.licensePlate}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Exit by: ${_formatDateTime(widget.payment.exitTime)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false);
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Parking Payment'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payment_outlined,
                        color: Colors.orange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.payment.message,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${widget.payment.paymentStatus}',
                            style: TextStyle(
                              color: widget.payment.paymentStatus == 'PENDING'
                                  ? Colors.orange
                                  : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Vehicle Details
            _buildSectionHeader('Vehicle Details'),
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'License Plate',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.payment.licensePlate,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Time Details
            _buildSectionHeader('Parking Details'),
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.login,
                      'Entry Time',
                      _formatDateTime(widget.payment.entryTime),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.logout,
                      'Exit Time',
                      _formatDateTime(widget.payment.exitTime),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.timelapse,
                      'Duration',
                      '${widget.payment.durationHours} hours',
                    ),
                  ],
                ),
              ),
            ),

            // Payment Details
            _buildSectionHeader('Payment Summary'),
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Parking Fee',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'د.ك ${widget.payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'د.ك ${widget.payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Payment Button
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.credit_card),
                label: Text(
                  _isProcessing
                      ? 'Processing...'
                      : 'Pay Now - د.ك ${widget.payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Methods
            Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPaymentMethod(Icons.credit_card, 'Credit Card'),
                const SizedBox(width: 12),
                _buildPaymentMethod(Icons.account_balance_wallet, 'Wallet'),
                const SizedBox(width: 12),
                _buildPaymentMethod(Icons.phone_android, 'Mobile Pay'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(IconData icon, String name) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
