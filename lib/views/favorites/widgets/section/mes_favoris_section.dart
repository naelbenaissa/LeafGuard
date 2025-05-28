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
  // Client Supabase pour accéder aux services backend
  final SupabaseClient supabase = Supabase.instance.client;

  // Services pour gérer les favoris et récupérer les données plantes
  late final FavoriteService favoriteService;
  late final TrefleApiService trefleApiService;

  // Identifiant de l'utilisateur connecté
  String? userId;

  // Liste des plantes favorites récupérées
  List<Map<String, dynamic>> favoritePlants = [];

  // Indicateur d'état de chargement des données
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialisation des services
    favoriteService = FavoriteService(supabase);
    trefleApiService = TrefleApiService();

    // Chargement initial des favoris
    _fetchFavorites();
  }

  /// Détecte un changement du filtre et trie ou recharge la liste en conséquence
  @override
  void didUpdateWidget(covariant MesFavorisSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _sortFavorites();
    }
  }

  /// Récupère la liste des plantes favorites de l'utilisateur avec leurs détails
  Future<void> _fetchFavorites() async {
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;

      // Récupération des IDs des plantes favorites
      final plantIds = await favoriteService.getFavoritePlantIds(userId!);

      // Récupération asynchrone des détails de chaque plante
      final futures =
      plantIds.map((plantId) => trefleApiService.fetchPlantDetails(plantId));
      final results = await Future.wait(futures);

      // Construction de la liste avec les données reçues
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

  /// Trie la liste des favoris en fonction du filtre sélectionné
  void _sortFavorites() {
    if (widget.filter == null) {
      // Si pas de filtre, recharge la liste initiale
      _fetchFavorites();
      return;
    }

    setState(() {
      if (widget.filter == "A - Z") {
        favoritePlants.sort((a, b) => a['plant_name'].compareTo(b['plant_name']));
      } else if (widget.filter == "Z - A") {
        favoritePlants.sort((a, b) => b['plant_name'].compareTo(a['plant_name']));
      } else if (widget.filter == "Date") {
        // Tri par date d'ajout (si présente)
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
      // Affiche un loader tant que les données ne sont pas chargées
      return const Center(child: CircularProgressIndicator());
    }

    // Affichage si la liste des favoris est vide
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
                      // Navigation vers le guide des plantes
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

    // Affichage de la liste des favoris avec rafraîchissement possible
        : RefreshIndicator(
      onRefresh: _fetchFavorites,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: favoritePlants.length + 1, // Pour espacer en bas
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          if (index == favoritePlants.length) {
            // Espace vide en bas de la liste
            return const SizedBox(height: 50);
          }

          final plant = favoritePlants[index];

          return Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  // Confirmation avant suppression du favori
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmer la suppression"),
                      content: Text(
                          "Souhaitez-vous retirer \"${plant['plant_name']}\" de vos favoris ?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Annuler"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Supprimer",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    // Suppression effective et rafraîchissement de la liste
                    await favoriteService.removeFavorite(
                        userId!, plant['plant_id']);
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
