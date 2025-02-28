import 'package:flutter/material.dart';
import '../../bar/widgets/profile_button.dart';

class FavoritesAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onFilterPressed;

  const FavoritesAppbar({super.key, required this.onFilterPressed});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]! // Gris foncé en mode sombre
        : Colors.white; // Blanc en mode clair

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
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
                  const ProfileButton(),
                  const Spacer(),
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // Icône blanche en mode sombre
                          : Colors.black, // Icône noire en mode clair
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
