import 'dart:async';

import 'package:flutter/material.dart';

class BottomMenuWidget extends StatefulWidget {
  // Callback appelé lorsqu'une option du menu est sélectionnée (ex: Caméra, Ajouter une image)
  final Function(String) onOptionSelected;

  // Callback asynchrone déclenché lors de l'appui sur le bouton de scan
  final Future<void> Function() onScanPressed;

  const BottomMenuWidget({
    super.key,
    required this.onOptionSelected,
    required this.onScanPressed,
  });

  @override
  _BottomMenuWidgetState createState() => _BottomMenuWidgetState();
}

class _BottomMenuWidgetState extends State<BottomMenuWidget> {
  bool _isScanning = false;
  Color _indicatorColor = Colors.white;
  Timer? _warningTimer;
  Timer? _timeoutTimer;
  bool _scanTermine = false;

  Future<void> _handleScanPressed() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _indicatorColor = Colors.white;
    });

    _warningTimer?.cancel();
    _timeoutTimer?.cancel();

    _scanTermine = false;  // reset au début du scan

    _warningTimer = Timer(const Duration(seconds: 5), () {
      if (!_scanTermine && mounted) {
        setState(() => _indicatorColor = Colors.orange);
      }
    });

    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_scanTermine && mounted) {
        setState(() => _indicatorColor = Colors.red);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Certaines opérations peuvent prendre un peu plus de temps. Merci de patienter..."),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    try {
      // Annule timers et état AVANT d'appeler la fonction qui ouvre le dialog
      _warningTimer?.cancel();
      _timeoutTimer?.cancel();

      if (mounted) {
        setState(() {
          _isScanning = false;
          _indicatorColor = Colors.white;
        });
      }

      await widget.onScanPressed();

      _scanTermine = true;

    } catch (e) {
      _scanTermine = true;
    }
  }



  @override
  void dispose() {
    _warningTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green, // Couleur de fond du menu
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Bouton caméra
          _buildMenuButton(Icons.camera_alt, "Caméra"),
          // Affiche indicateur de progression coloré pendant le scan, sinon bouton scan
          _isScanning
              ? SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    color: _indicatorColor,
                    strokeWidth: 3,
                  ),
                )
              : FloatingActionButton(
                  onPressed: _handleScanPressed,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.document_scanner,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
          // Bouton ajout d'image
          _buildMenuButton(Icons.image, "Ajouter une image"),
        ],
      ),
    );
  }

// Génère un bouton menu simple avec icône et gestion du tap
  Widget _buildMenuButton(IconData icon, String option) {
    return GestureDetector(
      onTap: () => widget.onOptionSelected(option),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
