import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Colors.green;
  static const Color accentColor = Colors.greenAccent;
  static const Color backgroundColorLight = Colors.white;
  static const Color backgroundColorDark = Colors.black;
  static const Color textColorLight = Colors.black;
  static const Color textColorDark = Colors.white;
  static const Color greyColor = Colors.grey;

  // Thème clair
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    appBarTheme: _appBarTheme(backgroundColorLight, textColorLight),
    bottomNavigationBarTheme: _bottomNavBarTheme(backgroundColorLight, textColorLight),
    textTheme: _textTheme(textColorLight),
    cardTheme: _cardTheme(Colors.white),
    buttonTheme: _buttonTheme(primaryColor),
  );

  // Thème sombre
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: _appBarTheme(backgroundColorDark, textColorDark),
    bottomNavigationBarTheme: _bottomNavBarTheme(backgroundColorDark, textColorDark),
    textTheme: _textTheme(textColorDark),
    cardTheme: _cardTheme(Colors.grey[900]!),
  );

  // 🎨 Thème AppBar
  static AppBarTheme _appBarTheme(Color bgColor, Color iconColor) {
    return AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor),
    );
  }

  // 🎨 Thème BottomNavigationBar
  static BottomNavigationBarThemeData _bottomNavBarTheme(Color bgColor, Color iconColor) {
    return BottomNavigationBarThemeData(
      backgroundColor: bgColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: greyColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }

  // 🎨 Thème Textes
  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: textColor),
      bodyMedium: TextStyle(fontSize: 16, color: textColor),
      bodySmall: TextStyle(fontSize: 14, color: greyColor),
    );
  }

  // 🎨 Thème Cartes
  static CardTheme _cardTheme(Color color) {
    return CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: color,
    );
  }

  // 🎨 Thème Boutons
  static ButtonThemeData _buttonTheme(Color color) {
    return ButtonThemeData(
      buttonColor: color,
      textTheme: ButtonTextTheme.primary,
    );
  }
}
