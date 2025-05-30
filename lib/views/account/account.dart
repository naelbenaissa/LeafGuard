import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/account/appbar/account_appbar.dart';
import 'package:ui_leafguard/views/account/widgets/sections/change_profile_picture_section.dart';
import 'package:ui_leafguard/views/account/widgets/sections/delete_account_section.dart';
import 'package:ui_leafguard/views/account/widgets/sections/logout_section.dart';
import 'package:ui_leafguard/views/account/widgets/sections/notifications_section.dart';
import 'package:ui_leafguard/views/account/widgets/sections/password_section.dart';
import 'package:ui_leafguard/views/account/widgets/sections/profile_section.dart';
import '../../services/user_service.dart';
import '../bar/custom_bottombar.dart';

/// Page du compte utilisateur affichant les sections de profil, paramètres et actions.
/// Gère le chargement des données utilisateur, l'état d'expansion des sections,
/// ainsi que la navigation et l'affichage conditionnel des composants.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _expandedSection; // Section actuellement déployée
  Map<String, dynamic>? _userData; // Données utilisateur récupérées
  bool _isLoading = true; // Indicateur de chargement
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Chargement initial des données utilisateur
  }

  /// Récupère les données utilisateur à partir du service Supabase
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

  /// Gère l'ouverture/fermeture des sections extensibles
  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AccountAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Affichage pendant le chargement
          : _userData == null
          ? const Center(child: Text("Utilisateur non trouvé")) // Gestion erreur utilisateur non trouvé
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileSection(userData: _userData),
            const SizedBox(height: 20),
            const Divider(color: Colors.green, thickness: 2),
            ChangeProfilePictureSection(
              userData: _userData,
              onUpdate: _loadUserData,
              isExpanded: _expandedSection == "profile_picture",
              onTap: () => _toggleSection("profile_picture"),
            ),
            ChangePasswordSection(
              isExpanded: _expandedSection == "password",
              onTap: () => _toggleSection("password"),
            ),
            NotificationsSection(
              isExpanded: _expandedSection == "notifications",
              onTap: () => _toggleSection("notifications"),
            ),
            const DeleteAccountSection(),
            const LogoutSection(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
