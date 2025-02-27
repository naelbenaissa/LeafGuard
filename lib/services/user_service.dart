import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Récupère les informations de l'utilisateur à partir de son UUID
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

  /// Change le mot de passe de l'utilisateur
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


  /// Génère une URL d'image de profil aléatoire entre `user_1.jpg` et `user_10.jpg`
  String _getRandomProfileImage() {
    final int randomIndex = Random().nextInt(10) + 1;
    return "https://xweiounkhqtchlapjazt.supabase.co/storage/v1/object/public/profil_picture/user_$randomIndex.jpg";
  }

  /// Ajoute un nouvel utilisateur dans la table "users"
  Future<void> addUserData(String userId, String email, String name, String surname, String phone, String? birthdate) async {
    try {
      await _client.from('users').insert({
        'user_id': userId,
        'email': email,
        'last_name': name,
        'first_name': surname,
        'phone_number': phone.isNotEmpty ? phone : null,
        'birthdate': birthdate,
        'username': name,
        'profile_image': _getRandomProfileImage(),
      });
    } catch (error) {
      print("Erreur lors de l'ajout de l'utilisateur : $error");
    }
  }

  /// Récupère les URLs des 10 images de profil disponibles
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

  /// Supprime définitevement un compte
  Future<void> deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw "Utilisateur non connecté.";
    }

    try {
      final client = Supabase.instance.client;

      // Supprime les tâches associées à l'utilisateur
      await client.from('tasks').delete().eq('user_id', user.id);
      await client.from('favorites').delete().eq('user_id', user.id);
      await client.from('scans').delete().eq('user_id', user.id);


      // Supprime les données utilisateur de la table "users"
      await client.from('users').delete().eq('user_id', user.id);

      // Supprime le compte de auth.users en appelant la fonction SQL
      await client.rpc('delete_user_account', params: {'user_id': user.id});

      // Déconnecte l'utilisateur après suppression
      await client.auth.signOut();
    } catch (error) {
      throw "Erreur lors de la suppression du compte : $error";
    }
  }

}
