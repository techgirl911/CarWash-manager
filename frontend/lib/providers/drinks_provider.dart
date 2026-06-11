import 'package:flutter/material.dart';

class DrinksProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _drinks = [];
  List<Map<String, dynamic>> _lowStock = [];

  List<Map<String, dynamic>> get drinks => _drinks;
  List<Map<String, dynamic>> get lowStock => _lowStock;

  bool get hasLowStockAlert => _lowStock.isNotEmpty;

  void setDrinks(List<Map<String, dynamic>> data) {
    _drinks = data;
    _lowStock = data
        .where((d) => (d['stock'] ?? 0) <= (d['low_stock_threshold'] ?? 5))
        .toList();
    notifyListeners();
  }

  void clear() {
    _drinks = [];
    _lowStock = [];
    notifyListeners();
  }
}
