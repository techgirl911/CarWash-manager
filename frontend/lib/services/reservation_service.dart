import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ReservationService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  // ── CREATE RESERVATION (customer) ──────────────────────────
  static Future<Map<String, dynamic>> createReservation({
    required String carPlate,
    required String serviceType,
    required double price,
    required DateTime reservationTime,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(Constants.reservationsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'car_plate': carPlate,
        'service_type': serviceType,
        'price': price,
        'reservation_time': reservationTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create reservation'
      };
    }
  }

  // ── GET MY RESERVATIONS (customer) ─────────────────────────
  static Future<Map<String, dynamic>> getMyReservations() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.myReservationsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'message': 'Failed to load reservations'};
    }
  }

  // ── GET ALL RESERVATIONS (admin) ───────────────────────────
  static Future<Map<String, dynamic>> getAllReservations() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.reservationsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'message': 'Failed to load reservations'};
    }
  }

  // ── GET TODAY'S COUNT ───────────────────────────────────────
  static Future<int> getTodayCount() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.todayReservationsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  // ── UPDATE STATUS (admin) ──────────────────────────────────
  static Future<Map<String, dynamic>> updateStatus({
    required int reservationId,
    required String status,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${Constants.reservationsUrl}/$reservationId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': 'Failed to update status'};
    }
  }

  // ── CANCEL RESERVATION (customer) ──────────────────────────
  static Future<Map<String, dynamic>> cancelReservation(
      int reservationId) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${Constants.reservationsUrl}/$reservationId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to cancel'
      };
    }
  }

  // ── UPDATE STATUS WITH BAY (admin) ─────────────────────────
  static Future<Map<String, dynamic>> updateStatusWithBay({
    required int reservationId,
    required String status,
    int? bayId,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${Constants.reservationsUrl}/$reservationId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status, 'bay_id': bayId}),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': 'Failed to update status'};
    }
  }
}
