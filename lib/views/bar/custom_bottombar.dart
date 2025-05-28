import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/auth/auth.dart';

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

  Future<void> _handleNavigation(BuildContext context, String targetRoute) async {
    final currentRoute = GoRouter.of(context).routeInformationProvider.value.location;
    if (currentRoute == '/auth') {
      final authPageState = context.findAncestorStateOfType<AuthPageState>();
      if (authPageState != null && authPageState.hasPartialInput()) {
        bool confirmed = await authPageState.confirmLeavePage();
        if (!confirmed) return;
      }
    }

    context.go(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = _getSelectedIndex(context);
    final user = Supabase.instance.client.auth.currentUser;
    final bool isAuthenticated = user != null;
    final backgroundColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor;
    final iconColor = Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;
    final selectedColor = Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Colors.green;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BottomAppBar(
          color: backgroundColor,
          elevation: 3,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: selectedIndex == 0 ? selectedColor : iconColor),
                  onPressed: selectedIndex == 0 ? null : () => _handleNavigation(context, '/'),
                ),
                if (isAuthenticated)
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: selectedIndex == 1 ? selectedColor : iconColor),
                    onPressed: selectedIndex == 1 ? null : () => _handleNavigation(context, '/calendar'),
                  ),
                const SizedBox(width: 50),
                if (isAuthenticated)
                  IconButton(
                    icon: Icon(Icons.favorite, color: selectedIndex == 2 ? selectedColor : iconColor),
                    onPressed: selectedIndex == 2 ? null : () => _handleNavigation(context, '/favorites'),
                  ),
                IconButton(
                  icon: Icon(Icons.menu_book, color: selectedIndex == 3 ? selectedColor : iconColor),
                  onPressed: selectedIndex == 3 ? null : () => _handleNavigation(context, '/plantsguide'),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: FloatingActionButton(
            onPressed: () => _handleNavigation(context, '/camera'),
            backgroundColor: selectedColor,
            shape: const CircleBorder(),
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
