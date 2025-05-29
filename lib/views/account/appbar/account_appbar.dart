import 'package:flutter/material.dart';

/// AppBar personnalisée pour la page de compte.
///
/// Affiche uniquement un bouton d'options (3 points) à droite.
/// S'adapte dynamiquement au thème clair/sombre.
class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Détection du thème
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Couleurs dynamiques en fonction du thème
    final foregroundColor = isDarkMode ? Colors.white : Colors.black;
    final buttonBackground = isDarkMode ? Colors.grey[800] : Colors.white;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonBackground,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black45 : Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                },
                icon: Icon(Icons.more_vert, color: foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
