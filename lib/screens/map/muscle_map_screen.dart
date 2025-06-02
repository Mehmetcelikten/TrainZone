import 'package:flutter/material.dart';
import '../exercises/exercise_list_page.dart';

class MuscleMapPage extends StatefulWidget {
  const MuscleMapPage({super.key});

  @override
  State<MuscleMapPage> createState() => _MuscleMapPageState();
}

class _MuscleMapPageState extends State<MuscleMapPage> {
  bool showFront = true;

  void showSelected(BuildContext context, String muscle) {
    final muscleMap = {
      'Göğüs': 'Göğüs',
      'Karın': 'Karın',
      'Sol Omuz': 'Omuz',
      'Sağ Omuz': 'Omuz',
      'Sol Biceps': 'Kol',
      'Sağ Biceps': 'Kol',
      'Sol Forearm': 'Kol',
      'Sağ Forearm': 'Kol',
      'Sol Üst Bacak': 'Bacak',
      'Sağ Üst Bacak': 'Bacak',
      'Sol Baldır': 'Bacak',
      'Sağ Baldır': 'Bacak',
      'Trapez': 'Sırt',
      'Orta Sırt': 'Sırt',
      'Lats': 'Sırt',
      'Alt Sırt': 'Sırt',
      'Glutes': 'Kalça',
      'Hamstrings': 'Bacak',
      'Calfs': 'Bacak',
      'Sol Arka Omuz': 'Omuz',
      'Sağ Arka Omuz': 'Omuz',
      'Sol Triceps': 'Kol',
      'Sağ Triceps': 'Kol',
      'Sol Arka Forearm': 'Kol',
      'Sağ Arka Forearm': 'Kol',
    };

    final selectedMuscle = muscleMap[muscle] ?? 'Tümü';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseListPage(muscle: selectedMuscle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = showFront
        ? 'lib/assets/FitnessAppModel.png'
        : 'lib/assets/FitnessAppModel2.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kas Haritası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                showFront = !showFront;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imagePath,
                width:
                    MediaQuery.of(context).size.width * (showFront ? 0.8 : 0.9),
                fit: BoxFit.contain,
              ),
              ...(showFront
                  ? _buildFrontPositions(context)
                  : _buildBackPositions(context)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFrontPositions(BuildContext context) {
    return [
      _muscleBlock(context, 'Göğüs', 150, 140, 100, 60),
      _muscleBlock(context, 'Karın', 220, 145, 90, 60),
      _muscleBlock(context, 'Sol Omuz', 120, 70, 50, 50),
      _muscleBlock(context, 'Sağ Omuz', 120, null, 50, 50, right: 60),
      _muscleBlock(context, 'Sol Biceps', 175, 70, 40, 80),
      _muscleBlock(context, 'Sağ Biceps', 175, null, 40, 80, right: 70),
      _muscleBlock(context, 'Sol Forearm', 260, 50, 40, 60),
      _muscleBlock(context, 'Sağ Forearm', 260, null, 40, 60, right: 40),
      _muscleBlock(context, 'Sol Üst Bacak', 330, 110, 50, 120),
      _muscleBlock(context, 'Sağ Üst Bacak', 330, null, 50, 120, right: 90),
      _muscleBlock(context, 'Sol Baldır', 460, 120, 40, 80),
      _muscleBlock(context, 'Sağ Baldır', 460, null, 40, 80, right: 100),
    ];
  }

  List<Widget> _buildBackPositions(BuildContext context) {
    return [
      _muscleBlock(context, 'Trapez', 100, 130, 110, 40),
      _muscleBlock(context, 'Orta Sırt', 150, 140, 100, 60),
      _muscleBlock(context, 'Lats', 210, 130, 120, 50),
      _muscleBlock(context, 'Alt Sırt', 260, 135, 110, 60),
      _muscleBlock(context, 'Glutes', 330, 140, 100, 60),
      _muscleBlock(context, 'Hamstrings', 390, 120, 140, 70),
      _muscleBlock(context, 'Calfs', 500, 130, 110, 70),
      _muscleBlock(context, 'Sol Arka Omuz', 120, 70, 50, 50),
      _muscleBlock(context, 'Sağ Arka Omuz', 120, null, 50, 50, right: 70),
      _muscleBlock(context, 'Sol Triceps', 180, 60, 40, 80),
      _muscleBlock(context, 'Sağ Triceps', 180, null, 40, 80, right: 60),
      _muscleBlock(context, 'Sol Arka Forearm', 260, 50, 40, 60),
      _muscleBlock(context, 'Sağ Arka Forearm', 260, null, 40, 60, right: 40),
    ];
  }

  Widget _muscleBlock(BuildContext context, String name, double top,
      double? left, double width, double height,
      {double? right}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => showSelected(context, name),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
