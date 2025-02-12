import 'package:flutter/material.dart';
import '../../bar/widgets/profileButton.dart';

class PlantGuideAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PlantGuideAppBar({super.key});

  @override
  _PlantGuideAppBarState createState() => _PlantGuideAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _PlantGuideAppBarState extends State<PlantGuideAppBar> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        filled: true,
                        fillColor: Colors.grey.shade100,
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
