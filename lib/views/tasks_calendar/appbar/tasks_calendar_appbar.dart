import 'package:flutter/material.dart';
import '../../bar/widgets/profile_button.dart';
import '../widgets/dialog/show_notifications_dialog.dart';

/// Barre d'applications personnalisée pour le calendrier des tâches.
/// Implémente PreferredSizeWidget pour définir une hauteur spécifique.
class TasksCalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TasksCalendarAppBar({super.key});

  @override
  _TasksCalendarAppBarState createState() => _TasksCalendarAppBarState();

  /// Hauteur préférée de la barre d'applications (80 pixels)
  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _TasksCalendarAppBarState extends State<TasksCalendarAppBar> {
  @override
  Widget build(BuildContext context) {
    // Détermination de la couleur de fond selon le thème (mode clair/sombre)
    final Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]! // Gris foncé pour mode sombre
        : Colors.white;     // Blanc pour mode clair

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        children: [
          // AppBar transparente pour gérer la zone du statut sans afficher de fond
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),

          // Positionnement du conteneur principal juste en dessous de la barre de statut
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Décalage respectant la zone safe area
            left: 16,
            right: 16,
            child: Container(
              // Conteneur avec fond arrondi et ombre portée pour un effet carte flottante
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Ombre légère
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),

              // Espacement interne pour contenir proprement les éléments
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

              child: Row(
                children: [
                  // Bouton profil utilisateur placé à gauche
                  const ProfileButton(),

                  // Espace flexible pour pousser la notification à droite
                  const Spacer(),

                  // Conteneur circulaire pour le bouton notification avec ombre
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,  // Ombre légère sous le bouton
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),

                    // Bouton icône pour afficher la boîte de dialogue des notifications
                    child: IconButton(
                      onPressed: () => showNotificationDialog(context),
                      icon: const Icon(Icons.notifications),

                      // Couleur de l'icône adaptée au thème (clair ou sombre)
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
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
