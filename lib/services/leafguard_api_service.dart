import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class IaLeafguardService {
  // URL de l'API d'IA pour la prédiction des maladies à partir d'une image
  static const String _predictUrl = "https://fastapi-app-72575665998.us-central1.run.app/predict/";

  final http.Client client;

  // Injection possible d'un client HTTP, ou création d'un client par défaut
  IaLeafguardService({http.Client? client}) : client = client ?? http.Client();

  /// Envoie une image à l'API d'IA pour prédire la maladie de la plante.
  /// Retourne un Map contenant les résultats décodés en JSON.
  /// Lance une exception en cas d'erreur réseau ou code HTTP != 200.
  Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(_predictUrl));

      // Ajout du fichier image dans la requête multipart/form-data
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Envoi de la requête
      var streamedResponse = await client.send(request);

      // Vérification du succès de la requête
      if (streamedResponse.statusCode == 200) {
        var responseData = await streamedResponse.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        throw Exception("Erreur lors de la prédiction : ${streamedResponse.statusCode}");
      }
    } catch (e) {
      // Gestion des erreurs réseau ou exceptions inattendues
      throw Exception("Erreur de connexion à l'IA : $e");
    }
  }
}
