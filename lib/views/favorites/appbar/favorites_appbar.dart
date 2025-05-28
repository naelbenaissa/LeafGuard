import 'package:flutter/material.dart';
import '../../bar/widgets/profile_button.dart';

class FavoritesAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onFilterPressed;

  const FavoritesAppbar({super.key, required this.onFilterPressed});

  // Hauteur préférée de l'AppBar personnalisée
  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    // Couleur de fond selon le thème (mode sombre ou clair)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;

    return PreferredSize(
      preferredSize: preferredSize,
      child: Stack(
        children: [
          // AppBar transparente pour gérer la zone du statut bar et l'ombre
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          // Conteneur personnalisé positionné sous la status bar avec ombre et arrondi
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // décallage sous la status bar
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30), // coins arrondis
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // ombre légère
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const ProfileButton(), // Bouton profil à gauche
                  const Spacer(),          // Espace flexible pour pousser le bouton filtre à droite
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: onFilterPressed,
                      icon: const Icon(Icons.filter_list),
                      color: isDarkMode ? Colors.white : Colors.black, // couleur de l'icône selon thème
                      tooltip: 'Filtrer', // accessibilité
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
