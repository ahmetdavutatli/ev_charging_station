import 'package:flutter/cupertino.dart';

class UserData with ChangeNotifier {
  List<Map<String, dynamic>> _userCars = [];

  List<Map<String, dynamic>> get userCars => _userCars;

  void updateUserCars(List<Map<String, dynamic>> cars) {
    _userCars = cars;
    notifyListeners();
  }
}