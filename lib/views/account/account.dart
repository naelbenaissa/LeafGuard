import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../home/bar/custom_bottombar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _expandedSection;
  String? _selectedNotification;

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text("Mon Compte"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile_placeholder.png"),
            ),
            const SizedBox(height: 20),
            const Text("John Doe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("johndoe@example.com", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.green),
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
                      decoration: InputDecoration(labelText: "Ancien mot de passe"),
                    ),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Nouveau mot de passe"),
                    ),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Répétez le mot de passe"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: () {}, child: const Text("Modifier")),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text("Gérer les notifications"),
              onTap: () => _toggleSection("notifications"),
            ),
            if (_expandedSection == "notifications")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    RadioListTile(
                      title: const Text("Toutes les notifications"),
                      value: "all",
                      groupValue: _selectedNotification,
                      onChanged: (value) => setState(() => _selectedNotification = value),
                    ),
                    RadioListTile(
                      title: const Text("Seulement les messages importants"),
                      value: "important",
                      groupValue: _selectedNotification,
                      onChanged: (value) => setState(() => _selectedNotification = value),
                    ),
                    RadioListTile(
                      title: const Text("Aucune notification"),
                      value: "none",
                      groupValue: _selectedNotification,
                      onChanged: (value) => setState(() => _selectedNotification = value),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.green),
              title: const Text("Se déconnecter"),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
