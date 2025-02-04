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
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSlogan(sloganWords: sloganWords),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Image.asset(
                      'assets/img/slogan/pepper_slogan.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        bottomNavigationBar: CustomBottomBar(
          selectedIndex: _selectedIndex,
        ),
      ),
    );
  }
}
