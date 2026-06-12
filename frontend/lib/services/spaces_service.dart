import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SpacesService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  // ── GET ALL BAYS ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getBays() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.spacesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load bays'
      };
    }
  }

  // ── UPDATE BAY ────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateBay({
    required int bayId,
    required String status,
    String? carPlate,
    String? serviceType,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${Constants.spacesUrl}/$bayId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
        'car_plate': carPlate,
        'service_type': serviceType,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update bay'
      };
    }
  }
}
