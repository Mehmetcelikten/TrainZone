import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan.dart';
// Plan modelini içe aktarın

class PlanService {
  static const String baseUrl =
      'http://localhost:3000/api/users'; // Base URL, backend'e uygun olarak düzenlenmeli

  /// Kullanıcının tüm fitness planlarını getir
  static Future<List<Plan>> fetchUserPlans(String userId, String token) async {
    final url = Uri.parse('$baseUrl/$userId/plans'); // API URL'si

    try {
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
            .map((e) => Plan.fromJson(e))
            .toList(); // Plan modeliyle veriyi eşle
      } else {
        throw Exception(
            'Fitness planları alınamadı. Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fitness planları alınamadı: $e');
    }
  }

  /// Yeni bir fitness planı oluştur
  static Future<Plan> createPlan(String userId, Plan plan, String token) async {
    final url = Uri.parse('$baseUrl/$userId/plans'); // API URL'si

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body:
            jsonEncode(plan.toJson()), // Plan verilerini JSON formatında gönder
      );

      if (response.statusCode == 201) {
        return Plan.fromJson(
            json.decode(response.body)); // Plan oluşturulduysa geri döndür
      } else {
        throw Exception(
            'Plan oluşturulamadı. Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Plan oluşturulamadı: $e');
    }
  }

  /// Var olan bir fitness planını güncelle
  static Future<Plan> updatePlan(
      String userId, String planId, Plan plan, String token) async {
    final url = Uri.parse(
        '$baseUrl/$userId/plans/$planId'); // Plan ID'si ile URL'yi oluştur

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(plan.toJson()), // Güncellenmiş plan verilerini gönder
      );

      if (response.statusCode == 200) {
        return Plan.fromJson(
            json.decode(response.body)); // Plan güncellenmişse geri döndür
      } else {
        throw Exception(
            'Plan güncellenemedi. Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Plan güncellenemedi: $e');
    }
  }

  /// Fitness planını sil
  static Future<void> deletePlan(
      String userId, String planId, String token) async {
    final url = Uri.parse(
        '$baseUrl/$userId/plans/$planId'); // Plan ID'si ile URL'yi oluştur

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Plan silinemedi. Hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Plan silinemedi: $e');
    }
  }
}
