import 'package:flutter/material.dart';
import 'package:shop/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isSupplierTheme = false;
  
  bool get isSupplierTheme => _isSupplierTheme;
  
  ThemeData getTheme(BuildContext context) {
    if (_isSupplierTheme) {
      return SupplierTheme.lightTheme;
    } else {
      return AppTheme.lightTheme(context);
    }
  }
  
  void setSupplierTheme(bool isSupplier) {
    if (_isSupplierTheme != isSupplier) {
      _isSupplierTheme = isSupplier;
      notifyListeners();
    }
  }
  
  void switchToSupplierTheme() {
    if (!_isSupplierTheme) {
      _isSupplierTheme = true;
      notifyListeners();
    }
  }
  
  void switchToAppTheme() {
    if (_isSupplierTheme) {
      _isSupplierTheme = false;
      notifyListeners();
    }
  }
}