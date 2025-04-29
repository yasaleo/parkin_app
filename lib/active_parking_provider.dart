import 'package:flutter/material.dart';
import 'package:smart_parking/models/active_parking.dart';

class ActiveParkingProvider extends InheritedWidget {
  const ActiveParkingProvider({super.key, required super.child , required this.activeParkings});

  final List<ActiveParking> activeParkings;

  static ActiveParkingProvider of(BuildContext context) {
    final ActiveParkingProvider? result =
        context.dependOnInheritedWidgetOfExactType<ActiveParkingProvider>();
    assert(result != null, 'No ActiveParkingProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
