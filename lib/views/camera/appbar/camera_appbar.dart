import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onOptionSelected;

  const CameraAppBar({super.key, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => context.go("/"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    ),
                    child: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text("Accueil", style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white : Colors.black)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black54 : Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                onSelected: onOptionSelected,
                icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "Caméra",
                    child: Text("Caméra", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                  PopupMenuItem(
                    value: "Ajouter une image",
                    child: Text("Ajouter une image", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                ],
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
