import 'package:flutter/material.dart';

class ChargeState extends ChangeNotifier {
  List<Map<String, dynamic>> _userCharge = [];

  List<Map<String, dynamic>> get userCharge => _userCharge;

  void updateUserCharge(List<Map<String, dynamic>> newCharge) {
    _userCharge = newCharge;
    notifyListeners();
  }
}