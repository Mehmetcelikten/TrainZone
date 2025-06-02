import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/exercise.dart';
import '../../models/favorite_list.dart';
import '../../services/favorites_service.dart';
import '../../services/exercise_service.dart';
import '../../services/auth_service.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool isFavorite = false;
  List<FavoriteList> favoriteLists = [];
  List<double> ratings = [];
  bool showStars = false;
  String? userId;
  String? token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteLists();
  }

  double get averageRating => ratings.isEmpty
      ? widget.exercise.rating
      : (ratings.reduce((a, b) => a + b) / ratings.length);

  Future<void> _loadFavoriteLists() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('authToken');

    if (userId == null || token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final lists = await FavoritesService.fetchUserLists(userId!, token!);
      final alreadyExists = lists.any(
        (list) => list.exercises.any((ex) => ex.id == widget.exercise.id),
      );
      setState(() {
        isFavorite = alreadyExists;
        favoriteLists = lists;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Favori listeler alınamadı: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _addToFavoriteList(String listId) async {
    if (userId == null || token == null) return;

    try {
      await FavoritesService.addExerciseToList(
        userId!,
        listId,
        widget.exercise.id,
        token!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.exercise.name} listeye eklendi')),
      );
      _loadFavoriteLists();
    } catch (e) {
      debugPrint('Ekleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listeye eklenemedi')),
      );
    }
  }

  void _showCreateListBottomSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Yeni Liste Oluştur",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Liste adı",
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty && userId != null && token != null) {
                    try {
                      final newList = await FavoritesService.createFavoriteList(
                        userId!,
                        name,
                        token!,
                      );
                      setState(() => favoriteLists.add(newList));
                      await _addToFavoriteList(newList.id);
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint('Liste oluşturulamadı: $e');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.9),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                    Colors.redAccent.withOpacity(0.1),
                  ),
                ),
                child: const Text(
                  "Oluştur ve Ekle",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showFavoriteBottomSheet() {
    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favori eklemek için giriş yapmalısınız')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Favori Listeni Seç",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              if (isLoading)
                const CircularProgressIndicator()
              else if (favoriteLists.isEmpty)
                const Text('Hiç favori listeniz yok.',
                    style: TextStyle(color: Colors.white70))
              else
                ...favoriteLists.map((list) => ListTile(
                      title: Text(list.name,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        _addToFavoriteList(list.id);
                        Navigator.pop(context);
                      },
                    )),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showCreateListBottomSheet,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "Yeni Liste Oluştur",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.9),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                    Colors.redAccent.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectRating(double value) async {
    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puan vermek için giriş yapmalısınız')),
      );
      return;
    }

    setState(() {
      ratings.add(value);
      showStars = false;
    });

    try {
      await ExerciseService.updateRating(widget.exercise.id, value, userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Puanınız gönderildi: $value')),
      );
    } catch (e) {
      debugPrint("Rating gönderilemedi: $e");
    }
  }

  Widget _infoChip(String text, IconData icon,
      {bool isSquare = false,
      bool isLarge = false,
      bool isTransparent = false}) {
    return Container(
      padding: isLarge
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 14)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isTransparent
            ? Colors.redAccent.shade200.withOpacity(0.65)
            : Colors.redAccent.shade200.withOpacity(0.85),
        borderRadius: BorderRadius.circular(isSquare ? 8 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isLarge ? 22 : 18),
          SizedBox(width: isLarge ? 10 : 7),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isLarge ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
            onPressed: _showFavoriteBottomSheet,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => setState(() => showStars = false),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: PageView(
                      children: exercise.images.map((img) {
                        return Image.network(
                          img.replaceFirst('/upload/v1/', '/upload/'),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      }).toList(),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _infoChip(
                              '${exercise.sets} Set',
                              Icons.fitness_center,
                              isSquare: false,
                              isTransparent: true,
                            ),
                            _infoChip(
                              '${exercise.reps} Tekrar',
                              Icons.repeat,
                              isSquare: false,
                              isTransparent: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => showStars = !showStars),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                              ],
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: showStars
                              ? Container(
                                  key: const ValueKey('stars'),
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color(0xFFFFD700), // gold color
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(5, (index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        child: GestureDetector(
                                          onTap: () => _selectRating(
                                              (index + 1).toDouble()),
                                          child: const Icon(
                                            Icons.star_border,
                                            color:
                                                Color(0xFFFFD700), // gold color
                                            size: 18,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                )
                              : const SizedBox(
                                  height: 40, key: ValueKey('empty')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  _infoChip(
                    exercise.level,
                    Icons.bar_chart,
                    isSquare: true,
                    isLarge: true,
                  ),
                  _infoChip(
                    exercise.equipment,
                    Icons.handyman,
                    isSquare: true,
                    isLarge: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    exercise.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
