import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/user_service.dart';

class ProfileButton extends StatefulWidget {
  const ProfileButton({super.key});

  @override
  _ProfileButtonState createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
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

    return GestureDetector(
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
    );
  }
}