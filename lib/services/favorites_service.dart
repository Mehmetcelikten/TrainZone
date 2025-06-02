import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favorite_list.dart';
import '../models/exercise.dart';

class FavoritesService {
  static const String baseUrl = 'http://localhost:3000/api/users';

  /// 🔁 Klasik favori listeleri getir
  static Future<List<FavoriteList>> fetchUserLists(
      String userId, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print("🧪 Favori listeler geldi: ${jsonData.length} adet");

      return jsonData
          .where((e) => e != null && e is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => FavoriteList.fromJson(e))
          .toList();
    } else {
      throw Exception(
          'Favori listeleri alınamadı. Kod: ${response.statusCode}');
    }
  }

  static Future<List<FavoriteList>> fetchFavoriteBalancedLists(
      String userId, String token) async {
    final url = Uri.parse('$baseUrl/$userId/balanced-favorites');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .where((e) => e['listId'] != null)
          .map((e) => FavoriteList.fromJson(e))
          .toList();
    } else {
      throw Exception(
          'Balanced favoriler alınamadı. Kod: ${response.statusCode}');
    }
  }

  /// ➕ Yeni klasik favori listesi oluştur
  static Future<FavoriteList> createFavoriteList(
      String userId, String name, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return FavoriteList.fromJson(jsonData['createdList']);
    } else {
      throw Exception(
          'Favori listesi oluşturulamadı. Kod: ${response.statusCode}');
    }
  }

  /// ➕ BalancedList üzerinden klasik favori oluştur
  static Future<void> addFullListToFavorites({
    required String userId,
    required String token,
    required String listName,
    required List<Exercise> exercises,
  }) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/full-list');

    final exerciseIds = exercises.map((e) => e.id).toList();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': listName,
        'exerciseIds': exerciseIds,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Liste favorilere eklenemedi. Kod: ${response.statusCode}');
    }
  }

  /// ➕ Egzersiz listeye ekle
  static Future<void> addExerciseToList(
      String userId, String listId, String exerciseId, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/$listId/exercises');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'exerciseId': exerciseId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Egzersiz eklenemedi. Kod: ${response.statusCode}');
    }
  }

  /// 🟨 Liste adını güncelle
  static Future<void> renameFavoriteList(
      String userId, String listId, String newName, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/$listId/rename');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'newName': newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Liste adı güncellenemedi. Kod: ${response.statusCode}');
    }
  }

  /// 🗑️ Favori listeyi sil
  static Future<void> deleteFavoriteList(
      String userId, String listId, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/$listId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Favori listesi silinemedi. Kod: ${response.statusCode}');
    }
  }

  /// 🟨 Liste rengi güncelle
  static Future<void> updateFavoriteListColor(
      String userId, String listId, String newColor, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/$listId/color');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'newColor': newColor}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Liste rengi güncellenemedi. Kod: ${response.statusCode}');
    }
  }

  static Future<List<Exercise>> fetchExercisesByListId(
      String userId, String listId, String token) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/$listId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> exerciseList = data['exercises'];
      return exerciseList.map((e) {
        final ex = (e is Map && e['exerciseId'] is Map) ? e['exerciseId'] : e;
        return Exercise.fromJson(ex);
      }).toList();
    } else {
      throw Exception(
          'Liste egzersizleri alınamadı. Kod: ${response.statusCode}');
    }
  }

  /// 🔁 Toggle klasik favori listesi (BalancedList ID ile)
  static Future<void> toggleFavoriteList({
    required String userId,
    required String token,
    required String listId,
  }) async {
    final url = Uri.parse('$baseUrl/$userId/favorites/$listId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Favori listesi güncellenemedi. Kod: ${response.statusCode}');
    }
  }

  /// 🔁 Toggle balanced favori listesi
  static Future<void> toggleFavoriteBalancedList({
    required String userId,
    required String token,
    required String listId,
  }) async {
    final url = Uri.parse('$baseUrl/$userId/balanced-favorites/$listId');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Balanced favori listesi güncellenemedi. Kod: ${response.statusCode}');
    }
  }
}
