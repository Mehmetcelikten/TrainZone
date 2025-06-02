import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../services/exercise_service.dart';
import '../../widgets/exercise_card.dart';

class ExerciseListPage extends StatefulWidget {
  final String muscle;

  const ExerciseListPage({super.key, required this.muscle});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  String selectedLevel = '';
  final List<String> selectedEquipment = [];

  List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetched = await ExerciseService.fetchExercises(
        muscle: widget.muscle,
        level: selectedLevel.isEmpty ? null : selectedLevel,
        equipment: selectedEquipment.isEmpty ? null : selectedEquipment.first,
      );
      setState(() {
        exercises = fetched;
        isLoading = false;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() => isLoading = false);
    }
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text('Kademe Seç',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Başlangıç', 'Orta', 'İleri'].map((level) {
                    IconData icon = Icons.star_border;
                    if (level == 'Orta') icon = Icons.star_half;
                    if (level == 'İleri') icon = Icons.star;

                    final isSelected = selectedLevel == level;

                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedLevel = isSelected ? '' : level;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  isSelected ? Colors.redAccent : Colors.grey),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, color: Colors.white, size: 34),
                            const SizedBox(height: 4),
                            Text(level,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Ekipman Seç',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    {'name': 'Vücut Ağırlığı', 'icon': Icons.accessibility},
                    {'name': 'Dambıl', 'icon': Icons.fitness_center},
                    {'name': 'Barbell', 'icon': Icons.sports_gymnastics},
                    {'name': 'Makine', 'icon': Icons.devices},
                    {'name': 'Kettlebell', 'icon': Icons.sports_mma},
                    {'name': 'Kablo', 'icon': Icons.cable},
                  ].map((equipment) {
                    bool isSelected =
                        selectedEquipment.contains(equipment['name']);
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          if (isSelected) {
                            selectedEquipment.remove(equipment['name']);
                          } else {
                            selectedEquipment.add(equipment['name'] as String);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 90,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isSelected
                                  ? Colors.redAccent
                                  : Colors.white38),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.5),
                                      blurRadius: 8)
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(equipment['icon'] as IconData,
                                size: 34, color: Colors.white),
                            const SizedBox(height: 6),
                            Text(equipment['name']! as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => isLoading = true);
                      fetchData();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Filtrele',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController(viewportFraction: 0.9);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.muscle} Egzersizleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, size: 28),
            onPressed: _openFilterBottomSheet,
            tooltip: 'Filtrele',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : exercises.isEmpty
              ? const Center(
                  child: Text('Egzersiz bulunamadı',
                      style: TextStyle(color: Colors.white)),
                )
              : PageView.builder(
                  controller: controller,
                  scrollDirection: Axis.vertical,
                  itemCount: exercises.length,
                  padEnds: false,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    return ExerciseCard(
                      name: ex.name,
                      rating: ex.rating,
                      imageUrl: ex.images.first, // ✅ İlk görsel kullanılıyor
                      onDetailsPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/exercise_detail',
                          arguments: ex,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
