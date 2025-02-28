import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlantDetailAppbar extends StatelessWidget implements PreferredSizeWidget {
  const PlantDetailAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final foregroundColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? Colors.grey[800] : Colors.grey[200]!;
    final shadowColor = isDarkMode ? Colors.black38 : Colors.black12;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
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
                      color: buttonColor,
                    ),
                    child: Icon(Icons.arrow_back, color: foregroundColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text("Retour", style: TextStyle(fontSize: 18, color: foregroundColor)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(color: shadowColor, blurRadius: 5, spreadRadius: 1),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  user != null ? Icons.account_circle : Icons.login,
                  color: foregroundColor,
                  size: 28,
                ),
                onPressed: () {
                  print('Navigation vers : ${user != null ? "/account" : "/auth"}');
                  context.pop();
                  context.go(user != null ? '/account' : '/auth');
                },
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
