import 'package:flutter/material.dart';

/// Bouton personnalisé affichant une icône et
/// déclenchant une callback avec l'option associée lors du tap.
class MenuButton extends StatelessWidget {
  /// Icône à afficher dans le bouton
  final IconData icon;

  /// Option passée au callback lors de l'appui
  final String option;

  /// Fonction callback appelée avec [option] lors du tap
  final Function(String) onPressed;

  const MenuButton({
    super.key,
    required this.icon,
    required this.option,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(option),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
