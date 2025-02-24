import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/leafguard_api_service.dart';
import 'appbar/camera_appbar.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String _selectedOption = "Caméra";
  CameraController? _controller;
  List<CameraDescription>? cameras;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final IaLeafguardService _iaService = IaLeafguardService();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation de la caméra: $e");
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection d'une image: $e");
    }
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      debugPrint("Erreur lors de la capture de la photo: $e");
    }
  }

  Future<void> scanDisease() async {
    if (_selectedImage == null) return;
    try {
      final result = await _iaService.predictDisease(_selectedImage!);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Résultat du scan"),
            content: Text("Maladie détectée: ${result['maladies'] ?? 'Inconnu'}\nConfiance: ${(result['confiance'] != null ? (result['confiance'] * 100).toStringAsFixed(2) : 'N/A')}%"),
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CameraAppBar(onOptionSelected: (option) {
        setState(() {
          _selectedOption = option;
          _selectedImage = null;
        });
      }),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _selectedOption == "Caméra"
                ? (_controller != null && _controller!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            )
                : const Center(child: CircularProgressIndicator()))
                : _selectedOption == "Scans récents"
                ? const Center(child: Text("Liste des scans récents"))
                : _selectedImage != null
                ? Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/img/storyboard_pickImage.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedOption == "Caméra"
                          ? Icons.camera_alt
                          : _selectedOption == "Scans récents"
                          ? Icons.history
                          : Icons.image,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedOption,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text("Sélectionner une image", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedOption != "Scans récents" && _selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: scanDisease,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Scanner la maladie"),
              ),
            ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return Container(color: Colors.grey[300]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}