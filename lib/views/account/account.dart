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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final userService = UserService();
      final data = await userService.fetchUserData(user.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AccountAppBar(),
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

                      // Changer le mot de passe
                      ListTile(
                        leading: Icon(Icons.lock,
                            color: _expandedSection == "password"
                                ? Colors.green
                                : Colors.black),
                        title: const Text("Changer le mot de passe"),
                        onTap: () => _toggleSection("password"),
                      ),
                      if (_expandedSection == "password")
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: "Ancien mot de passe"),
                              ),
                              const TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: "Nouveau mot de passe"),
                              ),
                              const TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: "Répétez le mot de passe"),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Modifier")),
                            ],
                          ),
                        ),

                      // Notifications
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
