import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanService {
  final SupabaseClient supabase;

  ScanService(this.supabase);

  /// Ajoute un scan dans la base de données
  Future<void> addScan({
    required File imageFile,
    required String predictions,
    required double confidence,
    required int criticite,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Utilisateur non connecté !");
      }

      String imageUrl = await uploadImage(imageFile, userId);

      await supabase.from('scans').insert({
        'user_id': userId,
        'predictions': predictions,
        'scan_time': DateTime.now().toIso8601String(),
        'confidence': confidence,
        'image_url': imageUrl,
        'criticite': criticite,
      });
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du scan: $e");
    }
  }

  Future<int?> getCriticiteForDisease(String diseaseName) async {
    final response = await supabase
        .from('diseases')
        .select('criticite')
        .eq('disease_name', diseaseName)
        .maybeSingle();

    if (response != null && response['criticite'] != null) {
      return response['criticite'] as int;
    }
    return null;
  }

  /// Upload l'image et retourne son URL
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      final String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}";
      final String filePath = "scans/$userId/$fileName";

      await supabase.storage.from('scans').upload(filePath, imageFile);

      final String publicUrl =
          supabase.storage.from('scans').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception("Erreur lors de l'upload de l'image: $e");
    }
  }

  /// Récupère les scans d'un utilisateur
  Future<List<Map<String, dynamic>>> getScans() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Utilisateur non connecté !");
      }

      final response = await supabase
          .from('scans')
          .select('*')
          .eq('user_id', userId)
          .order('scan_time', ascending: false);

      return response;
    } catch (e) {
      throw Exception("Erreur lors de la récupération des scans: $e");
    }
  }

  /// Supprime un scan et son image associée
  Future<void> deleteScan(String scanId, String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Utilisateur non connecté !");
      }
      await supabase
          .from('scans')
          .delete()
          .match({'id': scanId, 'user_id': userId});

      final String storagePath =
          imageUrl.split('/storage/v1/object/public/').last;

      await supabase.storage.from('scans').remove([storagePath]);
    } catch (e) {
      throw Exception("Erreur lors de la suppression du scan: $e");
    }
  }
}
