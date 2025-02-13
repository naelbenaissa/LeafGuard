import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/plant_guide/appbar/plantDetail_appbar.dart';
import 'package:ui_leafguard/services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> plant;

  const DetailPage({super.key, required this.plant});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;
  final SupabaseClient supabase = Supabase.instance.client;
  late final FavoriteService favoriteService;
  String? userId;

  @override
  void initState() {
    super.initState();
    favoriteService = FavoriteService(supabase);
    _fetchUserId();
  }

  /// Récupère l'ID de l'utilisateur connecté
  void _fetchUserId() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.id;
      });
      _checkIfFavorite();
    }
  }

  /// Vérifie si la plante est en favori
  Future<void> _checkIfFavorite() async {
    if (userId == null) return;
    bool favorite = await favoriteService.isFavorite(userId!, widget.plant['id']);
    setState(() {
      isFavorite = favorite;
    });
  }

  /// Ajoute ou supprime une plante des favoris
  Future<void> _toggleFavorite() async {
    if (userId == null) return;
    if (isFavorite) {
      await favoriteService.removeFavorite(userId!, widget.plant['id']);
    } else {
      await favoriteService.addFavorite(userId!, widget.plant['id']);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PlantDetailAppbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌿 Image de la plante
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.network(
                    widget.plant['image_url'] ?? '',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 350,
                      width: double.infinity,
                      color: Colors.green[200],
                      child: const Icon(Icons.local_florist, size: 100, color: Colors.green),
                    ),
                  ),
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🌱 Nom de la plante + bouton favori ❤️
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plant['common_name'] ?? "Nom inconnu",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.plant['scientific_name'] ?? "Nom scientifique inconnu",
                        style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ),

                  // ❤️ Bouton favori interactif
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 32,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📋 Cartes d'informations principales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(Icons.account_tree, "Famille", widget.plant['family'] ?? 'Non spécifiée'),
                  _buildInfoCard(Icons.grass, "Genre", widget.plant['genus'] ?? 'Non spécifié'),
                  _buildInfoCard(Icons.leaderboard, "Rang", widget.plant['rank'] ?? 'Inconnu'),
                  _buildInfoCard(Icons.verified, "Statut", widget.plant['status'] ?? 'Non précisé'),
                  _buildInfoCard(Icons.history, "Année de découverte", widget.plant['year']?.toString() ?? 'Inconnue'),
                  _buildInfoCard(Icons.person, "Auteur", widget.plant['author'] ?? 'Non spécifié'),
                  _buildInfoCard(Icons.menu_book, "Bibliographie", widget.plant['bibliography'] ?? 'Non disponible'),
                  _buildInfoCard(Icons.map, "Distribution", widget.plant['distribution'] ?? 'Non disponible'),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Widget pour afficher une carte d'information
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
