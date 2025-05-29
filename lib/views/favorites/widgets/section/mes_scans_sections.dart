import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/scan_service.dart';
import '../../../widgets/delete_confirmation_dialog.dart';

class MesScansSection extends StatefulWidget {
  final String? filter;

  /// Constructeur avec un filtre optionnel pour trier les scans
  const MesScansSection({super.key, this.filter});

  @override
  _MesScansSectionState createState() => _MesScansSectionState();
}

class _MesScansSectionState extends State<MesScansSection> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final ScanService scanService;

  List<Map<String, dynamic>> scans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialisation du service de scans avec le client Supabase
    scanService = ScanService(supabase);
    _fetchScans();
  }

  /// Détecte un changement dans le filtre pour mettre à jour l'ordre des scans
  @override
  void didUpdateWidget(covariant MesScansSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _sortScans();
    }
  }

  /// Charge la liste des scans depuis le service, avec gestion du chargement
  Future<void> _fetchScans() async {
    setState(() => isLoading = true);
    try {
      final userScans = await scanService.getScans();
      if (mounted) {
        setState(() {
          scans = userScans;
          _sortScans();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des scans : $e");
      setState(() => isLoading = false);
    }
  }

  /// Trie la liste des scans selon le filtre sélectionné (Confiance ou Date)
  void _sortScans() {
    if (widget.filter == null) {
      // Si aucun filtre, recharge la liste complète
      _fetchScans();
      return;
    }

    setState(() {
      if (widget.filter == "Confiance") {
        scans.sort((a, b) => (b['confidence'] ?? 0).compareTo(a['confidence'] ?? 0));
      } else if (widget.filter == "Date") {
        scans.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          DateTime dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
      }
    });
  }

  /// Affiche une boîte de dialogue demandant la confirmation de suppression
  Future<void> _confirmDelete(String scanId, String imageUrl) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);
    if (confirmDelete) {
      await _deleteScan(scanId, imageUrl);
    }
  }

  /// Supprime un scan via le service et rafraîchit la liste des scans
  Future<void> _deleteScan(String scanId, String imageUrl) async {
    setState(() => isLoading = true);
    try {
      await scanService.deleteScan(scanId, imageUrl);
      await _fetchScans();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan supprimé avec succès.")),
      );
    } catch (e) {
      debugPrint("Erreur lors de la suppression du scan : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la suppression du scan.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Affiche un indicateur de chargement pendant le fetch
      return const Center(child: CircularProgressIndicator());
    }

    // Affiche un message si aucun scan n'est présent
    if (scans.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchScans,
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
                      "Vous n'avez aucun scan.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Scannez dès maintenant vos plantes pour les voir apparaître ici !",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Redirection vers la caméra pour scanner une plante
                        context.go('/camera');
                      },
                      child: Text(
                        "Aller à la caméra",
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
        ),
      );
    }

    // Affiche la liste des scans avec possibilité de rafraîchir
    return RefreshIndicator(
      onRefresh: _fetchScans,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: scans.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final scan = scans[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  scan['image_url'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 50),
                ),
              ),
              title: Text(
                scan['predictions'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%"),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _confirmDelete(scan['id'], scan['image_url']),
              ),
            ),
          );
        },
      ),
    );
  }
}
