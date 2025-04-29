import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_parking/active_parking_provider.dart';
import 'package:smart_parking/home_screen.dart';
import 'package:smart_parking/models/active_parking.dart';
import 'package:smart_parking/models/slots.dart';
import 'package:smart_parking/services.dart';
import 'package:smart_parking/slidable_button.dart';
import 'package:intl/intl.dart';

final Map parkingPrice = {
  'bike': 1,
  'car': 2,
  'van': 3,
  'lorry': 3,
};

class SlotBookingScreen extends StatefulWidget {
  final Slots slot;
  final int parkingLevel;

  const SlotBookingScreen({
    Key? key,
    required this.slot,
    required this.parkingLevel,
  }) : super(key: key);

  @override
  _SlotBookingScreenState createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  bool _isLoading = false;

  // Pre-booking related variables
  bool _isPreBooking = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Map for more readable vehicle type names
  final Map<String, String> _vehicleTypeNames = {
    'bike': 'Motorcycle',
    'car': 'Car',
    'van': 'Van',
    'lorry': 'Lorry/Truck'
  };

  // Map for vehicle type to icon
  final Map<String, IconData> _vehicleIcons = {
    'bike': Icons.two_wheeler,
    'car': Icons.directions_car,
    'van': Icons.airport_shuttle,
    'lorry': Icons.local_shipping,
  };

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  // Method to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
          const Duration(days: 30)), // Allow booking up to 30 days in advance
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Get the combined DateTime for the selected date and time
  DateTime _getSelectedDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  // Format date and time for display
  String _formatDateTime() {
    final DateTime dateTime = _getSelectedDateTime();
    final DateFormat formatter = DateFormat('MMM dd, yyyy - hh:mm a');
    return formatter.format(dateTime);
  }

  Future<void> _bookSlot() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 2));

        await ApiServices().registervehicle(
          widget.slot.vehicleType,
          _vehicleNumberController.text,
        );

        // Get the start time based on whether it's a pre-booking or not
        final DateTime startTime =
            _isPreBooking ? _getSelectedDateTime() : DateTime.now();

        final response = await ApiServices().bookSlot(
          slotId: widget.slot.slotId,
          licensePlate: _vehicleNumberController.text,
          preBooking: _isPreBooking,
          startTime: startTime.toIso8601String(),
        );

        if (response['message'] == "Parking allocated") {
          final activeparking = ActiveParking(
            liscensePlate: _vehicleNumberController.text,
            slot: widget.slot,
            parkingLevel: widget.parkingLevel.toString(),
            startTime: startTime,
            cost:
                parkingPrice[widget.slot.vehicleType.toLowerCase()].toString(),
            vehicleType: widget.slot.vehicleType,
          );

          ActiveParkingProvider.of(context).activeParkings.add(activeparking);

          await _showBarrierWarningDialog();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_isPreBooking
                      ? 'Pre-booking successful for ${_formatDateTime()}!'
                      : 'Booking successful!')),
            );

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false); // Return true to indicate successful booking
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _showBarrierWarningDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Automatic Barrier Warning',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Please be aware that after booking this slot, an automatic barrier will be placed in front of your vehicle.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Text(
                  'The barrier will only be lowered once your payment is complete.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'I Understand',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Parking Slot'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background design element
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.blue,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _vehicleIcons[widget.slot.vehicleType] ??
                                      Icons.directions_car,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Booking Details',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Review information below',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 30),

                            // Slot Information
                            _buildInfoRow(
                              'Parking Level',
                              'Level ${widget.parkingLevel}',
                              Icons.layers,
                            ),
                            _buildInfoRow(
                              'Slot ID',
                              widget.slot.slotId,
                              Icons.crop_square,
                            ),
                            _buildInfoRow(
                              'Vehicle Type',
                              _vehicleTypeNames[widget.slot.vehicleType] ??
                                  widget.slot.vehicleType,
                              _vehicleIcons[widget.slot.vehicleType] ??
                                  Icons.directions_car,
                            ),

                            const SizedBox(height: 20),

                            // Pre-booking Switch
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.timer,
                                                    size: 20,
                                                    color: Colors.blue),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Pre-booking',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Reserve your parking slot for a future time',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: _isPreBooking,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPreBooking = value;
                                          });
                                        },
                                        activeColor: Colors.blue,
                                      ),
                                    ],
                                  ),

                                  // Show date and time pickers if pre-booking is enabled
                                  if (_isPreBooking) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            label: Text(
                                              DateFormat('MMM dd, yyyy')
                                                  .format(_selectedDate),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () =>
                                                _selectDate(context),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(Icons.access_time),
                                            label: Text(
                                              _selectedTime.format(context),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () =>
                                                _selectTime(context),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Vehicle Number Input
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vehicle Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _vehicleNumberController,
                                    decoration: InputDecoration(
                                      labelText: 'Vehicle Number',
                                      hintText: 'e.g., ABC-1234',
                                      prefixIcon: const Icon(Icons.credit_card),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.blue, width: 2),
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    inputFormatters: [
                                      // Optional: Add formatters for specific plate formats
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[A-Za-z0-9-]')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your vehicle number';
                                      }
                                      if (value.length < 3) {
                                        return 'Vehicle number is too short';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Booking Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Booking Summary',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Duration',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      const Text(
                                        'Hourly rate (Pay as you go)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Payment Method',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      const Text(
                                        'Pay on Exit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (_isPreBooking) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Start Time',
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                        Text(
                                          _formatDateTime(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Terms and conditions text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          children: const [
                            TextSpan(
                              text: 'By booking, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Full-screen loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlidableBookingButton(
            onBookingConfirmed: () {
              _bookSlot();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
