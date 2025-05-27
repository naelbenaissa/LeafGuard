import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ui_leafguard/services/trefle_api_service.dart';

void main() {
  late TrefleApiService apiService;

  // Exemple de payloads réutilisables
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

  group('TrefleApiService', () {
    test('retourne une liste de plantes quand la réponse est OK sans query', () async {
      // Arrange : mock client retourne liste de plantes
      final mockClient = MockClient((request) async {
        return http.Response(json.encode(plantsResponse), 200);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act
      final result = await apiService.fetchPlants(page: 1);

      // Assert
      expect(result['data'], isA<List>());
      expect(result['data'].length, 2);
      expect(result['total'], 2);
    });

    test('retourne une liste filtrée quand query est fournie', () async {
      // Arrange : mock client retourne une seule plante pour une recherche
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

      // Act
      final result = await apiService.fetchPlants(page: 1, query: 'daisy');

      // Assert
      expect(result['data'], isA<List>());
      expect(result['data'][0]['common_name'], 'Daisy');
      expect(result['total'], 1);
    });

    test('retourne une liste vide et total 0 en cas d\'erreur HTTP', () async {
      // Arrange : mock client retourne une erreur
      final mockClient = MockClient((request) async {
        return http.Response('Erreur', 500);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act
      final result = await apiService.fetchPlants();

      // Assert
      expect(result['data'], isEmpty);
      expect(result['total'], 0);
    });

    test('retourne les détails d\'une plante quand la réponse est OK', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response(json.encode(plantDetailsResponse), 200);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act
      final result = await apiService.fetchPlantDetails(5);

      // Assert
      expect(result, isNotNull);
      expect(result!['common_name'], 'Sunflower');
    });

    test('retourne null en cas d\'erreur lors de la récupération des détails', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response('Erreur', 404);
      });

      apiService = TrefleApiService(client: mockClient);

      // Act
      final result = await apiService.fetchPlantDetails(9999);

      // Assert
      expect(result, isNull);
    });
  });
}
