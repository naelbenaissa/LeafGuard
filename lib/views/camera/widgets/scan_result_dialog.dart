import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/leafguard_api_service.dart';

class ScanResultDialog {
  static Future<void> show(BuildContext context, File selectedImage, IaLeafguardService iaService) async {
    try {
      final result = await iaService.predictDisease(selectedImage);
      final String maladie = result['maladies'] ?? 'Inconnu';
      final double? confiance = result['confiance'] != null ? result['confiance'] * 100 : null;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Résultat du Scan",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
                  child: Image.file(selectedImage, height: 150, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                Text(
                  "🌿 Maladie détectée : $maladie",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "🔬 Confiance : ${confiance != null ? "${confiance.toStringAsFixed(2)}%" : "N/A"}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      debugPrint("Ajouté aux favoris !");
                    },
                    icon: const Icon(Icons.bookmark_border, color: Colors.orange),
                    tooltip: "Ajouter aux favoris",
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint("Tâche ajoutée au calendrier !");
                    },
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
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
    } catch (e) {
      debugPrint("Erreur lors de l'analyse de l'image: $e");
    }
  }
}
