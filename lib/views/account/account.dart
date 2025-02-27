import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/account/appbar/account_appbar.dart';
import '../../services/user_service.dart';
import '../bar/custom_bottombar.dart';
import '../widgets/notification_settings.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _expandedSection;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final UserService _userService = UserService();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final data = await _userService.fetchUserData(user.id);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  Future<void> _updateProfileImage(String newImageUrl) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _userService.updateProfileImage(user.id, newImageUrl);
      setState(() {
        _userData?["profile_image"] = newImageUrl;
      });
    }
  }

  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les nouveaux mots de passe ne correspondent pas.")),
      );
      return;
    }

    try {
      await _userService.changePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe mis à jour avec succès !")),
      );
      _toggleSection("password");
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AccountAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text("Utilisateur non trouvé"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _userData!["profile_image"] != null
                  ? NetworkImage(_userData!["profile_image"])
                  : const AssetImage(
                  "assets/img/slogan/pepper_slogan.png")
              as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              "${_userData!["first_name"]} ${_userData!["last_name"]}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_userData!["email"],
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Divider(color: Colors.green, thickness: 2),

            // Section Changer la photo de profil
            ListTile(
              leading: Icon(Icons.person,
                  color: _expandedSection == "profile_picture"
                      ? Colors.green
                      : Colors.black),
              title: const Text("Changer la photo de profil"),
              onTap: () => _toggleSection("profile_picture"),
            ),
            if (_expandedSection == "profile_picture")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _userService.getProfileImages().map((imageUrl) {
                    bool isSelected = imageUrl == _userData!["profile_image"];
                    return GestureDetector(
                      onTap: () => _updateProfileImage(imageUrl),
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: Colors.green, width: 3)
                              : null,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ListTile(
              leading: Icon(Icons.lock,
                  color: _expandedSection == "password" ? Colors.green : Colors.black),
              title: const Text("Changer le mot de passe"),
              onTap: () => _toggleSection("password"),
            ),
            if (_expandedSection == "password")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Ancien mot de passe"),
                    ),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Répétez le mot de passe"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _changePassword,
                      child: const Text("Modifier"),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: Icon(Icons.notifications,
                  color: _expandedSection == "notifications"
                      ? Colors.green
                      : Colors.black),
              title: const Text("Gérer les notifications"),
              onTap: () => _toggleSection("notifications"),
            ),
            if (_expandedSection == "notifications")
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    NotificationSettings(),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Supprimer mon compte"),
              onTap: () async {
                bool? confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Supprimer définitivement votre compte ?"),
                      content: const Text(
                          "Cette action est irréversible. Toutes vos données seront définitivement supprimées."
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Annuler"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );

                if (confirmDelete == true) {
                  try {
                    await _userService.deleteAccount();
                    if (mounted) {
                      GoRouter.of(context).go('/auth'); // Redirige vers la page d'authentification après suppression
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur : $error")),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Se déconnecter"),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  GoRouter.of(context).go('/auth');
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}