import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/home/widgets/animated_slogan.dart';
import 'package:ui_leafguard/views/home/widgets/section/mesPlantesSection.dart';
import 'package:ui_leafguard/views/home/widgets/section/mesTachesSection.dart';
import 'bar/custom_appbar.dart';
import 'bar/custom_bottombar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isLightTheme = true;
  int _selectedIndex = 0;
  final List<String> sloganWords = ["Scanne,", "Comprends,", "Agis !"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Mes Plantes"),
                  Tab(text: "Mes Tâches"),
                ],
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    mesPlantesSection(),
                    mesTachesSection(),
                  ],
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