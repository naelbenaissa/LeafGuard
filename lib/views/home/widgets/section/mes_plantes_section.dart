import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/scan_service.dart';
import 'package:go_router/go_router.dart'; // N'oublie pas cet import

// Widget principal affichant la section des plantes scannées de l'utilisateur
class MesPlantesSection extends StatefulWidget {
  final String? filter; // Filtre optionnel pour trier les scans

  const MesPlantesSection({super.key, this.filter});

  @override
  _MesScansSectionState createState() => _MesScansSectionState();
}

class _MesScansSectionState extends State<MesPlantesSection> {
  final SupabaseClient supabase = Supabase.instance.client; // Instance Supabase pour la connexion backend
  late final ScanService scanService; // Service pour récupérer les scans depuis la base de données
  List<Map<String, dynamic>> scans = []; // Liste des scans récupérés
  bool isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    scanService = ScanService(supabase); // Initialisation du service de scan
    _fetchScans(); // Chargement initial des scans
  }

  @override
  void didUpdateWidget(covariant MesPlantesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le filtre change, on trie de nouveau la liste des scans
    if (widget.filter != oldWidget.filter) {
      _sortScans();
    }
  }

  // Méthode asynchrone pour récupérer les scans utilisateur depuis la base
  Future<void> _fetchScans() async {
    setState(() => isLoading = true); // Activation du loader
    try {
      final userScans = await scanService.getScans(); // Appel au service
      if (mounted) {
        setState(() {
          scans = userScans; // Mise à jour des scans
          _sortScans(); // Tri selon le filtre actif
          isLoading = false; // Désactivation du loader
        });
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des scans : $e");
      setState(() => isLoading = false); // En cas d'erreur, désactivation du loader
    }
  }

  // Tri des scans selon le filtre : "Confiance" ou "Date"
  void _sortScans() {
    if (widget.filter == null) {
      // Si aucun filtre, on recharge les scans (peut entraîner récursivité si mal géré)
      _fetchScans();
      return;
    }

    setState(() {
      if (widget.filter == "Confiance") {
        // Tri décroissant par taux de confiance
        scans.sort(
                (a, b) => (b['confidence'] ?? 0).compareTo(a['confidence'] ?? 0));
      } else if (widget.filter == "Date") {
        // Tri décroissant par date de création
        scans.sort((a, b) {
          DateTime dateA =
              DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          DateTime dateB =
              DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Affichage d'un indicateur de chargement pendant la récupération des données
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: scans.isEmpty
      // Affichage si aucun scan n'est disponible
          ? RefreshIndicator(
        onRefresh: _fetchScans, // Permet le rafraîchissement par "pull to refresh"
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Aucun scan disponible.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Commencez à scanner vos plantes dès maintenant !",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.go('/camera'); // Navigation vers l'écran caméra
                  },
                  child: const Text(
                    "Ouvrir la caméra",
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
      )
      // Affichage de la grille des scans si la liste n'est pas vide
          : RefreshIndicator(
        onRefresh: _fetchScans, // Rafraîchissement possible par "pull to refresh"
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Deux éléments par ligne
            crossAxisSpacing: 16.0, // Espacement horizontal entre les items
            mainAxisSpacing: 16.0, // Espacement vertical entre les items
            childAspectRatio: 0.8, // Ratio largeur/hauteur des items
          ),
          itemCount: scans.length, // Nombre d'items dans la grille
          itemBuilder: (context, index) {
            final scan = scans[index];
            final int criticite = scan['criticite'] ?? 0;

            double criticiteProgress;
            Color criticiteColor;

            // Détermination de la couleur et progression du cercle selon la criticité
            switch (criticite) {
              case 0:
                criticiteProgress = 1.0;
                criticiteColor = Colors.green;
                break;
              case 1:
                criticiteProgress = 0.66;
                criticiteColor = Colors.yellow;
                break;
              case 2:
                criticiteProgress = 0.33;
                criticiteColor = Colors.orange;
                break;
              case 3:
                criticiteProgress = 0.15;
                criticiteColor = Colors.red;
                break;
              default:
                criticiteProgress = 0.0;
                criticiteColor = Colors.grey;
            }

            return Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16), // Bords arrondis sur l'image
                      child: Image.network(
                        scan['image_url'], // Affichage de l'image du scan
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 50), // Icone en cas d'erreur de chargement
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: criticiteProgress, // Progression circulaire selon criticité
                          color: criticiteColor, // Couleur du cercle
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  scan['predictions'], // Nom ou résultat de la prédiction du scan
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%", // Affichage de la confiance en %
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
