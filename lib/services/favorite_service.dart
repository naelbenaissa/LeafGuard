import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final SupabaseClient supabase;

  FavoriteService(this.supabase);

  /// Vérifie si une plante est en favoris
  Future<bool> isFavorite(String userId, int plantId) async {
    final response = await supabase
        .from('favorites')
        .select('id')
        .match({'user_id': userId, 'plant_id': plantId})
        .maybeSingle();

    return response != null; // Retourne `true` si la plante est en favori
  }

  /// Ajoute une plante aux favoris
  Future<void> addFavorite(String userId, int plantId) async {
    await supabase.from('favorites').insert({
      'user_id': userId,
      'plant_id': plantId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Supprime une plante des favoris
  Future<void> removeFavorite(String userId, int plantId) async {
    await supabase.from('favorites').delete().match({
      'user_id': userId,
      'plant_id': plantId,
    });
  }
}
