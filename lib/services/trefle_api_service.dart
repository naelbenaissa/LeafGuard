import 'dart:convert';
import 'package:http/http.dart' as http;

class TrefleApiService {
  static const String _apiKey = "Li9T6Q-Z5p9ZfAeOyKKKJMUPUbI0sr7JFYWavXwJ2yk";
  static const String _baseUrl = "https://trefle.io/api/v1/plants";

  /// Récupère une liste de plantes via `/search`
  Future<Map<String, dynamic>> fetchPlants({int page = 1, String query = ""}) async {
    String url = query.isEmpty
        ? "$_baseUrl?token=$_apiKey&page=$page"
        : "$_baseUrl/search?token=$_apiKey&q=${Uri.encodeComponent(query)}";

    print("🔗 URL de l'API: $url");
    return _getPlantsData(url);
  }

  /// Méthode privée pour gérer les requêtes HTTP
  Future<Map<String, dynamic>> _getPlantsData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      print("📩 Réponse API: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "data": data['data'] ?? [],
          "total": data['meta']?['total'] ?? 0
        };
      } else {
        throw Exception("Erreur ${response.statusCode} : Impossible de charger les données.");
      }
    } catch (e) {
      print("🚨 Erreur de chargement: $e");
      return {"data": [], "total": 0};
    }
  }

  /// Récupère les détails d'une plante via son ID
  Future<Map<String, dynamic>?> fetchPlantDetails(int plantId) async {
    String url = "$_baseUrl/$plantId?token=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      print("📩 Réponse API: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // Retourne directement les détails de la plante
      } else {
        throw Exception("Erreur ${response.statusCode} : Impossible de charger la plante.");
      }
    } catch (e) {
      print("🚨 Erreur de chargement: $e");
      return null;
    }
  }
}
