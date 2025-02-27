import 'package:flutter/material.dart';
import '../../../../services/user_service.dart';

class ChangeProfilePictureSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onUpdate;
  final bool isExpanded;
  final VoidCallback onTap;

  const ChangeProfilePictureSection({
    super.key,
    required this.userData,
    required this.onUpdate,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    Future<void> _updateProfileImage(String newImageUrl) async {
      await userService.updateProfileImage(userData!["id"], newImageUrl);
      onUpdate();
    }

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: isExpanded ? Colors.green : Colors.black),
          title: const Text("Changer la photo de profil"),
          onTap: onTap,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: userService.getProfileImages().map((imageUrl) {
                bool isSelected = imageUrl == userData!["profile_image"];
                return GestureDetector(
                  onTap: () => _updateProfileImage(imageUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
