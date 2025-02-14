import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:ui_leafguard/services/scan_service.dart';

class MesScansSection extends StatefulWidget {
  const MesScansSection({super.key});

  @override
  _MesScansSectionState createState() => _MesScansSectionState();
}

class _MesScansSectionState extends State<MesScansSection> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final ScanService scanService;
  String? userId;
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
    final user = supabase.auth.currentUser;
    if (user != null) {
      userId = user.id;
      final userScans = await scanService.getScans(userId!);
      setState(() {
        scans = userScans;
        isLoading = false;
      });
    }
  }

  /// Affiche une boîte de dialogue pour confirmer la suppression
  Future<void> _confirmDelete(String scanId, String imageUrl) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer ce scan ?"),
          content: const Text("Cette action est irréversible."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await scanService.deleteScan(scanId, imageUrl);
                _fetchScans();
              },
              child: const Text("Confirmer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return scans.isEmpty
        ? const Center(child: Text("Aucun scan disponible", style: TextStyle(fontSize: 18)))
        : ListView.builder(
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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
              ),
            ),
            title: Text(
              scan['predictions'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%"),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _confirmDelete(scan['id'], scan['image_url']),
            ),
          ),
        );
      },
    );
  }
}
