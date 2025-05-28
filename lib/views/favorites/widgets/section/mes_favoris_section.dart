import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/favorite_service.dart';
import 'package:ui_leafguard/services/trefle_api_service.dart';

class MesFavorisSection extends StatefulWidget {
  final String? filter;
  const MesFavorisSection({super.key, this.filter});

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

  /// Détecte le changement de filtre et actualise la liste
  @override
  void didUpdateWidget(covariant MesFavorisSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _sortFavorites();
    }
  }

  /// Récupère les favoris de l'utilisateur
  Future<void> _fetchFavorites() async {
    setState(() => isLoading = true);
    final user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
      final plantIds = await favoriteService.getFavoritePlantIds(userId!);
      final futures =
      plantIds.map((plantId) => trefleApiService.fetchPlantDetails(plantId));
      final results = await Future.wait(futures);

      favoritePlants = List.generate(results.length, (i) {
        final plantDetails = results[i];
        return {
          'plant_id': plantIds[i],
          'plant_name': plantDetails?['common_name'] ?? 'Nom inconnu',
          'plant_image': plantDetails?['image_url'] ?? '',
        };
      });

      setState(() {
        isLoading = false;
      });
    }
  }

  /// Trie les favoris selon le filtre sélectionné et actualise instantanément
  void _sortFavorites() {
    if (widget.filter == null) {
      _fetchFavorites(); // 🔄 Réinitialise la liste si aucun filtre n'est sélectionné
      return;
    }

    setState(() {
      if (widget.filter == "A - Z") {
        favoritePlants.sort((a, b) => a['plant_name'].compareTo(b['plant_name']));
      } else if (widget.filter == "Z - A") {
        favoritePlants.sort((a, b) => b['plant_name'].compareTo(a['plant_name']));
      } else if (widget.filter == "Date") {
        favoritePlants.sort(
                (a, b) => (b['added_at'] ?? "").compareTo(a['added_at'] ?? ""));
      } else if (widget.filter == "ID") {
        favoritePlants.sort((a, b) => a['plant_id'].compareTo(b['plant_id']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return favoritePlants.isEmpty
        ? RefreshIndicator(
      onRefresh: _fetchFavorites,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    "Vous n'avez aucun favori.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Découvrez des plantes intéressantes dans le guide et ajoutez-les à vos favoris !",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.go('/plantsguide');
                    },
                    child: const Text(
                      "Aller au guide des plantes",
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )

        : RefreshIndicator(
      onRefresh: _fetchFavorites,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: favoritePlants.length + 1,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          if (index == favoritePlants.length) {
            return const SizedBox(height: 50);
          }

          final plant = favoritePlants[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${plant['plant_id']}"),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmer la suppression"),
                      content: Text("Souhaitez-vous retirer \"${plant['plant_name']}\" de vos favoris ?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Annuler"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await favoriteService.removeFavorite(userId!, plant['plant_id']);
                    _fetchFavorites();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
