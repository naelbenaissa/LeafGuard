import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:ui_leafguard/services/leafguard_api_service.dart';

/// Mock de http.Client pour simuler les requêtes HTTP sans les effectuer réellement.
class MockHttpClient extends Mock implements http.Client {}

/// Mock pour http.StreamedResponse, représentant la réponse HTTP reçue sous forme de flux.
class MockStreamedResponse extends Mock implements http.StreamedResponse {}

/// Fake pour http.BaseRequest nécessaire à mocktail
/// afin de matcher les arguments lors de l'utilisation de `any()` dans les mocks.
/// Ceci évite les erreurs liées au typage strict de Dart.
class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late IaLeafguardService service;         // Instance du service à tester
  late MockHttpClient mockHttpClient;      // Client HTTP simulé

  setUpAll(() {
    // Enregistrement de la Fake pour BaseRequest, requis par mocktail
    // Permet de matcher les appels avec des objets BaseRequest dans les tests.
    registerFallbackValue(FakeBaseRequest());
  });

  setUp(() {
    // Initialisation du client mocké et du service avant chaque test
    mockHttpClient = MockHttpClient();
    service = IaLeafguardService(client: mockHttpClient);
  });

  test('predictDisease retourne une map avec la réponse de l\'IA', () async {
    // Préparation d'une fausse image locale pour la prédiction
    final fakeImage = File('assets/img/plantes/nest_fern.png');

    // Simulation d'une réponse HTTP réussie avec un corps JSON encodé
    final mockResponse = MockStreamedResponse();
    final responseBody = jsonEncode({"disease": "blight", "confidence": 0.85});

    // Mock du code HTTP 200 OK
    when(() => mockResponse.statusCode).thenReturn(200);
    // Mock du corps de la réponse sous forme de stream de bytes
    when(() => mockResponse.stream)
        .thenAnswer((_) => http.ByteStream.fromBytes(utf8.encode(responseBody)));

    // Mock de l'envoi de la requête HTTP qui renvoie la réponse simulée
    when(() => mockHttpClient.send(any())).thenAnswer((_) async => mockResponse);

    // Appel de la méthode testée
    final result = await service.predictDisease(fakeImage);

    // Vérification que le résultat est bien une Map et contient les données attendues
    expect(result, isA<Map<String, dynamic>>());
    expect(result['disease'], 'blight');
    expect(result['confidence'], 0.85);

    // Vérification que la méthode send du client HTTP a été appelée exactement une fois
    verify(() => mockHttpClient.send(any())).called(1);
  });

  test('predictDisease lance une exception sur erreur HTTP', () async {
    final fakeImage = File('assets/img/plantes/dahlia.png');

    final mockResponse = MockStreamedResponse();

    // Simulation d'une réponse HTTP avec code d'erreur (500 Internal Server Error)
    when(() => mockResponse.statusCode).thenReturn(500);
    when(() => mockHttpClient.send(any())).thenAnswer((_) async => mockResponse);

    // On s'attend à ce que la méthode lance une exception contenant un message d'erreur spécifique
    expect(
          () => service.predictDisease(fakeImage),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Erreur lors de la prédiction'))),
    );
  });

  test('predictDisease lance une exception en cas de problème réseau', () async {
    final fakeImage = File('assets/img/plantes/dahlia.png');

    // Simulation d'une exception réseau lors de l'envoi de la requête HTTP
    when(() => mockHttpClient.send(any())).thenThrow(Exception("Timeout"));

    // Vérification que la méthode lance bien une exception indiquant un problème de connexion
    expect(
          () => service.predictDisease(fakeImage),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Erreur de connexion'))),
    );
  });
}
