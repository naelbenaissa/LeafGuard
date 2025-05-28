import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final SupabaseClient supabase;

  // Injection du client Supabase pour accès aux opérations sur la base distante
  FavoriteService(this.supabase);

  /// Vérifie si une plante est déjà marquée comme favorite par l'utilisateur.
  /// Retourne true si l'entrée existe, false sinon.
  Future<bool> isFavorite(String userId, int plantId) async {
    final response = await supabase
        .from('favorites')
        .select('id')
        .match({'user_id': userId, 'plant_id': plantId})
        .maybeSingle();

    return response != null;
  }

  /// Ajoute une plante à la liste des favoris de l'utilisateur.
  /// Enregistre la date de création en format ISO 8601.
  Future<void> addFavorite(String userId, int plantId) async {
    await supabase.from('favorites').insert({
      'user_id': userId,
      'plant_id': plantId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Récupère la liste des IDs des plantes favorites pour un utilisateur donné.
  /// Utilisé pour afficher ou synchroniser les favoris côté client.
  Future<List<int>> getFavoritePlantIds(String userId) async {
    final response = await supabase
        .from('favorites')
        .select('plant_id')
        .eq('user_id', userId);

    return response.map<int>((fav) => fav['plant_id'] as int).toList();
  }

  /// Supprime une plante de la liste des favoris de l'utilisateur.
  /// Effectue la suppression en fonction de l'utilisateur et de la plante.
  Future<void> removeFavorite(String userId, int plantId) async {
    await supabase.from('favorites').delete().match({
      'user_id': userId,
      'plant_id': plantId,
    });
  }
}
