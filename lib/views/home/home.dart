import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/home/widgets/animated_slogan.dart';
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
  final List<String> sloganWords = ["Scanne,", "Comprends,", "Agis !"];

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
        body: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10),
          child: AnimatedSlogan(sloganWords: sloganWords),
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
