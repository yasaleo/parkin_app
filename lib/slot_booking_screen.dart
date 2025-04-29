import 'package:flutter/material.dart';
import 'package:smart_parking/models/slots.dart';

class SlotBookingScreen extends StatefulWidget {
  final Slots slot;
  final int levelNumber;

  const SlotBookingScreen({
    super.key,
    required this.slot,
    required this.levelNumber,
  });

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  final TextEditingController _vehicleNumberController =
      TextEditingController();

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _bookSlot() {
    final vehicleNumber = _vehicleNumberController.text.trim();

    if (vehicleNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your vehicle number')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Slot ${widget.slot.slotId} booked for $vehicleNumber',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Book Slot'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Slot ID', slot.slotId),
                    const SizedBox(height: 10),
                    _infoRow('Vehicle Type', slot.vehicleType),
                    const SizedBox(height: 10),
                    _infoRow('Parking Level', 'Level ${widget.levelNumber}'),
                    const SizedBox(height: 10),
                    _infoRow('Availability',
                        slot.isAvailable ? 'Available' : 'Occupied'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Vehicle number input
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vehicle Number Plate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(
                hintText: 'e.g., MH12AB1234',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),

            const Spacer(),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
