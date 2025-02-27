import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) {
        _loadUserProfile();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final userData = await UserService().fetchUserData(user.id);
      if (mounted && userData != null && userData['profile_image'] != null) {
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
        child: profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileImageUrl!,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
            const Icon(Icons.error, color: Colors.red),
          ),
        )
            : const Icon(Icons.person, size: 28, color: Colors.grey),
      ),
    );
  }
}
