class ParkingPayment {
  final String message;
  final String licensePlate;
  final DateTime entryTime;
  final DateTime exitTime;
  final double durationHours;
  final double amount;
  final String paymentStatus;

  ParkingPayment({
    required this.message,
    required this.licensePlate,
    required this.entryTime,
    required this.exitTime,
    required this.durationHours,
    required this.amount,
    required this.paymentStatus,
  });

  // Factory method to create ParkingPayment from JSON
  factory ParkingPayment.fromJson(Map<String, dynamic> json) {
    return ParkingPayment(
      message: json['message'] as String,
      licensePlate: json['license_plate'] as String,
      entryTime: DateTime.parse(json['entry_time']),
      exitTime: DateTime.parse(json['exit_time']),
      durationHours: json['duration_hours'].toDouble(),
      amount: json['amount'].toDouble(),
      paymentStatus: json['payment_status'] as String,
    );
  }
}
