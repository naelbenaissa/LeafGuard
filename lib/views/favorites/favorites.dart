import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/favorites/appbar/favorites_appbar.dart';
import 'package:ui_leafguard/views/favorites/widgets/section/mes_favoris_section.dart';
import 'package:ui_leafguard/views/favorites/widgets/section/mes_scans_sections.dart';
import '../bar/custom_bottombar.dart';
import '../widgets/dot_indicator.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFilterOptions = false;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur d'onglets avec 2 tabs
    _tabController = TabController(length: 2, vsync: this);
    // Reset du filtre sélectionné à chaque changement d'onglet
    _tabController.addListener(() {
      setState(() {
        _selectedFilter = null;
      });
    });
  }

  /// Active/désactive l'affichage des options de filtre
  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }

  /// Sélectionne ou désélectionne un filtre donné
  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = _selectedFilter == filter ? null : filter;
    });
  }

  /// Retourne la liste des widgets filtres selon l'onglet actif
  List<Widget> _getFilterOptions() {
    // Filtres différents selon l'onglet "Mes Favoris" ou "Mes Scans"
    List<String> filters = _tabController.index == 0
        ? ["Confiance", "Date"]
        : ["A - Z", "Z - A", "Date", "ID"];

    // Génère un bouton filtrage stylisé pour chaque filtre
    return filters.map((filter) {
      bool isSelected = _selectedFilter == filter;
      return GestureDetector(
        onTap: () => _selectFilter(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                filter,
                style:
                TextStyle(color: isSelected ? Colors.white : Colors.black),
              ),
              if (isSelected)
                GestureDetector(
                  onTap: () => _selectFilter(filter),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    // Libération des ressources du contrôleur d'onglets
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre d'applications personnalisée avec bouton filtre
      appBar: FavoritesAppbar(onFilterPressed: _toggleFilterOptions),
      body: Column(
        children: [
          // Titre de la page
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Gérez vos plantes favorites et vos scans",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Affiche les options de filtrage si activées
          if (_showFilterOptions)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getFilterOptions(),
              ),
            ),
          // Onglets avec indicateur personnalisé (DotIndicator)
          SizedBox(
            width: 250,
            child: TabBar(
              controller: _tabController,
              labelStyle: const TextStyle(fontSize: 18),
              tabs: const [
                Tab(text: "Mes Favoris"),
                Tab(text: "Mes Scans"),
              ],
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 0,
              dividerHeight: 0,
              indicator: DotIndicator(),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          // Affiche le contenu associé à chaque onglet
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MesFavorisSection(filter: _selectedFilter),
                MesScansSection(filter: _selectedFilter),
              ],
            ),
          ),
        ],
      ),
      // Barre de navigation personnalisée en bas
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
