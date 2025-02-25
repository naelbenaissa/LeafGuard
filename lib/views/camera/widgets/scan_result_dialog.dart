import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/leafguard_api_service.dart';

class ScanResultDialog {
  static Future<void> show(BuildContext context, File selectedImage, IaLeafguardService iaService) async {
    try {
      final result = await iaService.predictDisease(selectedImage);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Résultat du scan"),
            content: Text(
              "Maladie détectée: ${result['maladies'] ?? 'Inconnu'}\n"
                  "Confiance: ${(result['confiance'] != null ? (result['confiance'] * 100).toStringAsFixed(2) : 'N/A')}%",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          );
        },
      );
    } catch (e) {
      debugPrint("Erreur lors de l'analyse de l'image: $e");
    }
  }
}
