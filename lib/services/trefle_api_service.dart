import 'dart:convert';
import 'package:http/http.dart' as http;

class TrefleApiService {
  static const String _apiKey = "Li9T6Q-Z5p9ZfAeOyKKKJMUPUbI0sr7JFYWavXwJ2yk";
  static const String _baseUrl = "https://trefle.io/api/v1/plants";

  final http.Client httpClient;

  // Injection du client HTTP, par défaut http.Client standard
  TrefleApiService({http.Client? client}) : httpClient = client ?? http.Client();

  /// Récupère une liste de plantes, avec pagination et possibilité de recherche par nom.
  /// Retourne une Map contenant une liste de données et un total.
  Future<Map<String, dynamic>> fetchPlants({int page = 1, String query = ""}) async {
    final url = query.isEmpty
        ? "$_baseUrl?token=$_apiKey&page=$page"
        : "$_baseUrl/search?token=$_apiKey&q=${Uri.encodeComponent(query)}";

    return _getPlantsData(url);
  }

  /// Effectue la requête HTTP GET et traite la réponse JSON.
  Future<Map<String, dynamic>> _getPlantsData(String url) async {
    try {
      final response = await httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "data": data['data'] ?? [],
          "total": data['meta']?['total'] ?? 0,
        };
      } else {
        throw Exception("Erreur ${response.statusCode} : Impossible de charger les données.");
      }
    } catch (e) {
      // En cas d'erreur réseau ou parsing, on retourne un résultat vide
      return {"data": [], "total": 0};
    }
  }

  /// Récupère les détails d'une plante par son ID.
  /// Retourne null si la requête échoue ou en cas d'exception.
  Future<Map<String, dynamic>?> fetchPlantDetails(int plantId) async {
    final url = "$_baseUrl/$plantId?token=$_apiKey";

    try {
      final response = await httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception("Erreur ${response.statusCode} : Impossible de charger la plante.");
      }
    } catch (e) {
      return null;
    }
  }
}
