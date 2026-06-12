import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class DrinksService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  // ── GET ALL DRINKS ────────────────────────────────────────
  static Future<Map<String, dynamic>> getDrinks() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(Constants.drinksUrl),
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
        'message': data['message'] ?? 'Failed to load drinks'
      };
    }
  }

  // ── ADD NEW DRINK ─────────────────────────────────────────
  static Future<Map<String, dynamic>> addDrink({
    required String name,
    required int stock,
    required double price,
    required int threshold,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(Constants.drinksUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'stock': stock,
        'unit_price': price,
        'low_stock_threshold': threshold,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to add drink'
      };
    }
  }

  // ── ADJUST STOCK (+/-) ────────────────────────────────────
  static Future<Map<String, dynamic>> adjustStock({
    required int drinkId,
    required int delta,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${Constants.drinksUrl}/$drinkId/stock'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'delta': delta}),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update stock'
      };
    }
  }
}
