import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/scan_service.dart';
import 'package:go_router/go_router.dart';

// Widget principal affichant la section des plantes scannées de l'utilisateur
class MesPlantesSection extends StatefulWidget {
  final String? filter; // Filtre optionnel pour trier les scans

  const MesPlantesSection({super.key, this.filter});

  @override
  _MesScansSectionState createState() => _MesScansSectionState();
}

class _MesScansSectionState extends State<MesPlantesSection> {
  final SupabaseClient supabase = Supabase.instance
      .client; // Instance Supabase pour la connexion backend
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
      setState(() =>
      isLoading = false); // En cas d'erreur, désactivation du loader
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
                (a, b) =>
                (b['confidence'] ?? 0).compareTo(a['confidence'] ?? 0));
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
          ? RefreshIndicator(
        onRefresh: _fetchScans,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Align(
                  alignment: Alignment.topCenter,  // Alignement en haut, centré horizontalement
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                            context.go('/camera');
                          },
                          child: Text(
                            "Ouvrir la caméra",
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      )
      // Affichage de la grille des scans si la liste n'est pas vide
          : RefreshIndicator(
        onRefresh: _fetchScans,
        // Rafraîchissement possible par "pull to refresh"
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: scans.length,
          // Nombre d'items dans la grille
          itemBuilder: (context, index) {
            final scan = scans[index];
            final int criticite = scan['criticite'] ?? 0;

            double criticiteProgress;
            Color criticiteColor;

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

            // Fonction pour afficher le dialogue de confirmation
            Future<void> _confirmDelete() async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) =>
                    AlertDialog(
                      title: const Text('Confirmer la suppression'),
                      content: const Text(
                          'Voulez-vous vraiment supprimer ce scan ?'),
                      actions: [
                        TextButton(onPressed: () =>
                            Navigator.of(ctx).pop(false), child: const Text(
                            'Annuler')),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
              );

              if (confirmed == true) {
                try {
                  await scanService.deleteScan(scan['id'], scan['image_url']);
                  await _fetchScans(); // Rafraîchir la liste après suppression
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan supprimé avec succès')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erreur lors de la suppression: $e')),
                  );
                }
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        scan['image_url'],
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 50),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: criticiteProgress,
                          color: criticiteColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _confirmDelete,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Column(
                    children: [
                      Text(
                        scan['predictions'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
