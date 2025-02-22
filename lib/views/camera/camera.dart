import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
        debugPrint("Image sélectionnée: ${image.path}");
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection d'une image: $e");
    }
  }

  void _updateOption(String option) {
    setState(() {
      _selectedOption = option;
    });
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
      appBar: CameraAppBar(onOptionSelected: _updateOption),
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
                    : Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/img/storyboard_pickImage.jpg',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            ElevatedButton.icon(
                              onPressed: pickImage,
                              icon:
                                  const Icon(Icons.image, color: Colors.white),
                              label: const Text("Sélectionner une image",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  return Container(
                    color: Colors.grey[300],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
