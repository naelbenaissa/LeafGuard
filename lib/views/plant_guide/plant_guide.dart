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
  final TrefleApiService _plantService = TrefleApiService();
  List<dynamic> plants = [];
  List<dynamic> allPlants = [];
  bool isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchAllPlants();
    _fetchPlants();
  }

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
          hasMoreData = false;
        }
      }
    } catch (e) {
      // Gestion d'erreur ici si besoin
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchPlants() async {
    _setLoading(true);

    try {
      final response = await _plantService.fetchPlants(page: _currentPage);
      final totalPlants = response['total'] ?? 0;

      if (!mounted) return;

      setState(() {
        plants = response['data'] ?? [];
        _totalPages = (totalPlants / 20).ceil();
        if (_totalPages < 1) _totalPages = 1;

        _currentPage = _currentPage.clamp(1, _totalPages);
      });
    } catch (e) {
      // Gestion d'erreur ici si besoin
    } finally {
      _setLoading(false);
    }
  }

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
  }

  void _changePage(int page) {
    if (page >= 1 && page <= _totalPages && _searchQuery.isEmpty) {
      setState(() {
        _currentPage = page.clamp(1, _totalPages);
      });
      _fetchPlants();
    }
  }

  void _setLoading(bool value) {
    if (!mounted) return;
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
        padding: const EdgeInsets.only(top: 140),
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
                  ? const Center(child: CircularProgressIndicator())
                  : plants.isEmpty
                  ? const Center(child: Text("Aucun résultat trouvé"))
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: plants.map((plant) {
                      return GestureDetector(
                        onTap: () {
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
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
                                  aspectRatio: 1, // carré
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
            if (_searchQuery.isEmpty && plants.isNotEmpty && _totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildPaginationControls(),
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
