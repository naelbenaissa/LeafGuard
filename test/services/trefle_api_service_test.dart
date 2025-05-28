import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ui_leafguard/services/trefle_api_service.dart';

void main() {
  late TrefleApiService apiService;

  // Données simulées pour les réponses d'API (payloads)
  const plantsResponse = {
    "data": [
      {"id": 1, "common_name": "Rose"},
      {"id": 2, "common_name": "Tulip"},
    ],
    "meta": {"total": 2},
  };

  const plantDetailsResponse = {
    "data": {
      "id": 5,
      "common_name": "Sunflower",
      "scientific_name": "Helianthus annuus",
    }
  };

  // Groupe de tests pour TrefleApiService
  group('TrefleApiService', () {
    // Test : récupération des plantes sans recherche (query)
    test('retourne une liste de plantes quand la réponse est OK sans query', () async {
      // Arrange : client HTTP simulé retournant une réponse valide
      final mockClient = MockClient((request) async {
        return http.Response(json.encode(plantsResponse), 200);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act : appel de la méthode fetchPlants
      final result = await apiService.fetchPlants(page: 1);

      // Assert : vérifie que le résultat est correct
      expect(result['data'], isA<List>());
      expect(result['data'].length, 2);
      expect(result['total'], 2);
    });

    // Test : récupération des plantes avec un filtre (query)
    test('retourne une liste filtrée quand query est fournie', () async {
      // Arrange : client HTTP simulé avec une réponse filtrée
      final mockClient = MockClient((request) async {
        final filteredResponse = {
          "data": [
            {"id": 10, "common_name": "Daisy"},
          ],
          "meta": {"total": 1},
        };
        return http.Response(json.encode(filteredResponse), 200);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act : appel avec un mot-clé de recherche
      final result = await apiService.fetchPlants(page: 1, query: 'daisy');

      // Assert : vérifie que seule la plante correspondante est retournée
      expect(result['data'], isA<List>());
      expect(result['data'][0]['common_name'], 'Daisy');
      expect(result['total'], 1);
    });

    // Test : gestion des erreurs HTTP (par exemple erreur 500)
    test('retourne une liste vide et total 0 en cas d\'erreur HTTP', () async {
      // Arrange : simulation d'une erreur serveur
      final mockClient = MockClient((request) async {
        return http.Response('Erreur', 500);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act : appel de l’API
      final result = await apiService.fetchPlants();

      // Assert : le service doit retourner une liste vide et un total de 0
      expect(result['data'], isEmpty);
      expect(result['total'], 0);
    });

    // Test : récupération des détails d'une plante avec succès
    test('retourne les détails d\'une plante quand la réponse est OK', () async {
      // Arrange : réponse détaillée simulée
      final mockClient = MockClient((request) async {
        return http.Response(json.encode(plantDetailsResponse), 200);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act : récupération des détails d'une plante
      final result = await apiService.fetchPlantDetails(5);

      // Assert : vérifie que les bonnes informations sont retournées
      expect(result, isNotNull);
      expect(result!['common_name'], 'Sunflower');
    });

    // Test : gestion d’une erreur lors de la récupération de détails
    test('retourne null en cas d\'erreur lors de la récupération des détails', () async {
      // Arrange : erreur HTTP simulée
      final mockClient = MockClient((request) async {
        return http.Response('Erreur', 404);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act : appel avec un ID inexistant
      final result = await apiService.fetchPlantDetails(9999);

      // Assert : résultat attendu = null
      expect(result, isNull);
    });
  });
}
