import 'package:flutter/material.dart';
import 'package:smart_parking/active_parking_provider.dart';
import 'package:smart_parking/models/active_parking.dart';
import 'package:smart_parking/models/parking_model.dart';
import 'package:smart_parking/services.dart';
import 'package:smart_parking/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  void _testApi() async {
    final re = await ApiServices().getSlotAvailability();
    final model = ParkingModel.fromJson(re);
  }

  final List<ActiveParking> activeParkings = [];

  @override
  Widget build(BuildContext context) {
    return ActiveParkingProvider(
      activeParkings: activeParkings,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
