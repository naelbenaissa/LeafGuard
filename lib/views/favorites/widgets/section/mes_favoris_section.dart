import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/favorite_service.dart';
import 'package:ui_leafguard/services/trefle_api_service.dart';

class MesFavorisSection extends StatefulWidget {
  const MesFavorisSection({super.key});

  @override
  _MesFavorisSectionState createState() => _MesFavorisSectionState();
}

class _MesFavorisSectionState extends State<MesFavorisSection> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final FavoriteService favoriteService;
  late final TrefleApiService trefleApiService;
  String? userId;
  List<Map<String, dynamic>> favoritePlants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    favoriteService = FavoriteService(supabase);
    trefleApiService = TrefleApiService();
    _fetchFavorites();
  }

  /// Récupère les favoris de l'utilisateur avec les détails des plantes
  Future<void> _fetchFavorites() async {
    setState(() {
      isLoading = true;
    });

    final user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
      final plantIds = await favoriteService.getFavoritePlantIds(userId!);

      List<Map<String, dynamic>> plants = [];

      final futures = plantIds
          .map((plantId) => trefleApiService.fetchPlantDetails(plantId));
      final results = await Future.wait(futures);

      for (int i = 0; i < results.length; i++) {
        final plantDetails = results[i];
        if (plantDetails != null) {
          plants.add({
            'plant_id': plantIds[i],
            'plant_name': plantDetails['common_name'] ?? 'Nom inconnu',
            'plant_image': plantDetails['image_url'] ?? '',
          });
        }
      }

      setState(() {
        favoritePlants = plants;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return favoritePlants.isEmpty
        ? const Center(
            child: Text("Pas de favoris", style: TextStyle(fontSize: 18)))
        : ListView.builder(
            itemCount: favoritePlants.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final plant = favoritePlants[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      plant['plant_image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_florist, size: 50),
                    ),
                  ),
                  title: Text(
                    plant['plant_name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${plant['plant_id']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      await favoriteService.removeFavorite(
                          userId!, plant['plant_id']);
                      _fetchFavorites();
                    },
                  ),
                ),
              );
            },
          );
  }
}
