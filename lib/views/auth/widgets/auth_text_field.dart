import 'package:flutter/material.dart';

/// Champ de saisie générique avec support du type clavier, mode lecture seule,
/// et personnalisation optionnelle d'une icône suffixe.
/// S’adapte automatiquement au thème clair/sombre pour une meilleure lisibilité.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller; // Contrôleur du champ texte
  final String label; // Libellé affiché au-dessus du champ
  final TextInputType keyboardType; // Type du clavier (texte, email, nombre, etc.)
  final bool readOnly; // Indique si le champ est en lecture seule
  final Widget? suffixIcon; // Icône personnalisée affichée à droite du champ

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        suffixIcon: suffixIcon,
      ),
    );
  }
}
