import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget AppBar personnalisé pour la page de compte.
///
/// Affiche un bouton de retour vers la page d'accueil et un bouton d'options.
/// Les couleurs et le style s'adaptent dynamiquement selon le thème actuel (clair ou sombre).
class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Détecte si le thème actuel est sombre
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Définition des couleurs dynamiques en fonction du thème
    final foregroundColor = isDarkMode ? Colors.white : Colors.black;
    final buttonBackground = isDarkMode ? Colors.grey[800] : Colors.white;
    final iconBackground = isDarkMode ? Colors.grey[700] : Colors.grey[200];

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton "Accueil" avec une icône flèche de retour
            ElevatedButton(
              onPressed: () => context.go("/"),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackground,
                foregroundColor: foregroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Row(
                children: [
                  // Icône circulaire de flèche retour
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBackground,
                    ),
                    child: Icon(Icons.arrow_back, color: foregroundColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Accueil",
                    style: TextStyle(fontSize: 18, color: foregroundColor),
                  ),
                ],
              ),
            ),
            // Bouton d'action (ex : menu, paramètres)
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
                  // Action à définir selon les besoins (menu contextuel, paramètres, etc.)
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
