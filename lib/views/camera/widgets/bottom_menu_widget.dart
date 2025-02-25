import 'package:flutter/material.dart';

class BottomMenuWidget extends StatelessWidget {
  final Function(String) onOptionSelected;
  final VoidCallback onScanPressed;

  const BottomMenuWidget({
    super.key,
    required this.onOptionSelected,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[700],
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuButton(Icons.camera_alt, "Caméra"),
          FloatingActionButton(
            onPressed: onScanPressed,
            backgroundColor: Colors.white,
            child: const Icon(Icons.document_scanner, color: Colors.black, size: 30),
          ),
          _buildMenuButton(Icons.image, "Ajouter une image"),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String option) {
    return GestureDetector(
      onTap: () => onOptionSelected(option),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
