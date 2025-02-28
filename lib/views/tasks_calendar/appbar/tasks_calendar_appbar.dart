import 'package:flutter/material.dart';
import '../../bar/widgets/profile_button.dart';
import '../widgets/dialog/show_notifications_dialog.dart';

class TasksCalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TasksCalendarAppBar({super.key});

  @override
  _TasksCalendarAppBarState createState() => _TasksCalendarAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _TasksCalendarAppBarState extends State<TasksCalendarAppBar> {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]! // Gris foncé en mode sombre
        : Colors.white; // Blanc en mode clair

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
                      shape: BoxShape.circle,
                      color: backgroundColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => showNotificationDialog(context),
                      icon: const Icon(Icons.notifications),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // Icône blanche en mode sombre
                          : Colors.black, // Icône noire en mode clair
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
