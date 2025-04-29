import 'package:flutter/material.dart';
import 'package:smart_parking/models/active_parking.dart';
import 'package:smart_parking/models/payment_model.dart';
import 'package:smart_parking/models/slots.dart';
import 'package:smart_parking/payment_screen.dart';
import 'package:smart_parking/services.dart';

class ActiveParkingScreen extends StatefulWidget {
  ActiveParkingScreen({super.key, required this.activeParking});

  List<ActiveParking> activeParking;

  @override
  State<ActiveParkingScreen> createState() => _ActiveParkingScreenState();
}

class _ActiveParkingScreenState extends State<ActiveParkingScreen> {
  bool _isLoading = true;
  List<ActiveParking> _activeParking = [];

  final Map<String, IconData> _vehicleIcons = {
    'bike': Icons.two_wheeler,
    'car': Icons.directions_car,
    'van': Icons.airport_shuttle,
    'lorry': Icons.local_shipping,
  };

  @override
  void initState() {
    super.initState();
    _loadActiveParking();
  }

  Future<void> _loadActiveParking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace this with your actual API call
      // This is a placeholder implementation
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _activeParking = widget.activeParking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading active parking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Active Parking'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveParking,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeParking.isEmpty
              ? _buildEmptyState()
              : _buildActiveParking(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_parking,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Parking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no active parking sessions',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Return to home screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Book Parking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveParking() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withOpacity(0.1),
          child: Column(
            children: [
              Text(
                'Your Active Parking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_activeParking.length} active sessions',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _activeParking.length,
            itemBuilder: (context, index) {
              final parking = _activeParking[index];
              return _buildParkingCard(parking);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParkingCard(ActiveParking parking) {
    // Format the start time
    final formattedTime = parking.startTime.toString();

    // Format the cost to show in dinars
    final String formattedCost =
        '${parking.cost} د.ع'; // د.ع is the symbol for Iraqi Dinar

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _vehicleIcons[parking.vehicleType] ?? Icons.directions_car,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parking.liscensePlate.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Slot ${parking.slot.slotId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.stairs, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            parking.parkingLevel,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                              _vehicleIcons[parking.vehicleType] ??
                                  Icons.directions_car,
                              size: 16,
                              color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            parking.vehicleType,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  icon: const Icon(
                    Icons.access_time,
                    color: Colors.blue,
                  ),
                  title: 'Start Time',
                  value: formattedTime,
                ),
                _buildInfoItem(
                  icon: const Text(
                    'د.ك',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: 'Cost',
                  value: formattedCost,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final res =
                      await ApiServices().checkOut(parking.liscensePlate);

                  final paymentModel =
                      ParkingPayment.fromJson((res as Map<String, dynamic>));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkingPaymentScreen(
                        payment: paymentModel,
                        activeParking: parking,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Check Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required Widget icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          icon,
          // Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
