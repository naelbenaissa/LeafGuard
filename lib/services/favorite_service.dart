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

    return response != null;
  }

  /// Ajoute une plante aux favoris
  Future<void> addFavorite(String userId, int plantId) async {
    await supabase.from('favorites').insert({
      'user_id': userId,
      'plant_id': plantId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Récupère la liste des IDs des plantes favorites d'un utilisateur
  Future<List<int>> getFavoritePlantIds(String userId) async {
    final response = await supabase
        .from('favorites')
        .select('plant_id')
        .eq('user_id', userId);

    return response.map<int>((fav) => fav['plant_id'] as int).toList();
  }

  /// Supprime une plante des favoris
  Future<void> removeFavorite(String userId, int plantId) async {
    await supabase.from('favorites').delete().match({
      'user_id': userId,
      'plant_id': plantId,
    });
  }
}
