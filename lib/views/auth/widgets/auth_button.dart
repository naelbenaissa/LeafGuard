import 'package:flutter/material.dart';

/// Bouton personnalisé utilisé dans les écrans d’authentification.
/// Adapte ses couleurs en fonction du thème (mode clair/sombre)
/// pour une meilleure intégration visuelle.
class AuthButton extends StatelessWidget {
  final VoidCallback onPressed; // Callback déclenché au clic
  final String text; // Texte affiché sur le bouton

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.teal : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.black : Colors.white),
      ),
    );
  }
}
