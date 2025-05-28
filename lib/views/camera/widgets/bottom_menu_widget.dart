import 'dart:async';

import 'package:flutter/material.dart';

class BottomMenuWidget extends StatefulWidget {
  final Function(String) onOptionSelected;
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
  Timer? _colorTimer;

  Future<void> _handleScanPressed() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _indicatorColor = Colors.white;
    });

    // Lancement des timers de changement de couleur
    _colorTimer?.cancel(); // au cas où un timer est encore actif
    _colorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _indicatorColor = Colors.orange;
        });
      }
    });

    _colorTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _indicatorColor = Colors.red;
        });
      }
    });

    try {
      await widget.onScanPressed();
    } finally {
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
    _colorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuButton(Icons.camera_alt, "Caméra"),
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
          _buildMenuButton(Icons.image, "Ajouter une image"),
        ],
      ),
    );
  }

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
