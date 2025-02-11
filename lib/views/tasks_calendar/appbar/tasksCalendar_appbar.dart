import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/user_service.dart';

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
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final userData = await UserService().fetchUserData(user.id);
      if (userData != null && userData['profile_image'] != null) {
        setState(() {
          profileImageUrl = userData['profile_image'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

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
                  GestureDetector(
                    onTap: () => context.go(user != null ? '/account' : '/auth'),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 28, color: Colors.grey)
                          : null,
                    ),
                  ),
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
