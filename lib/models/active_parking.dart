import 'package:smart_parking/models/slots.dart';

class ActiveParking {
  final String liscensePlate;
  final Slots slot;
  final String parkingLevel;
  final DateTime startTime;
  final String cost;
  final String vehicleType;

  ActiveParking({
    required this.liscensePlate,
    required this.slot,
    required this.parkingLevel,
    required this.startTime,
    required this.cost,
    required this.vehicleType,
  });
}
