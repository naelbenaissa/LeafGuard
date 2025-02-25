import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onOptionSelected;

  const CameraAppBar({super.key, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
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
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text("Accueil", style: TextStyle(fontSize: 18),),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                ],
              ),
              child: PopupMenuButton<String>(
                onSelected: onOptionSelected,
                icon: const Icon(Icons.more_vert, color: Colors.black),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "Caméra", child: Text("Caméra")),
                  const PopupMenuItem(value: "Ajouter une image", child: Text("Ajouter une image")),
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
