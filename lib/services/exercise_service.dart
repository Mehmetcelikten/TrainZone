import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';

class ExerciseService {
  static const String baseUrl = 'http://localhost:3000/api/exercises';

  static Future<List<Exercise>> fetchExercises({
    String? muscle,
    String? level,
    String? equipment,
  }) async {
    final queryParams = {
      if (muscle != null && muscle.isNotEmpty) 'muscle': muscle,
      if (level != null && level.isNotEmpty) 'level': level,
      if (equipment != null && equipment.isNotEmpty) 'equipment': equipment,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception('Egzersiz verileri alınamadı');
    }
  }

  static Future<List<Exercise>> fetchPopularExercises() async {
    final uri = Uri.parse('$baseUrl/popular');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception('Popüler egzersizler alınamadı');
    }
  }

  static Future<List<Exercise>> fetchByNames(List<String> names) async {
    if (names.isEmpty) return [];

    final uri = Uri.parse('$baseUrl/by-names');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'names': names}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception('İsimlere göre egzersizler alınamadı');
    }
  }

  static Future<void> updateRating(
    String exerciseId,
    double rating,
    String userId,
  ) async {
    final uri = Uri.parse('$baseUrl/$exerciseId/rating');

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Rating güncellenemedi');
    }
  }

  static Future<Exercise> fetchExerciseById(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Exercise.fromJson(data);
    } else {
      throw Exception('Egzersiz alınamadı');
    }
  }
}
