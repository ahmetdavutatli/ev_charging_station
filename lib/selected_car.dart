import 'package:flutter/material.dart';

class SelectedCar with ChangeNotifier {
  int? _selectedCarIndex;
  List<Map<String, dynamic>> _userCars = [];

  int? get selectedCarIndex => _selectedCarIndex;
  List<Map<String, dynamic>> get userCars => _userCars;

  void selectCar(int? index) {
    _selectedCarIndex = index;
    notifyListeners();
  }

  void updateUserCars(List<Map<String, dynamic>> cars) {
    _userCars = cars;
    notifyListeners();
  }
}