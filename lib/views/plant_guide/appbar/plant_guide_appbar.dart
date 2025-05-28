import 'package:flutter/material.dart';
import '../../bar/widgets/profile_button.dart';

/// AppBar personnalisée pour la page du guide des plantes.
///
/// Intègre un bouton profil et une barre de recherche avec un style arrondi,
/// adaptant ses couleurs au thème clair ou sombre.
class PlantGuideAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Callback appelé à chaque modification du texte dans le champ de recherche.
  final Function(String) onSearchChanged;

  const PlantGuideAppBar({super.key, required this.onSearchChanged});

  // Hauteur fixe de l'AppBar
  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Couleurs adaptées au thème clair/sombre
    final Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final Color textFieldColor = isDarkMode ? Colors.grey[800]! : Colors.grey.shade100;
    final Color hintTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey;
    final Color iconColor = isDarkMode ? Colors.white : Colors.black;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        children: [
          // Bar transparente pour gérer la hauteur et l'espace de la status bar
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          // Container principal avec champ de recherche et bouton profil
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const ProfileButton(), // Bouton profil utilisateur
                  const SizedBox(width: 10),
                  // Champ de recherche expansible
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChanged,
                      style: TextStyle(color: iconColor),
                      decoration: InputDecoration(
                        hintText: "Rechercher une plante...",
                        hintStyle: TextStyle(color: hintTextColor),
                        prefixIcon: Icon(Icons.search, color: hintTextColor),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        filled: true,
                        fillColor: textFieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
