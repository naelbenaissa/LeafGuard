import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/plant_guide/appbar/plantGuide_appbar.dart';
import '../../services/trefle_api_service.dart';
import '../bar/custom_bottombar.dart';
import 'widgets/pagination_controls.dart';

class PlantGuidePage extends StatefulWidget {
  const PlantGuidePage({super.key});

  @override
  _PlantGuidePageState createState() => _PlantGuidePageState();
}

class _PlantGuidePageState extends State<PlantGuidePage> {
  final TrefleApiService _plantService = TrefleApiService();
  List<dynamic> plants = []; // Plantes affichées
  List<dynamic> allPlants = []; // Toutes les plantes stockées en cache
  bool isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchAllPlants(); // Charge toutes les plantes
    _fetchPlants(); // Charge la première page
  }

  /// Charge **toutes** les plantes et les stocke en cache
  Future<void> _fetchAllPlants() async {
    print("🔍 Chargement complet des plantes...");
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
          hasMoreData = false;
        }
      }
    } catch (e) {
      print("🚨 Erreur lors du chargement des plantes: $e");
    }

    _setLoading(false);
    print("✅ Chargement terminé, total: ${allPlants.length} plantes.");
  }

  /// Charge uniquement une page de plantes pour l'affichage normal
  Future<void> _fetchPlants() async {
    print("🔍 Chargement de la page $_currentPage...");
    _setLoading(true);

    try {
      final response = await _plantService.fetchPlants(page: _currentPage);
      final totalPlants = response['total'] ?? 1;

      setState(() {
        plants = response['data'] ?? [];
        _totalPages = (totalPlants / 20).ceil();
      });
    } catch (e) {
      print("🚨 Erreur lors du chargement des plantes: $e");
    }

    _setLoading(false);
  }

  /// Filtre les plantes stockées en mémoire locale
  void _applyFilter(String query) {
    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _fetchPlants();
      } else {
        plants = allPlants.where((plant) {
          final name = plant['common_name']?.toString().toLowerCase() ?? "";
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });

    print("📂 Plantes affichées après filtrage: ${plants.length}");
  }

  void _changePage(int page) {
    if (page > 0 && page <= _totalPages && _searchQuery.isEmpty) {
      setState(() => _currentPage = page);
      _fetchPlants();
    }
  }

  void _setLoading(bool value) {
    setState(() => isLoading = value);
  }

  void _onSearchChanged(String query) {
    _applyFilter(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PlantGuideAppBar(onSearchChanged: _onSearchChanged),
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : plants.isEmpty
                  ? const Center(child: Text("Aucun résultat trouvé"))
                  : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: plants.length,
                      itemBuilder: (context, index) {
                        final plant = plants[index];

                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: plant['image_url'] != null
                                  ? Image.network(
                                plant['image_url'],
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 160,
                                height: 160,
                                color: Colors.green[100],
                                child: const Icon(
                                    Icons.local_florist,
                                    size: 50,
                                    color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              plant['common_name'] ?? "Nom inconnu",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildPaginationControls(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildPaginationControls() {
    return PaginationControls(
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageChanged: _changePage,
    );
  }
}
