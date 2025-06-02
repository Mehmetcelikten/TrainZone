class Plan {
  String id;
  String name;
  List<String> exercises;

  Plan({
    required this.id,
    required this.name,
    required this.exercises,
  });

  // JSON'dan Plan modeline dönüştürme
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'], // MongoDB'den gelen '_id' alanını kullanıyoruz
      name: json['name'],
      exercises: List<String>.from(
          json['exercises'] ?? []), // exercises alanı varsa al
    );
  }

  // Plan modelini JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises,
    };
  }
}
