import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLightTheme;
  final Function(bool) onThemeChanged;

  const CustomAppBar({
    super.key,
    required this.isLightTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                "https://img.freepik.com/photos-gratuite/portrait-jeune-homme-affaires-afro-americain-confiant-prospere-portant-lunettes-elegantes_273609-9178.jpg",
              ),
            ),
          ),
          const Spacer(),
          ToggleButtons(
            isSelected: [isLightTheme, !isLightTheme],
            onPressed: (int index) {
              onThemeChanged(index == 0);
            },
            selectedColor: Colors.white,
            color: Colors.black,
            fillColor: isLightTheme ? Colors.grey.shade300 : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(30),
            constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
            children: const [
              Icon(Icons.light_mode),
              Icon(Icons.dark_mode),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
