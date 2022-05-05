import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static ThemeMode themeMode = ThemeMode.dark;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) async {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('night_mode', isOn);
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.orangeAccent,
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.orangeAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: Colors.orangeAccent,
      ),
    ),
    focusColor: Colors.grey,
    scaffoldBackgroundColor: const Color(0xff000624),
    primaryColor: Colors.black,
    secondaryHeaderColor: Colors.orange,
    colorScheme: const ColorScheme.dark(
      primary: Colors.orangeAccent,
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.orangeAccent,
      unselectedLabelStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Colors.black),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.orangeAccent,
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
  );
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xfff5f5f5),
    primaryColor: Colors.white,
    secondaryHeaderColor: Colors.orange,
    colorScheme: const ColorScheme.light(
      primary: Colors.orangeAccent,
      onPrimary: Colors.black,
      onSurface: Colors.black,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.orange,
      unselectedLabelStyle: TextStyle(
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Colors.black),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.orangeAccent,
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
  );
}
