import 'exercise.dart';

class FavoriteList {
  final String id;
  String name;
  final String color;
  final List<Exercise> exercises;
  final String? createdAt;

  FavoriteList({
    required this.id,
    required this.name,
    required this.color,
    required this.exercises,
    this.createdAt,
  });
  factory FavoriteList.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("Geçersiz veri: json null geldi");
    }

    // 👇 Balanced listeler listId içinde gelir
    final dynamic listData = json['listId'] is Map ? json['listId'] : json;

    // 🧪 Log: gelen liste adı
    print("📥 Liste Adı: ${json['name'] ?? listData['name'] ?? 'Bilinmiyor'}");

    // ⚠️ Egzersiz alanını al, yoksa boş liste yap
    final List rawExercises = (listData['exercises'] ?? []) as List;

    final parsedExercises = rawExercises.map<Exercise>((e) {
      dynamic exerciseData;

      // ✅ Eğer Map ve içinde exerciseId varsa
      if (e is Map && e.containsKey('exerciseId')) {
        exerciseData = e['exerciseId'];
      } else {
        exerciseData = e;
      }

      if (exerciseData is Map<String, dynamic>) {
        return Exercise.fromJson(exerciseData);
      }

      if (exerciseData is String) {
        // ID geldiyse dummy oluştur
        return Exercise(
          id: exerciseData,
          name: 'Egzersiz',
          level: '',
          equipment: '',
          sets: 0,
          reps: 0,
          rating: 0,
          images: [],
          muscle: '',
          description: '',
        );
      }

      // 👎 Tanınmayan format — fallback
      return Exercise(
        id: '',
        name: 'Geçersiz Egzersiz',
        level: '',
        equipment: '',
        sets: 0,
        reps: 0,
        rating: 0,
        images: [],
        muscle: '',
        description: '',
      );
    }).toList();

    return FavoriteList(
      id: listData['_id']?.toString() ?? json['listId']?.toString() ?? '',
      name: json['name'] ?? listData['name'] ?? 'İsimsiz Liste',
      color: listData['color'] ?? '#FFFFFF',
      exercises: parsedExercises,
      createdAt: listData['createdAt'],
    );
  }
}
