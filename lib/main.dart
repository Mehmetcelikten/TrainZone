import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/theme_provider.dart';
import 'providers/workout_plan_provider.dart';
import 'theme.dart';
import 'app_scaffold.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/exercises/exercise_detail_page.dart';
import 'screens/map/muscle_map_screen.dart';
import 'screens/exercises/exercise_list_page.dart';
import 'screens/exercises/plan_exercises_page.dart';

import 'models/workout_plan.dart';
import 'models/exercise.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlanProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('authToken');

    return userId != null &&
        token != null &&
        userId.isNotEmpty &&
        token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: FutureBuilder<bool>(
        future: isUserLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data! ? const AppScaffold() : const ProfileScreen();
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/exercise_detail':
            final exercise = settings.arguments;
            if (exercise is Exercise) {
              return MaterialPageRoute(
                builder: (_) => ExerciseDetailPage(exercise: exercise),
              );
            }
            return _errorRoute('Veri tipi hatası: Exercise bekleniyordu.');

          case '/muscle_map':
            return MaterialPageRoute(builder: (_) => const MuscleMapPage());

          case '/exercise_list':
            final args = settings.arguments;
            if (args is Map<String, dynamic> && args.containsKey('muscle')) {
              final muscle = args['muscle'] as String;
              return MaterialPageRoute(
                builder: (_) => ExerciseListPage(muscle: muscle),
              );
            }
            return _errorRoute('Kas grubu verisi bulunamadı.');

          case '/plan_exercises':
            final args = settings.arguments;
            if (args is Map<String, dynamic> && args['plan'] is WorkoutPlan) {
              return MaterialPageRoute(
                builder: (_) => PlanDetailPage(plan: args['plan']),
              );
            }
            return _errorRoute('Plan verisi bulunamadı veya geçersiz.');
        }

        return _errorRoute('Geçersiz rota: ${settings.name}');
      },
    );
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
