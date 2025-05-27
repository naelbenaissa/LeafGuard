import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class IaLeafguardService {
  static const String _predictUrl = "https://fastapi-app-72575665998.us-central1.run.app/predict/";

  final http.Client client;

  IaLeafguardService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(_predictUrl));

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        var responseData = await streamedResponse.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        throw Exception("Erreur lors de la prédiction : ${streamedResponse.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion à l'IA : $e");
    }
  }
}
