import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/leafguard_api_service.dart';
import '../../../services/scan_service.dart';

class ScanResultDialog {
  static Future<void> show(
    BuildContext context,
    File selectedImage,
    IaLeafguardService iaService,
    ScanService scanService,
  ) async {
    try {
      final result = await iaService.predictDisease(selectedImage);
      final String maladie = result['maladies'] ?? 'Inconnu';

      final double? rawConfiance = result['confiance'];
      final double? displayedConfiance =
          rawConfiance != null ? rawConfiance * 100 : null;

      bool isBookmarked = false;
      String? scanId;
      String? imageUrl;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Résultat du Scan",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      tooltip: "Fermer",
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(selectedImage,
                          height: 150, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "🌿 Maladie détectée : $maladie",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "🔬 Confiance : ${displayedConfiance != null ? "${displayedConfiance.toStringAsFixed(2)}%" : "N/A"}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (isBookmarked) {
                            if (scanId == null || imageUrl == null) {
                              List<Map<String, dynamic>> scans =
                                  await scanService.getScans();
                              if (scans.isNotEmpty) {
                                scanId = scans.first['id'].toString();
                                imageUrl = scans.first['image_url'].toString();
                              } else {
                                return;
                              }
                            }

                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text("Supprimer ce scan ?"),
                                  content: const Text(
                                      "Êtes-vous sûr de vouloir supprimer ce scan ? Cette action est irréversible."),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text("Annuler"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: const Text("Supprimer",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete) {
                              try {
                                await scanService.deleteScan(
                                    scanId!, imageUrl!);
                                setState(() {
                                  isBookmarked = false;
                                  scanId = null;
                                  imageUrl = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Scan supprimé avec succès.")),
                                );
                              } catch (e) {
                                debugPrint(
                                    "Erreur lors de la suppression du scan : $e");
                              }
                            }
                          } else {
                            try {
                              await scanService.addScan(
                                imageFile: selectedImage,
                                predictions: maladie,
                                confidence: rawConfiance ?? 0.0,
                              );
                              List<Map<String, dynamic>> scans =
                                  await scanService.getScans();
                              Map<String, dynamic>? addedScan =
                                  scans.firstWhere(
                                (scan) =>
                                    scan['predictions'] == maladie &&
                                    scan['confidence'] == rawConfiance,
                                orElse: () => {},
                              );

                              setState(() {
                                isBookmarked = true;
                                scanId = addedScan['id']?.toString();
                                imageUrl = addedScan['image_url']?.toString();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Ajouté aux favoris !")),
                              );
                            } catch (e) {
                              debugPrint(
                                  "Erreur lors de l'ajout aux favoris : $e");
                            }
                          }
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.orange,
                        ),
                        tooltip: isBookmarked
                            ? "Retirer des favoris"
                            : "Ajouter aux favoris",
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          debugPrint("Tâche ajoutée au calendrier !");
                        },
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.white),
                        label: const Text("Ajouter au calendrier"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint("Erreur lors de l'analyse de l'image: $e");
    }
  }
}
