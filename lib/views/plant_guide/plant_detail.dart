import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/plant_guide/appbar/plant-detail_appbar.dart';
import 'package:ui_leafguard/services/favorite_service.dart';
import 'package:ui_leafguard/views/plant_guide/widgets/build_info_card.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> plant;

  /// Constructeur de la page détail d'une plante, requiert une map contenant les informations de la plante
  const DetailPage({super.key, required this.plant});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false; // Indique si la plante est marquée comme favorite par l'utilisateur
  final SupabaseClient supabase = Supabase.instance.client; // Instance Supabase pour accéder aux services backend
  late final FavoriteService favoriteService; // Service dédié à la gestion des favoris
  String? userId; // ID utilisateur connecté, null si non connecté

  @override
  void initState() {
    super.initState();
    favoriteService = FavoriteService(supabase);
    _fetchUserId(); // Récupération de l'ID utilisateur et vérification des favoris
  }

  /// Récupère l'ID de l'utilisateur actuellement connecté via Supabase
  /// Si l'utilisateur est connecté, met à jour l'état local et vérifie si la plante est en favori
  void _fetchUserId() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.id;
      });
      _checkIfFavorite();
    }
  }

  /// Interroge le service favoris pour déterminer si la plante est déjà ajoutée aux favoris
  /// Met à jour l'état local en conséquence
  Future<void> _checkIfFavorite() async {
    if (userId == null) return; // Pas d'utilisateur connecté, pas de vérification possible
    bool favorite = await favoriteService.isFavorite(userId!, widget.plant['id']);
    setState(() {
      isFavorite = favorite;
    });
  }

  /// Bascule l'état favori de la plante :
  /// - si l'utilisateur n'est pas connecté, affiche un message d'erreur
  /// - sinon, ajoute ou supprime la plante des favoris selon l'état actuel
  /// Met à jour l'interface utilisateur après modification
  Future<void> _toggleFavorite() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vous devez être connecté pour ajouter aux favoris."),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

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
    // Détection du mode sombre pour adapter les couleurs dynamiquement
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] ?? Colors.grey : Colors.grey[700]!;
    final cardColor = isDarkMode ? Colors.grey[900] ?? Colors.black : Colors.grey[100]!;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true, // Permet à la vue de s'étendre derrière l'app bar
      appBar: const PlantDetailAppbar(), // Barre d'app personnalisée pour la page détail plante
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image principale de la plante avec coins arrondis en bas
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
                      color: isDarkMode ? Colors.grey[800] : Colors.green[200],
                      child: Icon(
                        Icons.local_florist,
                        size: 100,
                        color: isDarkMode ? Colors.green[300] : Colors.green,
                      ),
                    ),
                  ),
                ),
                // Overlay dégradé noir en haut de l'image pour améliorer la lisibilité
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bloc texte affichant nom commun et nom scientifique de la plante
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plant['common_name'] ?? "Nom inconnu",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.plant['scientific_name'] ?? "Nom scientifique inconnu",
                        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: subtitleColor),
                      ),
                    ],
                  ),
                  // Bouton favori avec icône changeant selon l'état
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.green,
                      size: 32,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Liste des informations détaillées affichées sous forme de cartes personnalisées
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  buildInfoCard(Icons.account_tree, "Famille", widget.plant['family'] ?? 'Non spécifiée', textColor, cardColor),
                  buildInfoCard(Icons.grass, "Genre", widget.plant['genus'] ?? 'Non spécifié', textColor, cardColor),
                  buildInfoCard(Icons.leaderboard, "Rang", widget.plant['rank'] ?? 'Inconnu', textColor, cardColor),
                  buildInfoCard(Icons.verified, "Statut", widget.plant['status'] ?? 'Non précisé', textColor, cardColor),
                  buildInfoCard(Icons.history, "Année de découverte", widget.plant['year']?.toString() ?? 'Inconnue', textColor, cardColor),
                  buildInfoCard(Icons.person, "Auteur", widget.plant['author'] ?? 'Non spécifié', textColor, cardColor),
                  buildInfoCard(Icons.menu_book, "Bibliographie", widget.plant['bibliography'] ?? 'Non disponible', textColor, cardColor),
                  buildInfoCard(Icons.map, "Distribution", widget.plant['distribution'] ?? 'Non disponible', textColor, cardColor),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
