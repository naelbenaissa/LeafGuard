import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    String location = GoRouter.of(context).routeInformationProvider.value.location ?? '/';
    switch (location) {
      case '/':
        return 0;
      case '/calendar':
        return 1;
      case '/favorites':
        return 2;
      case '/plantsguide':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = _getSelectedIndex(context);
    final user = Supabase.instance.client.auth.currentUser;
    final bool isAuthenticated = user != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BottomAppBar(
          color: Colors.white,
          elevation: 3,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.green : Colors.grey),
                  onPressed: () => context.go('/'),
                ),
                if (isAuthenticated)
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: selectedIndex == 1 ? Colors.green : Colors.grey),
                    onPressed: () => context.go('/calendar'),
                  ),
                const SizedBox(width: 50),
                if (isAuthenticated)
                  IconButton(
                    icon: Icon(Icons.favorite, color: selectedIndex == 2 ? Colors.green : Colors.grey),
                    onPressed: () => context.go('/favorites'),
                  ),
                IconButton(
                  icon: Icon(Icons.menu_book, color: selectedIndex == 3 ? Colors.green : Colors.grey),
                  onPressed: () => context.go('/plantsguide'),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: FloatingActionButton(
            onPressed: () => context.go('/camera'),
            backgroundColor: Colors.green,
            shape: const CircleBorder(),
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
