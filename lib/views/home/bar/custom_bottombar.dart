import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom Navigation Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomAppBar(
              color: Colors.white,
              shape: const CircularNotchedRectangle(),
              notchMargin: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.green : Colors.grey),
                      onPressed: () => onItemTapped(0),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_month, color: selectedIndex == 1 ? Colors.green : Colors.grey),
                      onPressed: () => onItemTapped(1),
                    ),
                    const SizedBox(width: 50), // Espace pour le bouton central
                    IconButton(
                      icon: Icon(Icons.favorite, color: selectedIndex == 2 ? Colors.green : Colors.grey),
                      onPressed: () => onItemTapped(2),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu_book, color: selectedIndex == 3 ? Colors.green : Colors.grey),
                      onPressed: () => onItemTapped(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Floating Action Button (Camera Icon)
        Positioned(
          bottom: 30,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: FloatingActionButton(
            onPressed: () => onItemTapped(4),
            backgroundColor: Colors.green,
            shape: const CircleBorder(),
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
