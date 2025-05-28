import 'package:flutter/material.dart';

/// Champ de saisie sécurisé pour mot de passe avec visibilité basculable.
/// Adapté au thème clair/sombre pour une meilleure ergonomie visuelle.
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller; // Contrôleur du champ texte
  final String label; // Libellé du champ

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  _AuthPasswordFieldState createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _isPasswordVisible = false; // Gestion visibilité du mot de passe

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // bascule visibilité
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
