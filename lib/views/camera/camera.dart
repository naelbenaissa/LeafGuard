import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/camera/widgets/bottom_menu_widget.dart';
import 'package:ui_leafguard/views/camera/widgets/camera_preview_widget.dart';
import 'package:ui_leafguard/views/camera/widgets/image_selection_widget.dart';
import 'package:ui_leafguard/views/camera/widgets/recent_scans_grid.dart';
import 'package:ui_leafguard/views/camera/widgets/scan_result_dialog.dart';
import '../../services/leafguard_api_service.dart';
import '../../services/scan_service.dart';
import 'appbar/camera_appbar.dart';
import 'package:flutter/services.dart';

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
  final ScanService _scanService = ScanService(Supabase.instance.client);
  final GlobalKey<BottomMenuWidgetState> _bottomMenuKey = GlobalKey<BottomMenuWidgetState>();

  List<Map<String, dynamic>> _recentScans = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initializeCamera();
    _fetchScans();
  }

  /// Initialise la caméra et met à jour l'état
  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation de la caméra: $e");
    }
  }

  /// Ouvre la galerie pour sélectionner une image
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection d'une image: $e");
    }
  }

  /// Prend une photo avec la caméra active
  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      setState(() => _selectedImage = File(image.path));
    } catch (e) {
      debugPrint("Erreur lors de la capture de la photo: $e");
    }
  }

  /// Lance l'analyse de la maladie sur l'image sélectionnée et affiche les résultats
  Future<void> scanDisease() async {
    if (_selectedImage == null) return;

    // Stoppe les timers si le menu est monté
    _bottomMenuKey.currentState?.cancelTimers();

    await ScanResultDialog.show(
      context,
      _selectedImage!,
      _iaService,
      _scanService,
    );

    _fetchScans();
  }

  /// Charge les scans récents depuis la base de données
  Future<void> _fetchScans() async {
    try {
      final scans = await _scanService.getScans();
      setState(() => _recentScans = scans.toList());
    } catch (e) {
      debugPrint("Erreur lors du chargement des scans : $e");
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CameraAppBar(
        onOptionSelected: (option) {
          setState(() {
            _selectedOption = option;
            _selectedImage = null;
          });
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: isDarkMode ? Colors.black : Colors.green[100],
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
            key: _bottomMenuKey, // Ajoute la clé ici
            onOptionSelected: (option) {
              setState(() {
                _selectedOption = option;
                _selectedImage = null;
              });
            },
            onScanPressed: scanDisease,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              color: isDarkMode ? Colors.black : Colors.white,
              child: RecentScansGrid(
                recentScans: _recentScans,
                onScanTap: scanDisease,
                scanService: _scanService,
                onScanDeleted: _fetchScans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
