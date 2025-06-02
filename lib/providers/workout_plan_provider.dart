import 'package:flutter/material.dart';
import '../models/workout_plan.dart';

class WorkoutPlanProvider extends ChangeNotifier {
  final List<WorkoutPlan> _plans = [];

  List<WorkoutPlan> get plans => _plans;

  void addPlan(WorkoutPlan plan) {
    _plans.add(plan);
    notifyListeners();
  }

  void removePlan(WorkoutPlan plan) {
    _plans.remove(plan);
    notifyListeners();
  }

  void addExerciseToPlan(String planName, String exercise) {
    final index = _plans.indexWhere((p) => p.name == planName);
    if (index != -1) {
      final updatedPlan = WorkoutPlan(
        name: _plans[index].name,
        exercises: [..._plans[index].exercises, exercise],
        color: _plans[index].color,
      );
      _plans[index] = updatedPlan;
      notifyListeners();
    }
  }

  void renamePlan(WorkoutPlan oldPlan, String newName) {
    final index = _plans.indexOf(oldPlan);
    if (index != -1) {
      _plans[index] = WorkoutPlan(
        name: newName,
        exercises: oldPlan.exercises,
        color: oldPlan.color,
      );
      notifyListeners();
    }
  }

  void changePlanColor(WorkoutPlan oldPlan, Color newColor) {
    final index = _plans.indexOf(oldPlan);
    if (index != -1) {
      _plans[index] = WorkoutPlan(
        name: oldPlan.name,
        exercises: oldPlan.exercises,
        color: newColor,
      );
      notifyListeners();
    }
  }

  void reorderPlans(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _plans.removeAt(oldIndex);
    _plans.insert(newIndex, item);
    notifyListeners();
  }
}
