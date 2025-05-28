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
      return;
    }

    _setLoading(false);
  }

  Future<void> _fetchPlants() async {
    _setLoading(true);

    try {
      final response = await _plantService.fetchPlants(page: _currentPage);
      final totalPlants = response['total'] ?? 1;

      if (!mounted) return;

      setState(() {
        plants = response['data'] ?? [];
        _totalPages = (totalPlants / 20).ceil();
      });
    } catch (e) {
      return;
    }

    _setLoading(false);
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
    if (page > 0 && page <= _totalPages && _searchQuery.isEmpty) {
      setState(() => _currentPage = page);
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
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : plants.isEmpty
                  ? const Center(child: Text("Aucun résultat trouvé"))
                  : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "Guide des plantes",
                        style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(plant: plant),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: plant['image_url'] != null
                                  ? Image.network(
                                plant['image_url'],
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 180,
                                height: 180,
                                color: Colors.green[200],
                                child: const Icon(Icons.local_florist,
                                    size: 60, color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              plant['common_name'] ?? "Nom inconnu",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "ID: ${plant['id'] ?? 'Inconnu'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).brightness ==
                                    Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_searchQuery.isEmpty) _buildPaginationControls(),
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
