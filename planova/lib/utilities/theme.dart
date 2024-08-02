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
            welcomeText: const Color.fromARGB(255, 255, 255, 255),
            welcomeDot: const Color.fromARGB(255, 200, 200, 200),
            welcomeDotActive: const Color.fromARGB(255, 3, 218, 198),
            welcomeButton: const Color.fromARGB(255, 43, 81, 94),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255, 3, 218, 198),
            borderColor: const Color.fromARGB(255, 240, 240, 240),
            appBar: const Color.fromARGB(255, 255, 255, 255),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: const Color.fromARGB(255, 255, 255, 255),
            activeDayColor: const Color.fromARGB(255, 3, 161, 50),
            focusDayColor: const Color.fromARGB(255, 3, 218, 198),
            toDoCardBackground: const Color.fromARGB(255, 60, 70, 80),
            toDoTitle: const Color.fromARGB(255, 255, 255, 255),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: const Color.fromARGB(255, 43, 55, 63),
            habitTitle: const Color.fromARGB(255, 255, 255, 255),
            habitIcons: const Color.fromARGB(255, 200, 200, 200),
            checkBoxBorderColor: const Color.fromARGB(255, 200, 200, 200),
            checkBoxActiveColor: const Color.fromARGB(255, 3, 218, 198),
            addButton: const Color.fromARGB(255, 3, 218, 198),
            addButtonIcon: const Color.fromARGB(255, 0, 0, 0),
            bottomBarBackground: const Color.fromARGB(255, 42, 42, 42),
            bottomBarActive: const Color.fromARGB(255, 3, 218, 198),
            bottomBarActiveIcon: const Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: const Color.fromARGB(255, 255, 255, 255),
            bottomBarText: const Color.fromARGB(255, 255, 255, 255),
            habitProgress: const Color.fromARGB(255, 3, 218, 198),
            habitActiveDay: const Color.fromARGB(255, 121, 121, 121),
            habitActiveDayText: const Color.fromARGB(255, 255, 255, 255),
            habitDetailEditBackground: const Color.fromARGB(255, 60, 60, 60),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 65, 75, 85),
            background: const Color.fromARGB(255, 30, 30, 30),
            surface: const Color.fromARGB(255, 30, 30, 30),
            monthlyInvalidDayGrid: const Color.fromARGB(255, 150, 150, 150),
            monthlyDefaultDayGrid: const Color.fromARGB(255, 100, 100, 100),
            monthlyActiveDayGrid: const Color.fromARGB(125, 48, 143, 163),
            monthlyCompleteDayGrid: const Color.fromARGB(255, 48, 143, 163),
            monthlyActiveFriendDayGrid: const Color.fromARGB(125, 48, 143, 163),
            monthlyFriendCompleteDayGrid:
                const Color.fromARGB(255, 150, 150, 150),
            monthlyFriendUncompleteDayGrid:
                const Color.fromARGB(255, 200, 200, 200));
      case 3:
        return CustomThemeData(
            welcomeText: const Color.fromARGB(255, 50, 50, 50),
            welcomeDot: const Color.fromARGB(255, 153, 153, 153),
            welcomeDotActive: const Color.fromARGB(255, 153, 204, 204),
            welcomeButton: const Color.fromARGB(255, 121, 180, 183),
            subText: const Color.fromARGB(255, 120, 120, 120),
            loginTextAndBorder: const Color.fromARGB(255, 153, 204, 204),
            borderColor: const Color.fromARGB(255, 153, 153, 153),
            appBar: const Color.fromARGB(255, 111, 168, 171),
            calenderDays: const Color.fromARGB(255, 170, 170, 170),
            calenderNumbers: const Color.fromARGB(255, 0, 0, 0),
            activeDayColor: const Color.fromARGB(255, 144, 238, 144),
            focusDayColor: const Color.fromARGB(255, 121, 180, 183),
            toDoCardBackground: const Color.fromARGB(255, 232, 234, 237),
            toDoTitle: const Color.fromARGB(255, 50, 50, 50),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: const Color.fromARGB(255, 222, 228, 231),
            habitTitle: const Color.fromARGB(255, 50, 50, 50),
            habitIcons: const Color.fromARGB(255, 50, 50, 50),
            checkBoxBorderColor: const Color.fromARGB(255, 200, 200, 200),
            checkBoxActiveColor: const Color.fromARGB(255, 121, 180, 183),
            addButton: const Color.fromARGB(255, 153, 204, 204),
            addButtonIcon: const Color.fromARGB(255, 50, 50, 50),
            bottomBarBackground: const Color.fromARGB(255, 213, 223, 223),
            bottomBarActive: const Color.fromARGB(255, 121, 180, 183),
            bottomBarActiveIcon: const Color.fromARGB(255, 50, 50, 50),
            bottomBarIcon: const Color.fromARGB(255, 50, 50, 50),
            bottomBarText: const Color.fromARGB(255, 50, 50, 50),
            habitProgress: const Color.fromARGB(255, 153, 204, 204),
            habitActiveDay: const Color.fromARGB(255, 211, 216, 220),
            habitActiveDayText: const Color.fromARGB(255, 100, 100, 100),
            habitDetailEditBackground: const Color.fromARGB(255, 234, 234, 234),
            weeklyStatsBackgroundColor:
                const Color.fromARGB(255, 232, 234, 237),
            background: const Color.fromARGB(255, 248, 244, 239),
            surface: const Color.fromARGB(255, 248, 244, 239),
            monthlyInvalidDayGrid: const Color.fromARGB(255, 204, 204, 204),
            monthlyDefaultDayGrid: const Color.fromARGB(255, 153, 153, 153),
            monthlyActiveDayGrid: const Color.fromARGB(125, 153, 204, 204),
            monthlyCompleteDayGrid: const Color.fromARGB(255, 153, 204, 204),
            monthlyActiveFriendDayGrid:
                const Color.fromARGB(125, 153, 204, 204),
            monthlyFriendCompleteDayGrid:
                const Color.fromARGB(255, 153, 153, 153),
            monthlyFriendUncompleteDayGrid:
                const Color.fromARGB(255, 200, 200, 200));

      case 4:
        return CustomThemeData(
            welcomeText: const Color.fromARGB(255, 255, 255, 255),
            welcomeDot: const Color.fromARGB(255, 200, 200, 200),
            welcomeDotActive: const Color.fromARGB(255, 102, 48, 168),
            welcomeButton: const Color.fromARGB(255, 49, 24, 94),
            subText: const Color.fromARGB(255, 121, 121, 121),
            loginTextAndBorder: const Color.fromARGB(255, 112, 53, 180),
            borderColor: const Color.fromARGB(255, 240, 240, 240),
            appBar: const Color.fromARGB(255, 255, 255, 255),
            calenderDays: const Color.fromARGB(255, 121, 121, 121),
            calenderNumbers: const Color.fromARGB(255, 255, 255, 255),
            activeDayColor: const Color.fromARGB(255, 134, 93, 171),
            focusDayColor: const Color.fromARGB(255, 112, 53, 180),
            toDoCardBackground: Color.fromARGB(255, 48, 44,
                56), // Değiştirildi ve daha okunabilir hale getirildi
            toDoTitle: const Color.fromARGB(255, 255, 255, 255),
            toDoIcons: const Color.fromARGB(255, 200, 200, 200),
            habitCardBackground: Color.fromARGB(255, 54, 43, 63),
            habitTitle: const Color.fromARGB(255, 255, 255, 255),
            habitIcons: const Color.fromARGB(255, 200, 200, 200),
            checkBoxBorderColor: const Color.fromARGB(255, 200, 200, 200),
            checkBoxActiveColor: const Color.fromARGB(255, 102, 48, 168),
            addButton: const Color.fromARGB(255, 112, 53, 180),
            addButtonIcon: const Color.fromARGB(255, 255, 255, 255),
            bottomBarBackground: const Color.fromARGB(255, 31, 31, 31),
            bottomBarActive: const Color.fromARGB(255, 112, 53, 180),
            bottomBarActiveIcon: const Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: const Color.fromARGB(255, 255, 255, 255),
            bottomBarText: const Color.fromARGB(255, 255, 255, 255),
            habitProgress: const Color.fromARGB(255, 102, 48, 168),
            habitActiveDay: const Color.fromARGB(255, 121, 121, 121),
            habitActiveDayText: const Color.fromARGB(255, 255, 255, 255),
            habitDetailEditBackground: const Color.fromARGB(255, 60, 70, 80),
            weeklyStatsBackgroundColor: const Color.fromARGB(255, 60, 70, 80),
            background: const Color.fromARGB(255, 30, 30, 30),
            surface: const Color.fromARGB(255, 30, 30, 30),
            monthlyInvalidDayGrid: const Color.fromARGB(255, 150, 150, 150),
            monthlyDefaultDayGrid: const Color.fromARGB(255, 100, 100, 100),
            monthlyActiveDayGrid: const Color.fromARGB(125, 102, 48, 168),
            monthlyCompleteDayGrid: const Color.fromARGB(255, 102, 48, 168),
            monthlyActiveFriendDayGrid: const Color.fromARGB(125, 102, 48, 168),
            monthlyFriendCompleteDayGrid:
                const Color.fromARGB(255, 150, 150, 150),
            monthlyFriendUncompleteDayGrid:
                const Color.fromARGB(255, 200, 200, 200));
      case 1:
      default:
        return CustomThemeData(
            welcomeText: const Color.fromARGB(255, 0, 0, 0),
            welcomeDot: const Color.fromARGB(255, 100, 100, 100),
            welcomeDotActive: const Color.fromARGB(255, 48, 143, 163),
            welcomeButton: const Color.fromARGB(255, 48, 143, 163),
            subText: const Color.fromARGB(255, 70, 70, 70),
            loginTextAndBorder: const Color.fromARGB(255, 48, 143, 163),
            borderColor: const Color.fromARGB(255, 80, 80, 80),
            appBar: const Color.fromARGB(255, 0, 0, 0),
            calenderDays: const Color.fromARGB(255, 20, 20, 20),
            calenderNumbers: const Color.fromARGB(255, 40, 40, 40),
            activeDayColor: const Color.fromARGB(255, 3, 161, 50),
            focusDayColor: const Color.fromARGB(255, 48, 143, 163),
            toDoCardBackground: const Color.fromARGB(255, 230, 234, 239),
            toDoTitle: const Color.fromARGB(255, 0, 0, 0),
            toDoIcons: const Color.fromARGB(255, 100, 100, 100),
            habitCardBackground: Color.fromARGB(255, 204, 227, 231),
            habitTitle: const Color.fromARGB(255, 0, 0, 0),
            habitIcons: const Color.fromARGB(255, 100, 100, 100),
            checkBoxBorderColor: Color.fromARGB(255, 100, 100, 100),
            checkBoxActiveColor: const Color.fromARGB(255, 48, 143, 163),
            addButton: const Color.fromARGB(255, 48, 143, 163),
            addButtonIcon: const Color.fromARGB(255, 0, 0, 0),
            bottomBarBackground: const Color.fromARGB(255, 197, 209, 212),
            bottomBarActive: const Color.fromARGB(255, 48, 143, 163),
            bottomBarActiveIcon: const Color.fromARGB(255, 0, 0, 0),
            bottomBarIcon: const Color.fromARGB(255, 0, 0, 0),
            bottomBarText: const Color.fromARGB(255, 0, 0, 0),
            habitProgress: const Color.fromARGB(255, 48, 143, 163),
            habitActiveDay: const Color.fromARGB(255, 212, 216, 220),
            habitActiveDayText: const Color.fromARGB(255, 50, 50, 50),
            habitDetailEditBackground: const Color.fromARGB(255, 200, 200, 200),
            weeklyStatsBackgroundColor:
                const Color.fromARGB(255, 225, 229, 234),
            background: const Color.fromARGB(255, 243, 248, 248),
            surface: const Color.fromARGB(255, 243, 248, 248),
            monthlyInvalidDayGrid: const Color.fromARGB(255, 200, 200, 200),
            monthlyDefaultDayGrid: const Color.fromARGB(255, 125, 125, 125),
            monthlyActiveDayGrid: const Color.fromARGB(125, 48, 143, 163),
            monthlyCompleteDayGrid: const Color.fromARGB(255, 48, 143, 163),
            monthlyActiveFriendDayGrid: const Color.fromARGB(125, 48, 143, 163),
            monthlyFriendCompleteDayGrid:
                const Color.fromARGB(255, 100, 100, 100),
            monthlyFriendUncompleteDayGrid:
                const Color.fromARGB(255, 200, 200, 200));
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
  final Color surface;

  final Color monthlyInvalidDayGrid; //geçersiz gün
  final Color monthlyDefaultDayGrid; //ayın günleri
  final Color monthlyActiveDayGrid; //görevin geçerli günleri
  final Color monthlyCompleteDayGrid; //ayın tamamlanan günleri
  final Color monthlyActiveFriendDayGrid; //ayın arkadaş ile görev olan günleri
  final Color monthlyFriendCompleteDayGrid; //arkdaşın tamamladığı görev rengi
  final Color
      monthlyFriendUncompleteDayGrid; //arkadaşın tamamlamadığı görev rengi

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
    required this.surface,
    required this.monthlyInvalidDayGrid,
    required this.monthlyDefaultDayGrid,
    required this.monthlyActiveDayGrid,
    required this.monthlyCompleteDayGrid,
    required this.monthlyActiveFriendDayGrid,
    required this.monthlyFriendCompleteDayGrid,
    required this.monthlyFriendUncompleteDayGrid,
  });
}
