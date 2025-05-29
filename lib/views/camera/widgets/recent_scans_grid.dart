import 'package:flutter/material.dart';
import '../../../services/scan_service.dart';

class RecentScansGrid extends StatefulWidget {
  final List<Map<String, dynamic>> recentScans;
  final VoidCallback onScanTap;
  final ScanService scanService;
  final VoidCallback onScanDeleted;

  const RecentScansGrid({
    super.key,
    required this.recentScans,
    required this.onScanTap,
    required this.scanService,
    required this.onScanDeleted,
  });

  @override
  State<RecentScansGrid> createState() => _RecentScansGridState();
}

class _RecentScansGridState extends State<RecentScansGrid> {
  late List<Map<String, dynamic>> scans;

  @override
  void initState() {
    super.initState();
    scans = List.from(widget.recentScans);
  }

  @override
  void didUpdateWidget(covariant RecentScansGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recentScans != widget.recentScans) {
      scans = List.from(widget.recentScans);
    }
  }

  /// Affiche une boîte de dialogue pour confirmer la suppression d'un scan.
  /// Si confirmé, supprime le scan via le service et notifie le parent pour mise à jour.
  Future<void> _confirmAndDelete(BuildContext context, String scanId, String imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce scan ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.scanService.deleteScan(scanId, imageUrl);
        widget.onScanDeleted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan supprimé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (scans.isEmpty) {
      return Center(
        child: Text(
          "Vous n'avez aucun scan enregistré",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];

          return Stack(
            children: [
              GestureDetector(
                onTap: widget.onScanTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            scan['image_url'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image,
                              size: 50,
                              color: isDarkMode ? Colors.grey[500] : Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                scan['predictions'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _confirmAndDelete(context, scan['id'], scan['image_url']),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
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
          );
        },
      ),
    );
  }
}
