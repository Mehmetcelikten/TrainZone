import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/favorite_list.dart';
import '../../services/favorites_service.dart';
import '../../services/auth_service.dart';
import 'favorites_list_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavoriteList> userFavoriteLists = [];
  List<FavoriteList> userBalancedLists = [];
  String? userId;
  String? token;
  bool isFavoritesLoading = true;
  bool isCreating = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserFavorites();
  }

  Future<void> _loadUserFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) return;

    userId = prefs.getString('userId');
    token = prefs.getString('authToken');

    if (userId == null || token == null) return;

    try {
      final classic = await FavoritesService.fetchUserLists(userId!, token!);
      final balanced =
          await FavoritesService.fetchFavoriteBalancedLists(userId!, token!);
      classic.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? '') ?? 0);
      setState(() {
        userFavoriteLists = classic;
        userBalancedLists = balanced;
        isFavoritesLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Liste yüklenemedi: $e");
      setState(() => isFavoritesLoading = false);
    }
  }

  Future<void> _createFavoriteList() async {
    if (!isLoggedIn || userId == null || token == null) return;

    String newName = '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Yeni Liste Oluştur",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Liste adı",
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                onChanged: (val) => newName = val,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (newName.trim().isEmpty) return;
                  try {
                    final created = await FavoritesService.createFavoriteList(
                        userId!, newName, token!);
                    setState(() => userFavoriteLists.add(created));
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    debugPrint("❌ Liste oluşturulamadı: $e");
                  }
                },
                child: const Text("Oluştur"),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _renameList(FavoriteList list) async {
    final controller = TextEditingController(text: list.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Liste Adını Değiştir"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || userId == null || token == null) return;
              try {
                await FavoritesService.renameFavoriteList(
                    userId!, list.id, newName, token!);
                setState(() => list.name = newName);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint("❌ Ad değiştirilemedi: $e");
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteList(FavoriteList list) async {
    if (userId == null || token == null) return;
    try {
      await FavoritesService.deleteFavoriteList(userId!, list.id, token!);
      setState(() => userFavoriteLists.removeWhere((l) => l.id == list.id));
    } catch (e) {
      debugPrint("❌ Liste silinemedi: $e");
    }
  }

  Widget _buildListTile(FavoriteList list, {bool isBalanced = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(list.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text("${list.exercises.length} egzersiz",
            style: const TextStyle(color: Colors.white70)),
        onTap: () {
          print("📝 Liste Adı: ${list.name}");
          print("📦 Liste ID: ${list.id}");
          print("🎨 Renk: ${list.color}");
          print(
              "🧠 Balanced mı?: ${list.color.isEmpty || list.color == '#FF2196F3'}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavoriteDetailPage(favoriteList: list),
            ),
          );
        },
        trailing: isBalanced
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'rename') _renameList(list);
                  if (value == 'delete') _deleteList(list);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'rename', child: Text('Adı Değiştir')),
                  const PopupMenuItem(value: 'delete', child: Text('Sil')),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Listeler'),
        actions: [
          IconButton(
              onPressed: _createFavoriteList, icon: const Icon(Icons.add))
        ],
      ),
      body: isFavoritesLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (userFavoriteLists.isNotEmpty) ...[
                    const Text('Senin Oluşturduğun Listeler',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    ...userFavoriteLists.map((l) => _buildListTile(l)),
                    const SizedBox(height: 24),
                  ],
                  if (userBalancedLists.isNotEmpty) ...[
                    const Text('Hazır Favori Listelerin',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    ...userBalancedLists
                        .map((l) => _buildListTile(l, isBalanced: true)),
                  ],
                  if (userFavoriteLists.isEmpty && userBalancedLists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text("Henüz hiç favori listen yok.",
                          style: TextStyle(color: Colors.white54)),
                    )
                ],
              ),
            ),
    );
  }
}
