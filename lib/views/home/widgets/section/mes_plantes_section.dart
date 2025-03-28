import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/scan_service.dart';
import '../../../widgets/delete_confirmation_dialog.dart';

class MesPlantesSection extends StatefulWidget {
  final String? filter;
  const MesPlantesSection({super.key, this.filter});

  @override
  _MesScansSectionState createState() => _MesScansSectionState();
}

class _MesScansSectionState extends State<MesPlantesSection> {
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

  @override
  void didUpdateWidget(covariant MesPlantesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _sortScans();
    }
  }

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

  void _sortScans() {
    if (widget.filter == null) {
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

  Future<void> _confirmDelete(String scanId, String imageUrl) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);
    if (confirmDelete) {
      await _deleteScan(scanId, imageUrl);
    }
  }

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
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.8,
        ),
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];

          return Column(
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
                        value: (scan['confidence'] ?? 0) / 100,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                scan['predictions'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.grey),
              ),
              // IconButton(
              //   icon: const Icon(Icons.close, color: Colors.red),
              //   onPressed: () => _confirmDelete(scan['id'], scan['image_url']),
              // ),
            ],
          );
        },
      ),
    );
  }
}
