import 'package:smart_parking/models/park_level.dart';
import 'package:smart_parking/models/slots.dart';

class ParkingModel {
  final List<ParkingLevel> parkingLevels;
  final Set<String> vehicletypes;

  ParkingModel({required this.parkingLevels, required this.vehicletypes});

  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    List<ParkingLevel> levels = [];
    Set<String> vehicleTypeSet = {};

    for (var levelJson in json['levels']) {
      int levelNumber = levelJson['level_number'];
      List<Slots> availableSlots = [];
      List<Slots> bookedSlots = [];

      // Available Slots
      for (var slot in levelJson['slots']['available']) {
        availableSlots.add(Slots(
          slotId: slot['slot_id'],
          vehicleType: slot['vehicle_type'],
          isAvailable: true,
        ));
        vehicleTypeSet.add(slot['vehicle_type']);
      }

      // Occupied Slots
      for (var slot in levelJson['slots']['occupied']) {
        bookedSlots.add(Slots(
          slotId: slot['slot_id'],
          vehicleType: slot['vehicle_type'],
          isAvailable: false,
        ));
        vehicleTypeSet.add(slot['vehicle_type']);
      }

      levels.add(ParkingLevel(
        level: levelNumber,
        availableSlots: availableSlots,
        bookedSlots: bookedSlots,
      ));
    }

    return ParkingModel(
      parkingLevels: levels,
      vehicletypes: vehicleTypeSet,
    );
  }
}
