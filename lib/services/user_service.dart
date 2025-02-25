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

      if (response.isNotEmpty) {
        return response;
      } else {
        return null;
      }
    } catch (error) {
      return null;
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
}
