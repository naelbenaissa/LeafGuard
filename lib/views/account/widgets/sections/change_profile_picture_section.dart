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

    Future<void> updateProfileImage(String newImageUrl) async {
      if (userData == null || userData!["user_id"] == null) {
        return;
      }
      if (newImageUrl.isEmpty) {
        return;
      }

      await userService.updateProfileImage(userData!["user_id"], newImageUrl);

      final updatedUserData = await userService.fetchUserData(userData!["user_id"]);

      if (updatedUserData != null) {
        userData?.update("profile_image", (value) => updatedUserData["profile_image"],
            ifAbsent: () => updatedUserData["profile_image"]);
      }

      onUpdate();
    }

    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.person,
            color: isExpanded
                ? Colors.green
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
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
                bool isSelected = imageUrl == userData?["profile_image"];
                return GestureDetector(
                  onTap: () {
                    if (userData?["user_id"] != null && imageUrl.isNotEmpty) {
                      updateProfileImage(imageUrl);
                    }
                  },
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
