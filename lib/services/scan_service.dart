import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanService {
  final SupabaseClient supabase;

  // Injection du client Supabase pour accès aux opérations backend
  ScanService(this.supabase);

  /// Ajoute un nouveau scan dans la base avec image, prédictions, confiance et criticité.
  /// Gère la récupération de l'utilisateur connecté et l'upload de l'image.
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

      // Upload de l'image et récupération de son URL publique
      String imageUrl = await uploadImage(imageFile, userId);

      // Insertion du scan dans la table 'scans'
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

  /// Récupère la criticité associée à une maladie donnée depuis la table 'diseases'.
  /// Retourne null si aucune donnée trouvée.
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

  /// Upload une image dans le stockage Supabase sous un chemin spécifique à l'utilisateur.
  /// Retourne l'URL publique accessible de l'image.
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

  /// Récupère la liste des scans de l'utilisateur connecté, triés par date décroissante.
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

  /// Supprime un scan ainsi que l'image associée dans le stockage.
  /// Vérifie la correspondance avec l'utilisateur connecté pour sécuriser la suppression.
  Future<void> deleteScan(String scanId, String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Utilisateur non connecté !");
      }

      // Suppression de la ligne du scan dans la base de données
      await supabase
          .from('scans')
          .delete()
          .match({'id': scanId, 'user_id': userId});

      // Extraction du chemin relatif dans le bucket de stockage à partir de l'URL publique
      final String storagePath =
          imageUrl.split('/storage/v1/object/public/').last;

      // Suppression du fichier image dans le stockage Supabase
      await supabase.storage.from('scans').remove([storagePath]);
    } catch (e) {
      throw Exception("Erreur lors de la suppression du scan: $e");
    }
  }
}
