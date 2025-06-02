import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exercises/balanced_exercise_list_page.dart';
import '../../services/balanced_list_service.dart';
import '../../services/favorites_service.dart';

import '../../models/favorite_list.dart';

class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key});

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage>
    with SingleTickerProviderStateMixin {
  String? userName;
  String? gender;
  List<String> favoriteMuscleGroups = [];
  String? userId;
  String? token;
  List<FavoriteList> userFavoriteLists = [];
  List<FavoriteList> userBalancedLists = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final fetchedUserId = prefs.getString('userId');
    final fetchedToken = prefs.getString('authToken');

    List<FavoriteList> fetchedLists = [];
    List<FavoriteList> fetchedBalanced = [];

    if (fetchedUserId != null && fetchedToken != null) {
      fetchedLists =
          await FavoritesService.fetchUserLists(fetchedUserId, fetchedToken);

      fetchedBalanced = await FavoritesService.fetchFavoriteBalancedLists(
          fetchedUserId, fetchedToken);
    }

    setState(() {
      userName = prefs.getString('userName') ?? 'Kullanıcı';
      gender = prefs.getString('gender') ?? '';
      favoriteMuscleGroups = fetchedBalanced.map((e) => e.name).toList();
      userId = fetchedUserId;
      token = fetchedToken;
      userFavoriteLists = fetchedLists;
      userBalancedLists = fetchedBalanced;
    });
  }

  Future<void> _toggleFavorite(String listName) async {
    if (userId == null || token == null) return;

    try {
      // ✅ Liste adına göre BalancedList'i (id + egzersizlerle) getir
      final matched = await BalancedListService.fetchListByName(listName);

      if (matched.id.isEmpty) {
        throw Exception('BalancedList bulunamadı: $listName');
      }

      await FavoritesService.toggleFavoriteBalancedList(
        userId: userId!,
        token: token!,
        listId: matched.id,
      );

      // ♻️ Güncel favori balanced listeleri çek
      final updatedBalanced =
          await FavoritesService.fetchFavoriteBalancedLists(userId!, token!);

      setState(() {
        userBalancedLists = updatedBalanced;
        favoriteMuscleGroups = updatedBalanced.map((e) => e.name).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favori işlemi hatası: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = gender == 'Kadın'
        ? '$userName Hanım'
        : gender == 'Erkek'
            ? '$userName Bey'
            : userName ?? 'Kullanıcı';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hoşgeldiniz, $displayName!',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                const Color(0xFF1A1A1A),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ListView(
              children: [
                _buildSectionHeader('Önerilen Egzersizler', Icons.star),
                const SizedBox(height: 16),
                _buildCardRow([
                  'Bacak Günü',
                  'Sırt Günü',
                  'Omuz Günü',
                  'Göğüs Günü',
                  'Kol Günü',
                ], [
                  Color(0xFFFF4B4B),
                  Color(0xFFFF9F43),
                  Color(0xFF9B59B6),
                  Color(0xFF2ECC71),
                  Color(0xFF3498DB),
                ], [
                  Color(0xFFFF7676),
                  Color(0xFFFFB976),
                  Color(0xFFB976FF),
                  Color(0xFF76FFB9),
                  Color(0xFF76B9FF),
                ]),
                const SizedBox(height: 32),
                _buildSectionHeader(
                    'Ekipmansız Antrenmanlar', Icons.fitness_center),
                const SizedBox(height: 16),
                _buildCardRow([
                  'Ekipmansız Bacak',
                  'Ekipmansız Göğüs',
                  'Ekipmansız Sırt',
                  'Ekipmansız Kol',
                ], [
                  Color(0xFF1ABC9C),
                  Color(0xFF34495E),
                  Color(0xFFE74C3C),
                  Color(0xFF8E44AD),
                ], [
                  Color(0xFF76FFE6),
                  Color(0xFF76B9FF),
                  Color(0xFFFF7676),
                  Color(0xFFB976FF),
                ]),
                const SizedBox(height: 32),
                _buildSectionHeader(
                    'Yeni Başlayanlar İçin', Icons.emoji_events),
                const SizedBox(height: 16),
                _buildCardRow([
                  'Full Body Başlangıç',
                  'Evde Başlangıç',
                  'Dambılla Tüm Vücut',
                ], [
                  Color(0xFF16A085),
                  Color(0xFF27AE60),
                  Color(0xFF8E44AD),
                ], [
                  Color(0xFF76FFE6),
                  Color(0xFF76FFB9),
                  Color(0xFFD35400),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCardRow(
      List<String> titles, List<Color> startColors, List<Color> endColors) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return _buildGradientCard(
            context,
            titles[index],
            startColors[index],
            endColors[index],
          );
        },
      ),
    );
  }

  Widget _buildGradientCard(
      BuildContext context, String title, Color startColor, Color endColor) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BalancedExerciseListPage(muscle: title),
              ),
            );
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: endColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                favoriteMuscleGroups.contains(title)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteMuscleGroups.contains(title)
                    ? Colors.red
                    : Colors.white,
                size: 20,
              ),
              onPressed: () => _toggleFavorite(title),
            ),
          ),
        ),
      ],
    );
  }
}
