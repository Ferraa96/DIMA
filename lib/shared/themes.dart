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
      backgroundColor: Colors.amber,
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
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Colors.black,
    secondaryHeaderColor: Colors.orange,
    colorScheme: const ColorScheme.dark(),
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
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    secondaryHeaderColor: Colors.orange,
    colorScheme: const ColorScheme.light(),
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
