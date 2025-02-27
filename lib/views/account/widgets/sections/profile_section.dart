import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileSection({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: userData!["profile_image"] != null
              ? NetworkImage(userData!["profile_image"])
              : const AssetImage("assets/img/slogan/pepper_slogan.png")
          as ImageProvider,
        ),
        const SizedBox(height: 20),
        Text(
          "${userData!["first_name"]} ${userData!["last_name"]}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(userData!["email"], style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
