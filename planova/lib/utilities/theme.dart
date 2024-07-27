import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  int _themeValue = 1;

  ThemeProvider() {
    _loadThemeValue();
  }

  int get themeValue => _themeValue;

  Future<void> _loadThemeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedThemeValue = prefs.getInt('themeValue');
    if (storedThemeValue != null) {
      _themeValue = storedThemeValue;
    } else {
      _themeValue = 1; // Varsayılan değeri 1 olarak ayarla
    }
    notifyListeners();
  }

  Future<void> setThemeValue(int value) async {
    _themeValue = value;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeValue', value);
  }
}
class ThemeColors {
  static CustomThemeData getTheme(int value) {
    switch (value) {
      case 2:
        return CustomThemeData(
          cardBackground: const Color.fromARGB(255, 60, 60, 60),
          activeColor: const Color.fromARGB(255, 255, 0, 0),
          todayDecorationColor: const Color.fromARGB(99, 255, 87, 34),
          activeDayDecorationColor: const Color.fromARGB(255, 255, 69, 0),
          borderColor: const Color.fromARGB(0, 0, 255, 0),
          dayNumTextColor: Colors.red,
          habitCardBackground: const Color.fromARGB(200, 79, 94, 39),
          todoCardBackground: const Color.fromARGB(120, 139, 125, 96),
          checkBoxBorderColor: const Color.fromARGB(200, 255, 198, 3),
          checkBoxActiveColor: const Color.fromARGB(150, 255, 198, 3),
        );
      case 3:
        return CustomThemeData(
          cardBackground: const Color.fromARGB(255, 20, 20, 20),
          activeColor: const Color.fromARGB(255, 0, 0, 255),
          todayDecorationColor: const Color.fromARGB(99, 34, 87, 255),
          activeDayDecorationColor: const Color.fromARGB(255, 0, 69, 255),
          borderColor: const Color.fromARGB(0, 255, 0, 255),
          dayNumTextColor: Colors.blue,
          habitCardBackground: const Color.fromARGB(200, 39, 39, 94),
          todoCardBackground: const Color.fromARGB(120, 96, 96, 139),
          checkBoxBorderColor: const Color.fromARGB(200, 3, 198, 255),
          checkBoxActiveColor: const Color.fromARGB(150, 3, 198, 255),
        );
      case 4:
        return CustomThemeData(
          cardBackground: const Color.fromARGB(255, 10, 10, 10),
          activeColor: const Color.fromARGB(200, 198, 3, 255),
          todayDecorationColor: const Color.fromARGB(200, 198, 3, 255),
          activeDayDecorationColor: const Color.fromARGB(200, 198, 3, 255),
          borderColor: const Color.fromARGB(0, 255, 255, 0),
          dayNumTextColor: const Color.fromARGB(120, 198, 3, 255),
          habitCardBackground: const Color.fromARGB(200, 94, 39, 79),
          todoCardBackground: const Color.fromARGB(120, 139, 96, 125),
          checkBoxBorderColor: const Color.fromARGB(200, 198, 3, 255),
          checkBoxActiveColor: const Color.fromARGB(60, 198, 3, 255),
        );
      case 1:
      default:
        return CustomThemeData(
          cardBackground: const Color.fromARGB(255, 30, 30, 30),
          activeColor: const Color.fromARGB(250, 3, 218, 198),
          todayDecorationColor: const Color.fromARGB(99, 43, 158, 87),
          activeDayDecorationColor: const Color.fromARGB(255, 3, 218, 182),
          borderColor: const Color.fromARGB(0, 0, 255, 242),
          dayNumTextColor: Colors.white,
          habitCardBackground: const Color.fromARGB(200, 39, 79, 94),
          todoCardBackground: const Color.fromARGB(120, 96, 125, 139),
          checkBoxBorderColor: const Color.fromARGB(150, 3, 218, 198),
          checkBoxActiveColor: const Color.fromARGB(100, 3, 218, 198),
        );
    }
  }
}

class CustomThemeData {
  final Color cardBackground;
  final Color activeColor;
  final Color todayDecorationColor;
  final Color activeDayDecorationColor;
  final Color borderColor;
  final Color dayNumTextColor;
  final Color habitCardBackground;
  final Color todoCardBackground;
  final Color checkBoxBorderColor;
  final Color checkBoxActiveColor;

  CustomThemeData({
    required this.cardBackground,
    required this.activeColor,
    required this.todayDecorationColor,
    required this.activeDayDecorationColor,
    required this.borderColor,
    required this.dayNumTextColor,
    required this.habitCardBackground,
    required this.todoCardBackground,
    required this.checkBoxBorderColor,
    required this.checkBoxActiveColor,
  });
}
