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
  bool _isScanning = false; // Indique si une opération de scan est en cours
  Color _indicatorColor = Colors.white; // Couleur de l'indicateur de progression
  Timer? _colorTimer; // Timer pour gérer les changements de couleur progressifs

  Future<void> _handleScanPressed() async {
    if (_isScanning) return; // Empêche le lancement multiple simultané

    setState(() {
      _isScanning = true;
      _indicatorColor = Colors.white; // Couleur initiale de l'indicateur
    });

    // Annule tout timer précédent pour éviter chevauchement
    _colorTimer?.cancel();

    // Change la couleur de l'indicateur après 5s en orange pour signaler attente prolongée
    _colorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _indicatorColor = Colors.orange;
        });
      }
    });

    // Change la couleur en rouge après 10s pour signaler un délai critique
    _colorTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _indicatorColor = Colors.red;
        });
      }
    });

    try {
      // Exécution du scan asynchrone fourni par le parent
      await widget.onScanPressed();
    } finally {
      // Réinitialisation de l'état à la fin du scan, en annulant les timers
      if (mounted) {
        _colorTimer?.cancel();
        setState(() {
          _isScanning = false;
          _indicatorColor = Colors.white;
        });
      }
    }
  }

  @override
  void dispose() {
    _colorTimer?.cancel(); // Nettoyage des timers lors de la destruction du widget
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
