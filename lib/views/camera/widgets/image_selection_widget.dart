import 'dart:io';
import 'package:flutter/material.dart';

class ImageSelectionWidget extends StatelessWidget {
  // Image sélectionnée à afficher, null si aucune
  final File? selectedImage;

  // Callback pour ouvrir le sélecteur d'image
  final VoidCallback pickImage;

  // Callback pour effacer l'image sélectionnée
  final VoidCallback clearImage;

  const ImageSelectionWidget({
    super.key,
    required this.selectedImage,
    required this.pickImage,
    required this.clearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          // Affiche une image par défaut avec un bouton pour choisir une image si aucune sélectionnée,
          // sinon affiche l'image sélectionnée en plein écran.
          child: selectedImage == null
              ? Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/storyboard_pickImage.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text("Sélectionner une image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          )
              : Image.file(selectedImage!, fit: BoxFit.cover),
        ),
        if (selectedImage != null)
        // Bouton pour effacer l'image sélectionnée, visible uniquement quand une image est affichée
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: clearImage,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: const Icon(Icons.close, color: Colors.black, size: 30),
              ),
            ),
          ),
      ],
    );
  }
}
