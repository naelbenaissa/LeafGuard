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

  Future<void> _handleScanPressed() async {
    if (_isScanning) return; // sécurité anti double clic

    setState(() {
      _isScanning = true;
    });

    try {
      await widget.onScanPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
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
              ? const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              color: Colors.white,
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
