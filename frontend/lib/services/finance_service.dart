import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class FinanceService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  // ── GET HISTORY ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getHistory() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.financeUrl),
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
        'message': data['message'] ?? 'Failed to load history'
      };
    }
  }

  // ── SAVE TODAY'S ENTRY ────────────────────────────────────
  static Future<Map<String, dynamic>> saveEntry({
    required double washIncome,
    required double drinkIncome,
    required double expenses,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(Constants.financeUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'wash_income': washIncome,
        'drink_income': drinkIncome,
        'expenses': expenses,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to save entry'
      };
    }
  }

  // ── GET TODAY'S SUMMARY ───────────────────────────────────
  static Future<Map<String, dynamic>> getToday() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.todayFinanceUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'data': null};
    }
  }
}
