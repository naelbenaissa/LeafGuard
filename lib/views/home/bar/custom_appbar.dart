import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ScrollController scrollController;

  const CustomAppBar({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    bool isScrolled = scrollController.hasClients && scrollController.offset > 50;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isScrolled ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/account');
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  "https://img.freepik.com/photos-gratuite/portrait-jeune-homme-affaires-afro-americain-confiant-prospere-portant-lunettes-elegantes_273609-9178.jpg",
                ),
              ),
            ),
          ),
          const Spacer(),
          ToggleButtons(
            isSelected: [false, false],
            onPressed: (int index) {
            },
            selectedColor: Colors.white,
            color: Colors.black,
            fillColor: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
            constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
            children: const [
              Icon(Icons.light_mode),
              Icon(Icons.dark_mode),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}