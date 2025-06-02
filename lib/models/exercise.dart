class Exercise {
  final String id;
  final String name;
  final String level;
  final String equipment;
  final int sets;
  final int reps;
  final double rating;
  final List<String> images;
  final String muscle;
  final String description;

  Exercise({
    required this.id,
    required this.name,
    required this.level,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.rating,
    required this.images,
    required this.muscle,
    required this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Eğer favori listeden geliyorsa, json = { "exerciseId": { ...gerçek veri... } }
    final data = json['exerciseId'] ?? json;

    return Exercise(
      id: data['_id']?.toString() ?? '',
      name: data['name'] ?? '',
      level: data['level'] ?? '',
      equipment: data['equipment'] ?? '',
      sets: (data['sets'] ?? 3) as int,
      reps: (data['reps'] ?? 10) as int,
      rating: (data['rating'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      muscle: data['muscle'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'equipment': equipment,
      'sets': sets,
      'reps': reps,
      'rating': rating,
      'images': images,
      'muscle': muscle,
      'description': description,
    };
  }
}
