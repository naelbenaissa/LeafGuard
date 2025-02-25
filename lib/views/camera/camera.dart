import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/camera/widgets/bottom_menu_widget.dart';
import 'package:ui_leafguard/views/camera/widgets/camera_preview_widget.dart';
import 'package:ui_leafguard/views/camera/widgets/image_selection_widget.dart';
import 'package:ui_leafguard/views/camera/widgets/scan_result_dialog.dart';
import '../../services/leafguard_api_service.dart';
import '../../services/scan_service.dart'; // Import du ScanService
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
  final ScanService _scanService = ScanService(Supabase.instance.client); // Initialisation du service

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

  /// **🔍 Analyse l'image et affiche les résultats**
  Future<void> scanDisease() async {
    if (_selectedImage == null) return;
    await ScanResultDialog.show(context, _selectedImage!, _iaService, _scanService);
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
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.green[100],
              child: _selectedOption == "Caméra"
                  ? CameraPreviewWidget(
                controller: _controller,
                selectedImage: _selectedImage,
                takePicture: takePicture,
                clearImage: () => setState(() => _selectedImage = null),
              )
                  : ImageSelectionWidget(
                selectedImage: _selectedImage,
                pickImage: pickImage,
                clearImage: () => setState(() => _selectedImage = null),
              ),
            ),
          ),
          BottomMenuWidget(
            onOptionSelected: (option) {
              setState(() {
                _selectedOption = option;
                _selectedImage = null;
              });
            },
            onScanPressed: scanDisease,
          ),
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.all(4.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: scanDisease,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text("Scan récent")),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
