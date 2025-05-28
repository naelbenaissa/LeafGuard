import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  // Contrôleur de la caméra (nullable, car l'initialisation est asynchrone)
  final CameraController? controller;

  // Image sélectionnée affichée à la place de la preview caméra
  final File? selectedImage;

  // Callback déclenché pour prendre une photo
  final VoidCallback takePicture;

  // Callback déclenché pour annuler la photo sélectionnée
  final VoidCallback clearImage;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.selectedImage,
    required this.takePicture,
    required this.clearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          // Affiche la preview caméra si aucune image sélectionnée et que le contrôleur est prêt,
          // sinon affiche un message d’erreur ou l’image sélectionnée.
          child: selectedImage == null
              ? (controller != null && controller!.value.isInitialized
              ? CameraPreview(controller!)
              : const Center(child: Text("Caméra non disponible")))
              : Image.file(selectedImage!, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
              ],
            ),
            // Bouton action contextuel : prend une photo ou annule l’image sélectionnée
            child: IconButton(
              onPressed: selectedImage == null ? takePicture : clearImage,
              icon: Icon(
                selectedImage == null ? Icons.camera : Icons.close,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
