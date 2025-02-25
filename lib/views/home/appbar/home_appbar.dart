import 'package:flutter/material.dart';
import '../../bar/widgets/profile_button.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

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
                  const Spacer(),
                  ToggleButtons(
                    isSelected: const [false, false],
                    onPressed: (int index) {},
                    selectedColor: Colors.white,
                    color: Colors.black,
                    fillColor: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                    constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
                    children: const [
                      Icon(Icons.light_mode),
                      Icon(Icons.dark_mode),
                    ],
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
