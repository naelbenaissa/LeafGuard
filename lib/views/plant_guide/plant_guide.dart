import 'package:flutter/material.dart';
import '../../services/plant_service.dart';
import '../home/appbar/custom_appbar.dart';
import '../bar/custom_bottombar.dart';

class PlantGuidePage extends StatefulWidget {
  const PlantGuidePage({super.key});

  @override
  _PlantGuidePageState createState() => _PlantGuidePageState();
}

class _PlantGuidePageState extends State<PlantGuidePage> {
  final PlantService _plantService = PlantService();
  List<dynamic> plants = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchAllPlants();
  }

  Future<void> _fetchAllPlants() async {
    _setLoading(true);
    _currentPage = 1;
    _hasMore = true;
    plants = await _plantService.fetchPlants(page: _currentPage);
    _setLoading(false);
  }

  Future<void> _searchPlants() async {
    _setLoading(true);
    _currentPage = 1;
    _hasMore = true;
    plants = await _plantService.searchPlants(_searchController.text);
    _setLoading(false);
  }

  Future<void> _loadMorePlants() async {
    if (!_hasMore) return;
    _setLoading(true);
    _currentPage++;
    List<dynamic> newPlants =
        await _plantService.fetchPlants(page: _currentPage);

    if (newPlants.isEmpty) {
      _hasMore = false;
    } else {
      plants.addAll(newPlants);
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    setState(() => isLoading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(scrollController: ScrollController()),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _searchPlants(),
              decoration: InputDecoration(
                labelText: "Rechercher une plante...",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _fetchAllPlants)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : plants.isEmpty
                      ? const Center(child: Text("Aucun résultat trouvé"))
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
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
                            if (_hasMore)
                              ElevatedButton(
                                onPressed: _loadMorePlants,
                                child: const Text("Voir plus"),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
