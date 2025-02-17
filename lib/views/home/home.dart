import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/home/widgets/animated_slogan.dart';
import 'package:ui_leafguard/views/widgets/dotIndicator.dart';
import 'package:ui_leafguard/views/home/widgets/section/mesPlantesSection.dart';
import 'package:ui_leafguard/views/home/widgets/section/mesTachesSection.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuthStatus(); // Vérifie l'authentification aux démarrage
  }

  void _checkAuthStatus() {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      isAuthenticated = session != null;
    });

    // Écouter les changements d'état de l'authentification
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        setState(() {
          isAuthenticated = true;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          isAuthenticated = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        /// Provoque des erreurs inopinées
        // extendBodyBehindAppBar: true,
        appBar: const HomeAppBar(
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: SingleChildScrollView(
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
                SizedBox(
                  width: 250,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(fontSize: 18),
                    tabs: const [
                      Tab(text: "Mes Plantes"),
                      Tab(text: "Mes Tâches"),
                    ],
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    indicatorWeight: 0,
                    dividerHeight: 0,
                    indicator: DotIndicator(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.7,
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
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }
}
