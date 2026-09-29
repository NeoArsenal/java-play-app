import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../learning_path/domain/models/world.dart';
import '../../learning_path/domain/models/lesson.dart';
import '../../mock_interview/domain/models/interview_question.dart';
import '../../mock_interview/presentation/screens/mock_interview_screen.dart';
import '../../quiz/presentation/screens/quiz_screen.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  List<World> _worlds = [];
  List<InterviewQuestion> _mockQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurriculum();
  }

  Future<void> _loadCurriculum() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/curriculum.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final worldsJson = data['worlds'] as List;
      final mockJson = data['mockInterviews'] as List;

      setState(() {
        _worlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();
        _mockQuestions =
            mockJson.map((m) => InterviewQuestion.fromJson(m as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading curriculum: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopGamificationBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Banner de Simulador de Entrevista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildMockInterviewBanner(),
          ),
          const SizedBox(height: 12),
          // Mundos y Nodos de Lecciones
          ..._worlds.map((world) => _buildWorldSection(world)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopGamificationBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 2,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.local_fire_department_rounded, color: AppColors.duolingoOrange, size: 24),
              SizedBox(width: 4),
              Text(
                "3 días",
                style: TextStyle(
                  color: AppColors.duolingoOrange,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.bolt_rounded, color: AppColors.duolingoGold, size: 24),
              SizedBox(width: 2),
              Text(
                "180 XP",
                style: TextStyle(
                  color: AppColors.duolingoGold,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.favorite, color: AppColors.errorRed, size: 24),
              SizedBox(width: 4),
              Text(
                "5",
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockInterviewBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3A00), Color(0xFFFF9600)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Mock Interview Bajo Presión",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Preguntas trampa, audio y checklist técnico",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_mockQuestions.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MockInterviewScreen(question: _mockQuestions.first),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("PROBAR"),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldSection(World world) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: world.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: world.color.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.token, color: world.color, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        world.title,
                        style: TextStyle(
                          color: world.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        world.description,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Árbol de Nodos circulares
          Center(
            child: Column(
              children: List.generate(world.lessons.length, (index) {
                final lesson = world.lessons[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildLessonNode(lesson, world.color),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonNode(Lesson lesson, Color color) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuizScreen(lesson: lesson),
          ),
        );
      },
      borderRadius: BorderRadius.circular(40),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white24, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
