import 'package:flutter/material.dart';
import 'package:smart_parking/active_parking_provider.dart';
import 'package:smart_parking/active_parkings_screen.dart';
import 'package:smart_parking/services.dart';
import 'package:smart_parking/slobo2_sc.dart';
import '../models/parking_model.dart'; // Update this to your actual model path

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedVehicleType = 'all'; // Default filter
  final List<String> _vehicleTypes = ['all', 'bike', 'car', 'van', 'lorry'];

  final Map<String, IconData> _vehicleIcons = {
    'all': Icons.directions_transit,
    'bike': Icons.two_wheeler,
    'car': Icons.directions_car,
    'van': Icons.airport_shuttle,
    'lorry': Icons.local_shipping,
  };

  late Future<ParkingModel> _parkingFuture;

  @override
  void initState() {
    super.initState();
    _parkingFuture = ApiServices()
        .getSlotAvailability()
        .then((json) => ParkingModel.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Smart Parking'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _parkingFuture = ApiServices()
                    .getSlotAvailability()
                    .then((json) => ParkingModel.fromJson(json));
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<ParkingModel>(
        future: _parkingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading parking data: ${snapshot.error}'),
            );
          }

          final parkingModel = snapshot.data!;
          final levels = parkingModel.parkingLevels;

          return Column(
            children: [
              // Vehicle Filter
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.blue.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      'Select Vehicle Type',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: _vehicleTypes.map((type) {
                          final bool isSelected = _selectedVehicleType == type;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedVehicleType = type;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.blueAccent.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _vehicleIcons[type],
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    type[0].toUpperCase() + type.substring(1),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: levels.isEmpty
                    ? const Center(child: Text('No parking data available'))
                    : ListView.builder(
                        itemCount: levels.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          final slotsToShow = _selectedVehicleType == 'all'
                              ? level.availableSlots + level.bookedSlots
                              : level.getAvailableSlots(
                                      type: _selectedVehicleType) +
                                  level.bookedSlots
                                      .where((s) =>
                                          s.vehicleType == _selectedVehicleType)
                                      .toList();

                          final totalSlots = level.availableSlots.length +
                              level.bookedSlots.length;
                          final available = _selectedVehicleType == 'all'
                              ? level.availableSlots.length
                              : level
                                  .getAvailableSlots(type: _selectedVehicleType)
                                  .length;

                          final occupancyPercentage = totalSlots > 0
                              ? (totalSlots - available) / totalSlots
                              : 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text('L${level.level}',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                              title: Text('Level ${level.level}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: occupancyPercentage.toDouble(),
                                        backgroundColor: Colors.grey[200],
                                        color: _getProgressColor(
                                            occupancyPercentage.toDouble()),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$available/$totalSlots available',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getProgressColor(
                                          occupancyPercentage.toDouble()),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: slotsToShow.map((slot) {
                                      final isAvailable = slot.isAvailable;
                                      return InkWell(
                                        onTap: isAvailable
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SlotBookingScreen(
                                                      slot: slot,
                                                      parkingLevel: level.level,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Colors.blue.withOpacity(0.1)
                                                : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isAvailable
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _vehicleIcons[
                                                        slot.vehicleType] ??
                                                    Icons.directions_car,
                                                size: 16,
                                                color: isAvailable
                                                    ? Colors.blue
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${slot.slotId} (${slot.vehicleType})',
                                                style: TextStyle(
                                                  color: isAvailable
                                                      ? Colors.blue
                                                      : Colors.grey[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Scan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if(index == 1){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  ActiveParkingScreen(
                  activeParking: ActiveParkingProvider.of(context).activeParkings,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value < 0.5) return Colors.green;
    if (value < 0.8) return Colors.orange;
    return Colors.red;
  }
}
