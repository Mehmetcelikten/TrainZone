import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/workout_plan.dart';
import '../../providers/workout_plan_provider.dart';
import '../../widgets/exercise_info_card.dart';
import 'exercise_detail_page.dart';
import '../../services/exercise_service.dart';
import '../../models/exercise.dart';

class PlanDetailPage extends StatefulWidget {
  final WorkoutPlan plan;

  const PlanDetailPage({super.key, required this.plan});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  List<Exercise> fetchedExercises = [];
  bool isLoading = true;

  @override
  late String userId;
  late String token;
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    token = prefs.getString('authToken') ?? '';
    @override
    void initState() {
      super.initState();
      _loadAuthData().then((_) => loadExercises());
    }
  }

  Future<void> loadExercises() async {
    try {
      final all = await ExerciseService.fetchExercises();
      setState(() {
        fetchedExercises =
            all.where((e) => widget.plan.exercises.contains(e.name)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutPlanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                String updatedName = widget.plan.name;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Plan Adını Değiştir'),
                    content: TextField(
                      decoration: const InputDecoration(labelText: 'Yeni Ad'),
                      onChanged: (val) => updatedName = val,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          provider.renamePlan(widget.plan, updatedName);
                          Navigator.pop(context);
                        },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'delete') {
                provider.removePlan(widget.plan);
                Navigator.pop(context);
              } else if (value == 'color') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Renk Seç'),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _colorCircle(context, provider, Colors.red),
                        _colorCircle(context, provider, Colors.green),
                        _colorCircle(context, provider, Colors.blue),
                        _colorCircle(context, provider, Colors.orange),
                      ],
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Adı Değiştir')),
              const PopupMenuItem(value: 'delete', child: Text('Sil')),
              const PopupMenuItem(value: 'color', child: Text('Renk Değiştir')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final selectedExercise =
                    await Navigator.pushNamed(context, '/muscle_map');
                if (selectedExercise != null && selectedExercise is String) {
                  provider.addExerciseToPlan(
                      widget.plan.name, selectedExercise);
                  loadExercises(); // Güncelle
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Egzersiz Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : fetchedExercises.isEmpty
                    ? const Center(
                        child: Text(
                          'Henüz egzersiz eklenmedi.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: fetchedExercises.length,
                        itemBuilder: (context, index) {
                          final ex = fetchedExercises[index];
                          return ExerciseInfoCard(
                            name: ex.name,
                            muscleGroup: ex.muscle,
                            difficulty: ex.level,
                            equipment: ex.equipment,
                            imageUrl: ex.images.isNotEmpty
                                ? ex.images[0]
                                : 'https://via.placeholder.com/100',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExerciseDetailPage(
                                    exercise: ex,
                                  ),
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

  Widget _colorCircle(
      BuildContext context, WorkoutPlanProvider provider, Color color) {
    return GestureDetector(
      onTap: () {
        provider.changePlanColor(widget.plan, color);
        Navigator.pop(context);
      },
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}
