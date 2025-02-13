import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final SupabaseClient supabase;

  FavoriteService(this.supabase);

  Future<void> addFavorite(String userId, int plantId) async {
    final response = await supabase.from('favorites').insert({
      'user_id': userId,
      'plant_id': plantId,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.error != null) {
      throw Exception('Erreur lors de l\'jout de la plante: ${response.error!.message}');
    }
  }

  Future<void> removeFavorite(String userId, int plantId) async {
    final response = await supabase.from('favorites')
        .delete()
        .match({'user_id': userId, 'plant_id': plantId});

    if (response.error != null) {
      throw Exception('Erreur lors de la suppression de la plante: ${response.error!.message}');
    }
  }
}