import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/scan_service.dart';
import '../../../widgets/delete_confirmation_dialog.dart';

class MesScansSection extends StatefulWidget {
  const MesScansSection({super.key});

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
    scanService = ScanService(supabase);
    _fetchScans();
  }

  /// Récupère les scans de l'utilisateur
  Future<void> _fetchScans() async {
    setState(() => isLoading = true);
    try {
      final userScans = await scanService.getScans();
      setState(() {
        scans = userScans;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des scans : $e");
      setState(() => isLoading = false);
    }
  }

  /// Affiche une boîte de dialogue pour confirmer la suppression
  Future<void> _confirmDelete(String scanId, String imageUrl) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);
    if (confirmDelete) {
      await _deleteScan(scanId, imageUrl);
    }
  }

  /// Supprime un scan et rafraîchit la liste
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
      return const Center(child: CircularProgressIndicator());
    }

    return scans.isEmpty
        ? RefreshIndicator(
      onRefresh: _fetchScans,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Center(
            child: Text("Aucun scan disponible", style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    )
        : RefreshIndicator(
      onRefresh: _fetchScans,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: scans.length + 1,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          if (index == scans.length) {
            return const SizedBox(height: 50);
          }

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
