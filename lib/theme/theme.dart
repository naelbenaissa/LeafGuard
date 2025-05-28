import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales de l'application
  static const Color primaryColor = Colors.green;
  static const Color accentColor = Colors.greenAccent;
  static const Color backgroundColorLight = Colors.white;
  static const Color backgroundColorDark = Colors.black;
  static const Color textColorLight = Colors.black;
  static const Color textColorDark = Colors.white;
  static const Color greyColor = Colors.grey;

  // Thème clair de l'application
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    appBarTheme: _appBarTheme(backgroundColorLight, textColorLight),
    bottomNavigationBarTheme: _bottomNavBarTheme(backgroundColorLight, textColorLight),
    textTheme: _textTheme(textColorLight),
    cardTheme: _cardTheme(Colors.white),
    buttonTheme: _buttonTheme(primaryColor),
    tabBarTheme: _tabBarTheme(textColorLight, primaryColor),
    elevatedButtonTheme: _elevatedButtonTheme(primaryColor),
  );

  // Thème sombre basé sur ThemeData.dark() avec personnalisations
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: _appBarTheme(backgroundColorDark, textColorDark),
    bottomNavigationBarTheme: _bottomNavBarTheme(backgroundColorDark, textColorDark),
    textTheme: _textTheme(textColorDark),
    cardTheme: _cardTheme(Colors.grey[900]!),
    tabBarTheme: _tabBarTheme(textColorDark, primaryColor),
    elevatedButtonTheme: _elevatedButtonTheme(primaryColor),
  );

  // Configuration de l'AppBar
  static AppBarTheme _appBarTheme(Color bgColor, Color iconColor) {
    return AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor),
    );
  }

  // Style du BottomNavigationBar
  static BottomNavigationBarThemeData _bottomNavBarTheme(Color bgColor, Color iconColor) {
    return BottomNavigationBarThemeData(
      backgroundColor: bgColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: greyColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }

  // Définition des styles de texte
  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: textColor),
      bodyMedium: TextStyle(fontSize: 16, color: textColor),
      bodySmall: const TextStyle(fontSize: 14, color: greyColor),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
      headlineMedium: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: primaryColor),
    );
  }

  // Style des cartes (Cards)
  static CardTheme _cardTheme(Color color) {
    return CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: color,
    );
  }

  // Style général des boutons (hérité des anciens ButtonTheme)
  static ButtonThemeData _buttonTheme(Color color) {
    return ButtonThemeData(
      buttonColor: color,
      textTheme: ButtonTextTheme.primary,
    );
  }

  // Style du TabBar avec indicateur personnalisé
  static TabBarTheme _tabBarTheme(Color textColor, Color selectedColor) {
    return TabBarTheme(
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      labelColor: selectedColor,
      unselectedLabelColor: greyColor,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: selectedColor, width: 3)),
      ),
    );
  }

  // Style des ElevatedButtons avec coins arrondis et padding spécifique
  static ElevatedButtonThemeData _elevatedButtonTheme(Color color) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
    );
  }
}
