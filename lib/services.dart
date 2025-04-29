import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_parking/app_constants.dart';

class ApiServices {
  final String baseUrl = 'http://192.168.0.110:8000/';

  Future<Map> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final url = Uri.parse('${baseUrl}api/accounts/register/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
          {'email': email, 'password': password, 'username': username}),
    );

    print(response.body);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up');
    }
  }

  Future<Map> login(String email, String password) async {
    final url = Uri.parse('${baseUrl}api/accounts/login/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<dynamic> getSlotAvailability() async {
    final url = Uri.parse('$baseUrl/api/parking/availability/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get slot availability');
    }
  }

  Future<Map> bookSlot({
    required String slotId,
    required String licensePlate,
    required String? startTime,
    required bool preBooking,
  }) async {
    final url = Uri.parse('$baseUrl/api/parking/allocate/');

    final body = {
      'slot_number': slotId,
      'license_plate': licensePlate,
      'is_prebooked': preBooking,
    };

    if (startTime != null  && startTime.isNotEmpty && preBooking) {
      body['start_time'] = startTime;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Token ${AppConstants.accessToken}",
      },
      body: jsonEncode(body),
    );

    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to book slot');
    }
  }

  Future<Map> registervehicle(String vehicletype, String lisenceplate) async {
    final url = Uri.parse('$baseUrl/api/parking/vehicle/');

    final Map vt = {
      'car': 3,
      'bike': 2,
      'lorry': 5,
      'van': 4,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Token ${AppConstants.accessToken}",
      },
      body: jsonEncode({
        'vehicle_type_id': vt[vehicletype.toLowerCase()],
        'license_plate': lisenceplate
      }),
    );

    print(response.body);

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        response.statusCode == 200 ||
        body['error'] == 'Vehicle already registered.') {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register vehicle');
    }
  }

  Future<Map> checkOut(String lisenceplate) async {
    final url = Uri.parse('$baseUrl/api/parking/checkout/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Token ${AppConstants.accessToken}",
      },
      body: jsonEncode({'license_plate': lisenceplate}),
    );

    print(response.body);

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        response.statusCode == 200 ||
        body['error'] == 'Vehicle already registered.') {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register vehicle');
    }
  }

  Future<Map> payment(String lisenceplate) async {
    final url = Uri.parse('$baseUrl/api/parking/payment/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Token ${AppConstants.accessToken}",
      },
      body: jsonEncode({'license_plate': lisenceplate}),
    );

    print(response.body);

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        response.statusCode == 200 ||
        body['error'] == 'Vehicle already registered.') {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register vehicle');
    }
  }
}
