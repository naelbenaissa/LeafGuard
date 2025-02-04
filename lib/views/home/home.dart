import 'package:flutter/material.dart';
import 'bar/custom_appbar.dart';
import 'bar/custom_bottombar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLightTheme = true;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isLightTheme ? ThemeData.light() : ThemeData.dark(),
      home: Scaffold(
        appBar: CustomAppBar(
          isLightTheme: isLightTheme,
          onThemeChanged: (bool value) {
            setState(() {
              isLightTheme = value;
            });
          },
        ),
        body: Center(
          child: Text(
            'Home Page',
            style: TextStyle(color: isLightTheme ? Colors.black : Colors.white),
          ),
        ),
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        bottomNavigationBar: CustomBottomBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
