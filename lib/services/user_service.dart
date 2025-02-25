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

  /// Ajoute un nouvel utilisateur dans la table "users" CORRIGER NOM COLONNE
  Future<void> addUserData(String userId, String name, String surname, String phone) async {
    try {
      await _client.from('users').insert({
        'user_id': userId,
        'name': name.isNotEmpty ? name : null,
        'surname': surname.isNotEmpty ? surname : null,
        'phone': phone.isNotEmpty ? phone : null,
      });

    } catch (error) {
      print("Erreur lors de l'ajout de l'utilisateur : $error");
    }
  }
}
