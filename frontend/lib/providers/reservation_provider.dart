import 'package:flutter/material.dart';

class ReservationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _reservations = [];

  List<Map<String, dynamic>> get reservations => _reservations;

  void setReservations(List<Map<String, dynamic>> data) {
    _reservations = data;
    notifyListeners();
  }

  void clear() {
    _reservations = [];
    notifyListeners();
  }
}
