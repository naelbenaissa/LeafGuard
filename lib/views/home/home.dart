import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/home/widgets/animated_slogan.dart';
import 'package:ui_leafguard/views/widgets/dot_indicator.dart';
import 'package:ui_leafguard/views/home/widgets/section/mes_plantes_section.dart';  // Assurez-vous que le bon fichier est importé
import 'package:ui_leafguard/views/home/widgets/section/mes_taches_section.dart';
import 'appbar/home_appbar.dart';
import '../bar/custom_bottombar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<String> sloganWords = ["Scanne,", "Comprends,", "Agis !"];
  late TabController _tabController;
  bool isAuthenticated = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      isAuthenticated = session != null;
    });

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final AuthChangeEvent event = data.event;
      setState(() {
        isAuthenticated = (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed);
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 23;

    return Builder(
      builder: (context) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const HomeAppBar(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: appBarHeight),
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
                SizedBox(
                  width: 250,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(fontSize: 18),
                    tabs: const [
                      Tab(text: "Mes Plantes"),
                      Tab(text: "Mes Tâches"),
                    ],
                    labelColor: theme.primaryColor, // Utilisation du thème
                    unselectedLabelColor: theme.hintColor,
                    indicatorWeight: 0,
                    dividerHeight: 0,
                    indicator: DotIndicator(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      MesPlantesSection(), // Correction ici
                      MesTachesSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CustomBottomBar(),
          backgroundColor: theme.scaffoldBackgroundColor, // Applique le fond selon le thème
        );
      },
    );
  }
}
