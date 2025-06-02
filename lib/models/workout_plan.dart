import 'package:flutter/material.dart';

class WorkoutPlan {
  final String name;
  final List<String> exercises;
  Color color;

  WorkoutPlan({
    required this.name,
    this.exercises = const [],
    this.color = Colors.blue,
  });
}
