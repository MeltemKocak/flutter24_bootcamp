import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  int _themeValue = 1;

  ThemeProvider() {
    _loadThemeValue();
  }

  int get themeValue => _themeValue;

  CustomThemeData get currentTheme => ThemeColors.getTheme(
      _themeValue); // Burada currentTheme getter'ını ekledik

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
            welcomeText: Color.fromARGB(255, 255, 255, 255),
            welcomeDot: Color.fromARGB(255, 200, 200, 200),
            welcomeDotActive: const Color.fromARGB(255, 3, 218, 198),
            welcomeButton: const Color.fromARGB(255, 43, 81, 94),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255, 3, 218, 198),
            borderColor: const Color.fromARGB(255, 240, 240, 240),
            appBar: const Color.fromARGB(255, 255, 255, 255),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: Color.fromARGB(255, 255, 255, 255),
            activeDayColor: Color.fromARGB(255, 3, 161, 50),
            focusDayColor: const Color.fromARGB(255, 3, 218, 198),
            toDoCardBackground: const Color.fromARGB(255, 60, 70, 80),
            toDoTitle: const Color.fromARGB(255, 255, 255, 255),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: const Color.fromARGB(255, 43, 55, 63),
            habitTitle: Color.fromARGB(255, 255, 255, 255),
            habitIcons: const Color.fromARGB(255, 200, 200, 200),
            checkBoxBorderColor: const Color.fromARGB(255, 200, 200, 200),
            checkBoxActiveColor: const Color.fromARGB(255, 3, 218, 198),
            addButton: const Color.fromARGB(255, 3, 218, 198),
            addButtonIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarBackground: const Color.fromARGB(255, 42, 42, 42),
            bottomBarActive: const Color.fromARGB(255, 3, 218, 198),
            bottomBarActiveIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: Color.fromARGB(255, 255, 255, 255),
            bottomBarText: Color.fromARGB(255, 255, 255, 255),
            habitProgress: const Color.fromARGB(255, 3, 218, 198),
            habitActiveDay: const Color.fromARGB(255, 121, 121, 121),
            habitActiveDayText: Color.fromARGB(255, 255, 255, 255),
            habitDetailEditBackground: const Color.fromARGB(255, 60, 60, 60),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 65, 75, 85),
            background: const Color.fromARGB(255, 30, 30, 30));
      case 3:
        return CustomThemeData(
            welcomeText: Color.fromARGB(255, 0, 0, 0),
            welcomeDot: Color.fromARGB(255, 50, 50, 50),
            welcomeDotActive: const Color.fromARGB(255, 121, 180, 183),
            welcomeButton: const Color.fromARGB(255, 43, 81, 94),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255, 121, 180, 183),
            borderColor: const Color.fromARGB(255, 50, 50, 50),
            appBar: const Color.fromARGB(255, 111, 168, 171),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: Color.fromARGB(255, 0, 0, 0),
            activeDayColor: Color.fromARGB(255, 83, 138, 99),
            focusDayColor: const Color.fromARGB(255, 121, 180, 183),
            toDoCardBackground: const Color.fromARGB(255,222, 223, 223),
            toDoTitle: Color.fromARGB(255, 0, 0, 0),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: const Color.fromARGB(255,222, 223, 223),
            habitTitle: Color.fromARGB(255, 0, 0, 0),
            habitIcons: Color.fromARGB(255, 0, 0, 0),
            checkBoxBorderColor: const Color.fromARGB(255, 200, 200, 200),
            checkBoxActiveColor: const Color.fromARGB(255, 38, 50, 56),
            addButton: const Color.fromARGB(255, 121, 180, 183),
            addButtonIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarBackground: const Color.fromARGB(255, 203, 213, 213),
            bottomBarActive: const Color.fromARGB(255, 121, 180, 183),
            bottomBarActiveIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarText: Color.fromARGB(255, 0, 0, 0),
            habitProgress: Color.fromARGB(255, 0, 0, 0),
            habitActiveDay: const Color.fromARGB(255, 121, 121, 121),
            habitActiveDayText: Color.fromARGB(255, 100, 100, 100),
            habitDetailEditBackground: const Color.fromARGB(255, 222, 223, 223),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 222, 223, 223),
            background: const Color.fromARGB(255,254, 251, 243));
      case 4:
        return CustomThemeData(
            welcomeText: Color.fromARGB(255, 255, 255, 255),
            welcomeDot: Color.fromARGB(255, 200, 200, 200),
            welcomeDotActive: const Color.fromARGB(255, 3, 218, 198),
            welcomeButton: Color.fromARGB(255, 59, 29, 113),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255,137, 65, 225),
            borderColor: const Color.fromARGB(255, 240, 240, 240),
            appBar: const Color.fromARGB(255, 255, 255, 255),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: Color.fromARGB(255, 255, 255, 255),
            activeDayColor: Color.fromARGB(255, 167, 116, 209),
            focusDayColor: const Color.fromARGB(255,137, 65, 225),
            toDoCardBackground: const Color.fromARGB(255, 60, 70, 80),
            toDoTitle: const Color.fromARGB(255, 255, 255, 255),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: const Color.fromARGB(255, 43, 55, 63),
            habitTitle: Color.fromARGB(255, 255, 255, 255),
            habitIcons: const Color.fromARGB(255, 200, 200, 200),
            checkBoxBorderColor: const Color.fromARGB(255, 200, 200, 200),
            checkBoxActiveColor: const Color.fromARGB(255, 38, 50, 56),
            addButton: const Color.fromARGB(255,137, 65, 225),
            addButtonIcon: Color.fromARGB(255, 255, 255, 255),
            bottomBarBackground: const Color.fromARGB(255, 31, 31, 31),
            bottomBarActive: const Color.fromARGB(255,137, 65, 225),
            bottomBarActiveIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: Color.fromARGB(255, 255, 255, 255),
            bottomBarText: Color.fromARGB(255, 255, 255, 255),
            habitProgress: Color.fromARGB(255, 255, 255, 255),
            habitActiveDay: const Color.fromARGB(255, 121, 121, 121),
            habitActiveDayText: Color.fromARGB(255, 255, 255, 255),
            habitDetailEditBackground: const Color.fromARGB(255, 60, 70, 80),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 60, 70, 80),
            background: const Color.fromARGB(255, 30, 30, 30));
      case 5:
        return CustomThemeData(
            welcomeText: Color.fromARGB(255, 255, 255, 255),
            welcomeDot: Color.fromARGB(255, 200, 200, 200),
            welcomeDotActive: const Color.fromARGB(255, 88, 167, 159),
            welcomeButton: const Color.fromARGB(255, 43, 81, 94),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255, 88, 167, 159),
            borderColor: const Color.fromARGB(255, 240, 240, 240),
            appBar: const Color.fromARGB(255, 255, 255, 255),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: Color.fromARGB(255, 255, 255, 255),
            activeDayColor: Color.fromARGB(255, 89, 144, 106),
            focusDayColor: const Color.fromARGB(255, 88, 167, 159),
            toDoCardBackground: const Color.fromARGB(255, 96, 125, 139),
            toDoTitle: const Color.fromARGB(255, 255, 255, 255),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: const Color.fromARGB(255, 96, 125, 139),
            habitTitle: Color.fromARGB(255, 255, 255, 255),
            habitIcons: const Color.fromARGB(255, 200, 200, 200),
            checkBoxBorderColor: const Color.fromARGB(255, 88, 167, 159),
            checkBoxActiveColor: const Color.fromARGB(255, 38, 50,56),
            addButton: const Color.fromARGB(255, 88, 167, 159),
            addButtonIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarBackground: const Color.fromARGB(255,42, 42, 42),
            bottomBarActive: const Color.fromARGB(255, 88, 167, 159),
            bottomBarActiveIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: Color.fromARGB(255, 255, 255, 255),
            bottomBarText: Color.fromARGB(255, 255, 255, 255),
            habitProgress: Color.fromARGB(255, 0, 0, 0),
            habitActiveDay: Color.fromARGB(255, 0, 0, 0),
            habitActiveDayText: Color.fromARGB(255, 100, 100, 100),
            habitDetailEditBackground: const Color.fromARGB(255, 96, 125, 139),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 96, 125, 139),
            background: const Color.fromARGB(255, 28, 58, 69));
      case 1:
      default:
        return CustomThemeData(
            welcomeText: Color.fromARGB(255, 0, 0, 0),
            welcomeDot: Color.fromARGB(255, 100, 100, 100),
            welcomeDotActive: const Color.fromARGB(255, 48, 143, 163),
            welcomeButton: const Color.fromARGB(255, 43, 81, 94),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255, 3, 218, 198),
            borderColor: const Color.fromARGB(255, 100, 100, 100),
            appBar: const Color.fromARGB(255, 0, 0, 0),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: Color.fromARGB(255, 255, 255, 255),
            activeDayColor: Color.fromARGB(255, 3, 161, 50),
            focusDayColor:const Color.fromARGB(255, 48, 143, 163),
            toDoCardBackground: const Color.fromARGB(255, 60, 70, 80),
            toDoTitle: const Color.fromARGB(255, 0, 0, 0),
            toDoIcons: const Color.fromARGB(255, 100, 100, 100),
            habitCardBackground: const Color.fromARGB(255, 225, 229, 234),
            habitTitle: Color.fromARGB(255, 0, 0, 0),
            habitIcons: const Color.fromARGB(255, 100, 100, 100),
            checkBoxBorderColor: const Color.fromARGB(255, 48, 143, 163),
            checkBoxActiveColor: const Color.fromARGB(255, 38, 50, 56),
            addButton: const Color.fromARGB(255, 48, 143, 163),
            addButtonIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarBackground: const Color.fromARGB(255, 197, 209, 212),
            bottomBarActive: const Color.fromARGB(255, 48, 143, 163),
            bottomBarActiveIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: Color.fromARGB(255, 0, 0, 0),
            bottomBarText: Color.fromARGB(255, 0, 0, 0),
            habitProgress: const Color.fromARGB(255, 0, 0, 0),
            habitActiveDay: Color.fromARGB(255, 150, 150, 150),
            habitActiveDayText: Color.fromARGB(255, 0, 0, 0),
            habitDetailEditBackground: const Color.fromARGB(255, 60, 60, 60),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 225, 229, 234),
            background: const Color.fromARGB(255, 243, 248, 248));
    }
  }
}

class CustomThemeData {
  //Welcome and Login in Sign up
  final Color
      welcomeText; //Welcome text, Login or Sign up, continue as guest, e posta ile devam et, @
  final Color welcomeDot;
  final Color welcomeDotActive;
  final Color
      welcomeButton; //Welcome button, continue with Email button, devam et
  final Color subText; //All Login texts
  final Color loginTextAndBorder; //Back button, şifremi unuttum, e posta border
  final Color borderColor; //Guest button, Google Button
  final Color appBar;
  final Color calenderDays;
  final Color calenderNumbers;
  final Color activeDayColor;
  final Color focusDayColor;
  final Color toDoCardBackground;
  final Color toDoTitle;
  final Color toDoIcons;
  final Color habitCardBackground;
  final Color habitTitle;
  final Color habitIcons;
  final Color checkBoxBorderColor;
  final Color checkBoxActiveColor;
  final Color addButton;
  final Color addButtonIcon;
  final Color bottomBarBackground;
  final Color bottomBarActive;
  final Color bottomBarActiveIcon;
  final Color bottomBarIcon;
  final Color bottomBarText;
  final Color habitProgress;
  final Color habitActiveDay;
  final Color habitActiveDayText;
  final Color habitDetailEditBackground;
  final Color weeklyStatsBackgroundColor;
  final Color background;

  CustomThemeData({
    required this.welcomeText,
    required this.welcomeDot,
    required this.welcomeDotActive,
    required this.welcomeButton,
    required this.subText,
    required this.loginTextAndBorder,
    required this.borderColor,
    required this.appBar,
    required this.calenderDays,
    required this.calenderNumbers,
    required this.activeDayColor,
    required this.focusDayColor,
    required this.toDoCardBackground,
    required this.toDoTitle,
    required this.toDoIcons,
    required this.habitCardBackground,
    required this.habitTitle,
    required this.habitIcons,
    required this.checkBoxBorderColor,
    required this.checkBoxActiveColor,
    required this.addButton,
    required this.addButtonIcon,
    required this.bottomBarBackground,
    required this.bottomBarActive,
    required this.bottomBarActiveIcon,
    required this.bottomBarIcon,
    required this.bottomBarText,
    required this.habitProgress,
    required this.habitActiveDay,
    required this.habitActiveDayText,
    required this.habitDetailEditBackground,
    required this.weeklyStatsBackgroundColor,
    required this.background,
  });
}
