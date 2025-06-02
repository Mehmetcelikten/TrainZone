import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/exercise.dart';
import '../../models/favorite_list.dart';
import '../../services/balanced_list_service.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../widgets/exercise_info_card.dart';

class BalancedExerciseListPage extends StatefulWidget {
  final String muscle;

  const BalancedExerciseListPage({super.key, required this.muscle});

  @override
  State<BalancedExerciseListPage> createState() =>
      _BalancedExerciseListPageState();
}

class _BalancedExerciseListPageState extends State<BalancedExerciseListPage> {
  List<Exercise> exercises = [];
  bool isLoading = true;
  String errorMessage = '';
  String? userId;
  String? token;
  bool isFavorite = false;
  String? listId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserInfo();
    await _loadBalancedList();
    await _loadUserFavorites();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('authToken');
  }

  Future<void> _loadBalancedList() async {
    try {
      final list = await BalancedListService.fetchListByName(widget.muscle);
      listId = list.id;
      _updateState(list.exercises);
    } catch (e) {
      debugPrint('Egzersiz çekme hatası: $e');
      _updateState([], error: e.toString());
    }
  }

  Future<void> _loadUserFavorites() async {
    if (userId == null || token == null) return;

    try {
      final lists =
          await FavoritesService.fetchFavoriteBalancedLists(userId!, token!);
      setState(() {
        isFavorite = lists.any((l) => l.id == listId);
      });
    } catch (e) {
      debugPrint('Favori listeler alınamadı: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (userId == null || token == null || listId == null) return;

    try {
      await FavoritesService.toggleFavoriteBalancedList(
        userId: userId!,
        token: token!,
        listId: listId!,
      );

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      debugPrint('Toggle hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favori güncellenemedi: $e')),
      );
    }
  }

  void _updateState(List<Exercise> fetched, {String? error}) {
    if (mounted) {
      setState(() {
        exercises = fetched;
        isLoading = false;
        errorMessage = error ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.muscle),
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
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : exercises.isEmpty
                  ? const Center(child: Text('Egzersiz bulunamadı.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final ex = exercises[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExerciseInfoCard(
                            name: ex.name,
                            muscleGroup: ex.muscle,
                            difficulty: ex.level,
                            equipment: ex.equipment,
                            imageUrl: ex.images.isNotEmpty
                                ? ex.images.first
                                : 'https://via.placeholder.com/150',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/exercise_detail',
                                arguments: ex,
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
