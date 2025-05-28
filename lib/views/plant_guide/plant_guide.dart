import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/plant_guide/appbar/plant_guide_appbar.dart';
import 'package:ui_leafguard/views/plant_guide/plant_detail.dart';
import '../../services/trefle_api_service.dart';
import '../bar/custom_bottombar.dart';
import 'widgets/pagination_controls.dart';

class PlantGuidePage extends StatefulWidget {
  const PlantGuidePage({super.key});

  @override
  _PlantGuidePageState createState() => _PlantGuidePageState();
}

class _PlantGuidePageState extends State<PlantGuidePage> {
  final TrefleApiService _plantService = TrefleApiService(); // Service d'accès à l'API Trefle
  List<dynamic> plants = []; // Liste des plantes affichées, filtrée ou paginée
  List<dynamic> allPlants = []; // Liste complète des plantes chargées pour la recherche locale
  bool isLoading = false; // Indicateur de chargement pour afficher un loader pendant les appels API
  int _currentPage = 1; // Page courante pour la pagination côté API
  int _totalPages = 1; // Nombre total de pages disponibles selon la réponse API
  String _searchQuery = ""; // Requête de recherche utilisée pour filtrer localement les plantes

  @override
  void initState() {
    super.initState();
    _fetchAllPlants(); // Chargement initial complet pour la recherche locale
    _fetchPlants(); // Chargement initial paginé pour l'affichage principal
  }

  /// Charge toutes les plantes disponibles en paginant jusqu'à épuisement des données
  /// Remplit allPlants pour permettre une recherche locale efficace
  Future<void> _fetchAllPlants() async {
    int page = 1;
    bool hasMoreData = true;
    _setLoading(true);

    try {
      allPlants.clear();
      while (hasMoreData) {
        final response = await _plantService.fetchPlants(page: page);
        final List<dynamic> newPlants = response['data'] ?? [];

        if (newPlants.isNotEmpty) {
          allPlants.addAll(newPlants);
          page++;
        } else {
          hasMoreData = false; // Plus de données à récupérer, fin de la boucle
        }
      }
    } catch (e) {
      // TODO: Gestion d'erreur (ex: affichage message utilisateur, logs)
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les plantes pour la page courante en mode pagination API
  /// Met à jour la liste plants, le total de pages, et la page courante
  Future<void> _fetchPlants() async {
    _setLoading(true);

    try {
      final response = await _plantService.fetchPlants(page: _currentPage);
      final totalPlants = response['total'] ?? 0;

      if (!mounted) return; // Vérification que le widget est toujours monté

      setState(() {
        plants = response['data'] ?? [];
        _totalPages = (totalPlants / 20).ceil(); // Calcul du nombre total de pages
        if (_totalPages < 1) _totalPages = 1; // Minimum 1 page

        _currentPage = _currentPage.clamp(1, _totalPages); // Clamp page courante dans les bornes
      });
    } catch (e) {
      // TODO: Gestion d'erreur
    } finally {
      _setLoading(false);
    }
  }

  /// Applique le filtre de recherche localement sur allPlants
  /// Si la recherche est vide, recharge la page paginée depuis l'API
  void _applyFilter(String query) {
    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _fetchPlants();
      } else {
        // Filtrage local sur le nom commun (insensible à la casse)
        plants = allPlants.where((plant) {
          final name = plant['common_name']?.toString().toLowerCase() ?? "";
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  /// Change la page affichée uniquement si la recherche est vide (pas de pagination sur filtre local)
  /// Déclenche le chargement des données pour la page demandée
  void _changePage(int page) {
    if (page >= 1 && page <= _totalPages && _searchQuery.isEmpty) {
      setState(() {
        _currentPage = page.clamp(1, _totalPages);
      });
      _fetchPlants();
    }
  }

  /// Met à jour l'état de chargement uniquement si le widget est monté
  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => isLoading = value);
  }

  /// Callback appelé à chaque changement de la zone de recherche
  /// Transmet la requête au filtre local
  void _onSearchChanged(String query) {
    _applyFilter(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PlantGuideAppBar(onSearchChanged: _onSearchChanged), // AppBar avec recherche intégrée
      body: Padding(
        padding: const EdgeInsets.only(top: 140), // Décalage pour l'appbar custom
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  "Guide des plantes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Indicateur pendant chargement
                  : plants.isEmpty
                  ? const Center(child: Text("Aucun résultat trouvé")) // Message si aucune plante
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: plants.map((plant) {
                      return GestureDetector(
                        onTap: () {
                          // Navigation vers la page détail avec la plante sélectionnée
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(plant: plant),
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1, // Image carrée
                                  child: plant['image_url'] != null
                                      ? Image.network(
                                    plant['image_url'],
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.green[200],
                                    child: const Icon(
                                      Icons.local_florist,
                                      size: 60,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  plant['common_name'] ?? "Nom inconnu",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  "ID: ${plant['id'] ?? 'Inconnu'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Affiche la pagination uniquement si pas de recherche active, plusieurs pages et au moins une plante affichée
            if (_searchQuery.isEmpty && plants.isNotEmpty && _totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildPaginationControls(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(), // Barre de navigation personnalisée
    );
  }

  /// Widget dédié aux contrôles de pagination avec gestion de changement de page
  Widget _buildPaginationControls() {
    return PaginationControls(
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageChanged: _changePage,
    );
  }
}
