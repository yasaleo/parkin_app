import 'package:smart_parking/models/slots.dart';

class ParkingLevel {
  final int level;
  final List<Slots> availableSlots;
  final List<Slots> bookedSlots;

  ParkingLevel({
    required this.level,
    required this.availableSlots,
    required this.bookedSlots,
  });

  List<Slots> getAvailableSlots({String? type}) {
    if (type == null) {
      return availableSlots;
    }
    return availableSlots.where((slot) => slot.vehicleType == type).toList();
  }
}
