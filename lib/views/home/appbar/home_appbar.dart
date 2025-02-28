import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../bar/widgets/profile_button.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final backgroundColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final buttonBackgroundColor = isDarkMode ? Colors.grey[700]! : Colors.grey.shade100;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.grey[200]! : Colors.grey[800]!;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        children: [
          AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                      color: buttonBackgroundColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ToggleButtons(
                      isSelected: [!isDarkMode, isDarkMode],
                      onPressed: (int index) {
                        themeProvider.toggleTheme();
                      },
                      selectedColor: Colors.white,
                      color: textColor,
                      fillColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      borderRadius: BorderRadius.circular(30),
                      constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
                      children: [
                        Icon(Icons.light_mode, color: isDarkMode ? iconColor : Colors.white),
                        Icon(Icons.dark_mode, color: isDarkMode ? Colors.white : iconColor),
                      ],
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
