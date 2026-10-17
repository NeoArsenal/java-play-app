import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/user_service.dart';
import 'core/theme/app_theme.dart';
import 'features/learning_path/presentation/screens/learning_path_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService.initialize();
  runApp(
    const ProviderScope(
      child: JavaPlayApp(),
    ),
  );
}

class JavaPlayApp extends StatelessWidget {
  const JavaPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Java & Spring Interview Duolingo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LearningPathScreen(),
    );
  }
}
