import 'dart:io';
import 'package:flutter/material.dart';

class ImageSelectionWidget extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback pickImage;
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
          child: selectedImage == null
              ? Container(
            color: Colors.green[100],
            child: Center(
              child: ElevatedButton(
                onPressed: pickImage,
                child: const Text("Sélectionner une image"),
              ),
            ),
          )
              : Image.file(selectedImage!, fit: BoxFit.cover),
        ),
        if (selectedImage != null)
          Positioned(
            bottom: 20,
            child: FloatingActionButton(
              onPressed: clearImage,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.close, color: Colors.black, size: 30),
            ),
          ),
      ],
    );
  }
}
