import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/exercise.dart';
import '../../models/favorite_list.dart';
import '../../services/exercise_service.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../widgets/exercise_info_card.dart';
import '../exercises/exercise_detail_page.dart';

class MuscleDetailPage extends StatefulWidget {
  final String muscleGroup;

  const MuscleDetailPage({super.key, required this.muscleGroup});

  @override
  State<MuscleDetailPage> createState() => _MuscleDetailPageState();
}

class _MuscleDetailPageState extends State<MuscleDetailPage> {
  List<Exercise> exercises = [];
  List<FavoriteList> userBalancedLists = [];
  String? userId;
  String? token;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchExercises();
    _loadFavorites();
  }

  Future<void> fetchExercises() async {
    try {
      final all = await ExerciseService.fetchExercises();
      setState(() {
        exercises = all
            .where((ex) =>
                ex.muscle.toLowerCase() == widget.muscleGroup.toLowerCase())
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Egzersiz çekme hatası: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = await AuthService.isLoggedIn();

    if (!isLogged) return;

    userId = prefs.getString('userId');
    token = prefs.getString('authToken');

    if (userId == null || token == null) return;

    try {
      final balanced =
          await FavoritesService.fetchFavoriteBalancedLists(userId!, token!);

      setState(() {
        userBalancedLists = balanced;
        isFavorite = balanced.any((list) =>
            list.name.toLowerCase().contains(widget.muscleGroup.toLowerCase()));
      });
    } catch (e) {
      debugPrint('❌ Favori kontrolü başarısız: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (userId == null || token == null) return;

    try {
      final matchedList = userBalancedLists.firstWhere(
        (list) =>
            list.name.toLowerCase().contains(widget.muscleGroup.toLowerCase()),
        orElse: () => FavoriteList(
          id: '',
          name: '',
          color: '',
          exercises: [],
        ),
      );

      if (matchedList.id.isEmpty) return;

      await FavoritesService.toggleFavoriteBalancedList(
        userId: userId!,
        token: token!,
        listId: matchedList.id,
      );

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      debugPrint('❌ Favori toggle hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.muscleGroup} Egzersizleri'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : exercises.isEmpty
              ? const Center(
                  child: Text('Egzersiz bulunamadı.',
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    return ExerciseInfoCard(
                      name: ex.name,
                      muscleGroup: ex.muscle,
                      difficulty: ex.level,
                      equipment: ex.equipment,
                      imageUrl: ex.images.isNotEmpty
                          ? ex.images.first
                          : 'https://via.placeholder.com/100',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailPage(exercise: ex),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
