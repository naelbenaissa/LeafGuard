import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final File? selectedImage;
  final VoidCallback takePicture;
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
