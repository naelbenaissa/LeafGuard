import 'package:flutter/material.dart';
import '../../bar/widgets/profileButton.dart';

class TasksCalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TasksCalendarAppBar({super.key});

  @override
  _TasksCalendarAppBarState createState() => _TasksCalendarAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _TasksCalendarAppBarState extends State<TasksCalendarAppBar> {
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
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Action pour les notifications
                      },
                      icon: const Icon(Icons.notifications),
                      color: Colors.black,
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
