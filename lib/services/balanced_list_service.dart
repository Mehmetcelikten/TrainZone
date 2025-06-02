import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';
import '../models/favorite_list.dart';

class BalancedListService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// ✅ Liste adına göre ID + egzersizlerle birlikte FavoriteList döner
  static Future<FavoriteList> fetchListByName(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final uri = Uri.parse('$baseUrl/balanced-lists?name=$encodedName');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> exercisesRaw = data['exercises'] ?? [];

        final exercises =
            exercisesRaw.map((e) => Exercise.fromJson(e)).toList();

        return FavoriteList(
          id: data['id'] ?? data['_id'] ?? '',
          name: data['name'] ?? name,
          color: data['color'] ?? '#FF2196F3',
          exercises: exercises,
          createdAt: data['createdAt'],
        );
      } catch (e) {
        throw Exception('Veri çözümleme hatası: $e');
      }
    } else {
      throw Exception('Liste yüklenemedi. Kod: ${response.statusCode}');
    }
  }
}
