import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/exercise.dart';
import '../../models/favorite_list.dart';
import '../../services/favorites_service.dart';
import '../../widgets/exercise_info_card.dart';
import '../../screens/exercises/exercise_detail_page.dart';
import '../../screens/map/muscle_map_screen.dart';

class FavoriteDetailPage extends StatefulWidget {
  final FavoriteList favoriteList;

  const FavoriteDetailPage({super.key, required this.favoriteList});

  @override
  State<FavoriteDetailPage> createState() => _FavoriteDetailPageState();
}

class _FavoriteDetailPageState extends State<FavoriteDetailPage> {
  List<Exercise> exercises = [];
  bool isLoading = true;
  bool isBalanced = false;
  String? userId;
  String? token;
  late String listName;

  @override
  void initState() {
    super.initState();
    listName = widget.favoriteList.name;
    _loadUserAndExercises();
  }

  Future<void> _loadUserAndExercises() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('authToken');

    try {
      // ✅ Yeni yapıya uygun: doğrudan gelen egzersizleri alıyoruz
      exercises = widget.favoriteList.exercises;
      isBalanced = widget.favoriteList.color.isEmpty ||
          widget.favoriteList.color == '#FF2196F3';
    } catch (e) {
      debugPrint('Egzersizler yüklenemedi: $e');
    }

    setState(() => isLoading = false);
  }

  void _navigateToMuscleMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MuscleMapPage(),
      ),
    );
  }

  Future<void> _showRenameDialog() async {
    final controller = TextEditingController(text: listName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Listeyi Yeniden Adlandır'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Yeni ad'),
        ),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Kaydet'),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || userId == null || token == null) return;
              try {
                await FavoritesService.renameFavoriteList(
                    userId!, widget.favoriteList.id, newName, token!);
                setState(() {
                  listName = newName;
                });
                Navigator.pop(context);
              } catch (e) {
                debugPrint('❌ Yeniden adlandırma hatası: $e');
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Listeyi Sil'),
        content: const Text('Bu listeyi silmek istediğine emin misin?'),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sil'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && userId != null && token != null) {
      try {
        await FavoritesService.deleteFavoriteList(
            userId!, widget.favoriteList.id, token!);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint('❌ Liste silme hatası: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
        actions: [
          if (!isBalanced)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') _showRenameDialog();
                if (value == 'delete') _confirmDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'rename', child: Text('Yeniden Adlandır')),
                PopupMenuItem(value: 'delete', child: Text('Listeyi Sil')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (!isBalanced)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: _navigateToMuscleMap,
                icon: const Icon(Icons.add),
                label: const Text('Egzersiz Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : exercises.isEmpty
                    ? const Center(
                        child: Text(
                          'Bu listede hiç egzersiz yok.',
                          style: TextStyle(color: Colors.white70),
                        ),
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
                            imageUrl: ex.images.isNotEmpty ? ex.images[0] : '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExerciseDetailPage(exercise: ex),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
