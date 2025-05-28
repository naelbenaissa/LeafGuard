import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Récupère les données utilisateur à partir de son UUID unique
  Future<Map<String, dynamic>?> fetchUserData(String uuid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('user_id', uuid)
          .single();

      return response.isNotEmpty ? response : null;
    } catch (error) {
      return null;
    }
  }

  /// Modifie le mot de passe de l'utilisateur actuellement connecté
  Future<void> changePassword(String newPassword) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw "Utilisateur non connecté.";
    }

    final response = await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    if (response.user == null) {
      throw "Erreur lors du changement de mot de passe.";
    }
  }

  /// Génère une URL d'image de profil aléatoire parmi 10 images disponibles
  String _getRandomProfileImage() {
    final int randomIndex = Random().nextInt(10) + 1;
    return "https://xweiounkhqtchlapjazt.supabase.co/storage/v1/object/public/profil_picture/user_$randomIndex.jpg";
  }

  /// Insère un nouvel utilisateur dans la table 'users' avec une image de profil par défaut
  Future<void> addUserData(String userId, String email, String name, String surname, String? phone, String? birthdate) async {
    try {
      await _client.from('users').insert({
        'user_id': userId,
        'email': email,
        'last_name': name,
        'first_name': surname,
        'phone_number': phone,
        'birthdate': birthdate,
        'username': name,
        'profile_image': _getRandomProfileImage(),
      });
    } catch (error) {
      print("Erreur lors de l'ajout de l'utilisateur : $error");
    }
  }

  /// Retourne la liste des URLs des images de profil disponibles
  List<String> getProfileImages() {
    return List.generate(
      10,
          (index) => "https://xweiounkhqtchlapjazt.supabase.co/storage/v1/object/public/profil_picture/user_${index + 1}.jpg",
    );
  }

  /// Met à jour l'image de profil de l'utilisateur dans la base de données
  Future<void> updateProfileImage(String userId, String newImageUrl) async {
    try {
      await _client.from('users').update({'profile_image': newImageUrl}).eq('user_id', userId);
    } catch (error) {
      print("Erreur lors de la mise à jour de l'image de profil : $error");
    }
  }

  /// Vérifie que l'ancien mot de passe est correct en tentant une connexion
  Future<bool> verifyOldPassword(String oldPassword) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: oldPassword,
      );

      return response.user != null;
    } catch (error) {
      return false;
    }
  }

  /// Supprime définitivement un compte utilisateur et toutes ses données associées
  Future<void> deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw "Utilisateur non connecté.";
    }

    try {
      final client = Supabase.instance.client;

      // Suppression des données liées dans différentes tables
      await client.from('tasks').delete().eq('user_id', user.id);
      await client.from('favorites').delete().eq('user_id', user.id);
      await client.from('scans').delete().eq('user_id', user.id);

      // Suppression des données utilisateur principales
      await client.from('users').delete().eq('user_id', user.id);

      // Suppression du compte d'authentification via une fonction stockée SQL
      await client.rpc('delete_user_account', params: {'user_id': user.id});

      // Déconnexion après suppression du compte
      await client.auth.signOut();
    } catch (error) {
      throw "Erreur lors de la suppression du compte : $error";
    }
  }
}
