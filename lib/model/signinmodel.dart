import 'package:flutter/material.dart';

class Authmodel extends ChangeNotifier {
  get isVisible => _isVisible;
  bool _isVisible = false;

  set isVisible(value) {
    _isVisible = value;
    notifyListeners();
  }

  get isValid => _isValid;
  bool _isValid = false;

  void isValidEmail(String input) {
    _isValid =
        RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$').hasMatch(input);
    notifyListeners();
  }

  set isValid(value) {
    _isValid = value;
    notifyListeners();
  }
}
