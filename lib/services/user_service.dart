import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

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
      print('Erreur lors de la récupération des données de l\'utilisateur: $error');
      return null;
    }
  }
}