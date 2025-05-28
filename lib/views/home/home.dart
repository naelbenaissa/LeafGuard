import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/home/widgets/animated_slogan.dart';
import 'package:ui_leafguard/views/widgets/dot_indicator.dart';
import 'package:ui_leafguard/views/home/widgets/section/mes_plantes_section.dart';
import 'package:ui_leafguard/views/home/widgets/section/mes_taches_section.dart';
import 'appbar/home_appbar.dart';
import '../bar/custom_bottombar.dart';

/// Page principale de l'application affichant un slogan animé, une image,
/// et deux onglets "Mes Plantes" et "Mes Tâches" avec gestion de l'authentification.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Liste des mots à afficher dans le slogan animé
  final List<String> sloganWords = ["Scanne,", "Comprends,", "Agis !"];

  // Contrôleur pour gérer la sélection des onglets
  late TabController _tabController;

  // Booléen indiquant si l'utilisateur est authentifié
  bool isAuthenticated = false;

  // Abonnement au flux des changements d'état d'authentification Supabase
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Initialise le contrôleur d'onglets avec 2 onglets et ce State comme ticker
    _tabController = TabController(length: 2, vsync: this);

    // Vérifie le statut d'authentification actuel et écoute les changements
    _checkAuthStatus();
  }

  /// Vérifie la session courante Supabase et s'abonne aux changements d'état d'authentification
  void _checkAuthStatus() {
    final session = Supabase.instance.client.auth.currentSession;

    // Met à jour le booléen d'authentification selon la présence d'une session active
    setState(() {
      isAuthenticated = session != null;
    });

    // Écoute les événements d'authentification (connexion/déconnexion)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return; // Protection si le widget a été démonté

      final AuthChangeEvent event = data.event;

      // Met à jour le booléen en fonction de l'événement d'authentification
      setState(() {
        isAuthenticated = (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed);
      });
    });
  }

  @override
  void dispose() {
    // Annule l'abonnement à l'écoute d'authentification pour éviter les fuites mémoire
    _authSubscription.cancel();
    // Dispose le contrôleur d'onglets
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calcul de la hauteur totale de l'appbar (barre d'état + toolbar + marge personnalisée)
    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 23;

    return Builder(
      builder: (context) {
        return Scaffold(
          extendBodyBehindAppBar: true, // Le corps s'étend derrière l'appbar transparente
          appBar: const HomeAppBar(), // Appbar personnalisée spécifique à la page d'accueil
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: appBarHeight), // Décalage pour ne pas chevaucher l'appbar
                AnimatedSlogan(sloganWords: sloganWords), // Affichage du slogan animé
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30), // Coins arrondis de l'image
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

                // Barre d'onglets personnalisée avec point d'indication
                SizedBox(
                  width: 250,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: const TextStyle(fontSize: 18),
                    tabs: const [
                      Tab(text: "Mes Plantes"),
                      Tab(text: "Mes Tâches"),
                    ],
                    labelColor: theme.primaryColor, // Couleur des onglets sélectionnés
                    unselectedLabelColor: theme.hintColor, // Couleur des onglets non sélectionnés
                    indicatorWeight: 0, // Pas de trait d'indication classique
                    dividerHeight: 0,
                    indicator: DotIndicator(), // Indicateur personnalisé (point)
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),

                // Zone affichant le contenu correspondant à l'onglet actif
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7, // Hauteur dynamique
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      MesPlantesSection(), // Section "Mes Plantes"
                      MesTachesSection(),  // Section "Mes Tâches"
                    ],
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: const CustomBottomBar(), // Barre de navigation inférieure personnalisée

          backgroundColor: theme.scaffoldBackgroundColor, // Fond selon thème
        );
      },
    );
  }
}
