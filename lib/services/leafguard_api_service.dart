import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class IaLeafguardService {
  static const String _predictUrl = "https://ialeafguard-production.up.railway.app/predict/";

  /// Envoie une image et retourne la prédiction de l'IA
  Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(_predictUrl));

      // Ajoute l'image en multipart/form-data
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Envoye la requête
      var response = await request.send();

      // Vérifie si la requête est réussie
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        throw Exception("Erreur lors de la prédiction : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion à l'IA : $e");
    }
  }
}
