import 'dart:convert';
import 'package:http/http.dart' as http;

class TrefleApiService {
  static const String _apiKey = "Li9T6Q-Z5p9ZfAeOyKKKJMUPUbI0sr7JFYWavXwJ2yk";
  static const String _baseUrl = "https://trefle.io/api/v1/plants";

  /// Récupère une liste de plantes avec pagination
  Future<List<dynamic>> fetchPlants({int page = 1}) async {
    return _getPlantsData("$_baseUrl?token=$_apiKey&page=$page");
  }

  /// Recherche une plante par nom
  Future<List<dynamic>> searchPlants(String query) async {
    if (query.isEmpty) return fetchPlants(); // Si la recherche est vide, on récupère toutes les plantes
    final url = "$_baseUrl/search?token=$_apiKey&q=${Uri.encodeComponent(query)}";
    return _getPlantsData(url);
  }

  /// Méthode privée pour gérer les requêtes HTTP
  Future<List<dynamic>> _getPlantsData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception("Erreur ${response.statusCode} : Impossible de charger les données.");
      }
    } catch (e) {
      print("Erreur de chargement : $e");
      return [];
    }
  }
}
