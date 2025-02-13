import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

class ScanService {
  final SupabaseClient supabase;

  ScanService(this.supabase);

  /// Upload l'image et retourne son URL
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}_${basename(imageFile.path)}";
      final String filePath = "scans/$userId/$fileName";

      await supabase.storage.from('scans').upload(filePath, imageFile);

      final String publicUrl = supabase.storage.from('scans').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception("Erreur lors de l'upload de l'image: $e");
    }
  }

  /// Ajoute un scan dans la base de données
  Future<void> addScan({
    required String userId,
    required File imageFile,
    required String predictions,
    required double confidence,
  }) async {
    try {
      String imageUrl = await uploadImage(imageFile, userId);

      await supabase.from('scans').insert({
        'user_id': userId,
        'predictions': predictions,
        'scan_time': DateTime.now().toIso8601String(),
        'confidence': confidence,
        'image_url': imageUrl,
      });
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du scan: $e");
    }
  }

  /// Récupère les scans d'un utilisateur
  Future<List<Map<String, dynamic>>> getScans(String userId) async {
    try {
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
      // Supprimer l'entrée dans la base de données
      await supabase.from('scans').delete().eq('id', scanId);

      // Supprimer l'image de Supabase Storage
      final uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.sublist(2).join('/');
      await supabase.storage.from('scans').remove([filePath]);
    } catch (e) {
      throw Exception("Erreur lors de la suppression du scan: $e");
    }
  }
}
