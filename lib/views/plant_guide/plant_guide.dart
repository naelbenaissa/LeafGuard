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
  List<dynamic> plants = [];
  bool isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
    print("Début de _fetchPlants");
    _setLoading(true);

    try {
      final response = await _plantService.fetchPlants(page: _currentPage);
      print("Réponse API reçue");

      if (response is Map<String, dynamic>) {
        final totalPlants = response['total'] ?? 1;
        print("Nombre total de plantes: $totalPlants");

        setState(() {
          plants = response['data'] ?? [];
          _totalPages = (totalPlants / 20).ceil();
        });

        print("Nombre total de pages: $_totalPages");
      } else {
        print("Erreur: format de réponse inattendu");
      }
    } catch (e) {
      print("Exception lors du chargement des plantes: $e");
    }

    _setLoading(false);
    print("Fin de _fetchPlants");
  }

  void _changePage(int page) {
    if (page > 0 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
      _fetchPlants();
    }
  }

  void _setLoading(bool value) {
    setState(() => isLoading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PlantGuideAppBar(),
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
