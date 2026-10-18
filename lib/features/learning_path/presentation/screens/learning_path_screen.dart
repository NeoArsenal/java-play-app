import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/features/learning_path/domain/models/world.dart';
import 'package:java_play_app/features/learning_path/domain/models/lesson.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import 'package:java_play_app/features/mock_interview/domain/models/interview_question.dart';
import 'package:java_play_app/features/mock_interview/domain/models/ai_evaluation_result.dart';
import 'package:java_play_app/features/mock_interview/data/mock_interview_repository.dart';
import 'package:java_play_app/features/mock_interview/data/mock_interview_catalog.dart';
import 'package:java_play_app/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:java_play_app/features/quiz/presentation/screens/boss_challenge_screen.dart';
import 'package:java_play_app/features/learning_path/data/boss_repository.dart';
import 'package:java_play_app/core/services/user_service.dart';
import 'package:java_play_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum AppTab { path, srs, mock }

/// Decodifica el JSON del currículum en un Isolate de fondo para evitar
/// bloquear el hilo principal de la UI durante la carga inicial.
Map<String, dynamic> _parseCurriculumJson(String jsonString) {
  return json.decode(jsonString) as Map<String, dynamic>;
}

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> with SingleTickerProviderStateMixin {
  AppTab _currentTab = AppTab.path;
  List<World> _worlds = [];
  List<InterviewQuestion> _mockQuestions = List.from(MockInterviewCatalog.allQuestions);
  int _selectedWorldIndex = 0;
  String _difficulty = 'normal'; // easy (5), normal (7), hard (10)
  bool _isLoading = true;

  // Progreso por mundo (persistido)
  final Map<String, int> _completedLevels = {};
  final Set<String> _completedBosses = {};
  final BossRepository _bossRepo = BossRepository();
  int _userXp = 180;

  // Estado del Modo Repaso SM-2
  int _srsDueCount = 4;
  int _srsCurrentCardIndex = 0;
  bool _srsShowAnswer = false;
  final List<Map<String, String>> _srsDemoCards = [
    {
      'question': '¿Qué diferencia existe entre Heap y Stack en la JVM?',
      'answer': 'El Stack almacena variables locales y frames de ejecución por hilo (rápido, estático). El Heap almacena todos los Objetos creados con `new` compartidos por todos los hilos y administrados por el Garbage Collector.',
      'category': 'JVM Internals',
    },
    {
      'question': '¿Por qué los Beans de Spring deben ser Stateless por defecto?',
      'answer': 'Porque los Beans son Singleton por defecto y atendidos por múltiples hilos en paralelo. No deben tener estado mutable para evitar condiciones de carrera (Race Conditions).',
      'category': 'Spring Boot',
    },
    {
      'question': '¿Qué problema resuelve el contrato equals() y hashCode()?',
      'answer': 'Si dos objetos son iguales según equals(), deben tener el mismo hashCode(). Si no se cumple, las colecciones basadas en hash (como HashMap o HashSet) fallarán al buscar o recuperar elementos.',
      'category': 'Java Core',
    },
    {
      'question': '¿Qué ventaja ofrecen los Virtual Threads de Java 21?',
      'answer': 'Son hilos ultra ligeros gestionados por la JVM en memoria Heap. Cuando hacen operaciones bloqueantes de I/O, se desmontan del hilo del SO, permitiendo procesar millones de peticiones concurrentes.',
      'category': 'Java 21 Moderno',
    },
  ];

  // Estado del Modo Mock Interview
  int _selectedMockQuestionIndex = 0;
  String _mockInputMode = 'voice'; // 'voice' o 'text'
  bool _isRecording = false;
  int _recordingSeconds = 60;
  Timer? _recordingTimer;
  final TextEditingController _answerTextController = TextEditingController();
  final MockInterviewRepository _mockRepo = MockInterviewRepository();
  bool _isEvaluatingAi = false;
  AiEvaluationResult? _aiEvaluation;

  // Reconocimiento de voz continuo en tiempo real (Español)
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _isSpeechAvailable = false;
  String _currentLocaleId = 'es_ES';
  String _accumulatedTranscript = '';
  String _currentSessionTranscript = '';
  // Guards contra error_busy: solo un restart pendiente a la vez
  bool _isRestarting = false;
  Timer? _restartTimer;

  // Getters para el Simulador de Entrevista sincronizado con el Mundo activo
  String get _currentWorldId {
    if (_worlds.isNotEmpty && _selectedWorldIndex < _worlds.length) {
      return _worlds[_selectedWorldIndex].id;
    }
    return 'mundo_$_selectedWorldIndex';
  }

  List<InterviewQuestion> get _activeWorldQuestions {
    final worldId = _currentWorldId;
    final filtered = _mockQuestions.where((q) => q.worldId == worldId).toList();
    if (filtered.isNotEmpty) return filtered;
    final fromCatalog = MockInterviewCatalog.getQuestionsForWorld(worldId);
    if (fromCatalog.isNotEmpty) return fromCatalog;
    return _mockQuestions.isNotEmpty ? _mockQuestions : MockInterviewCatalog.allQuestions;
  }

  InterviewQuestion get _currentInterviewQuestion {
    final list = _activeWorldQuestions;
    if (list.isEmpty) return MockInterviewCatalog.allQuestions.first;
    return list[_selectedMockQuestionIndex % list.length];
  }

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initSpeech();
    _initApp();
  }

  Future<void> _initSpeech() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('Speech onError: ${val.errorMsg}');
          // error_busy = reconocedor ocupado (no reiniciar inmediatamente)
          // error_client = sesión cortada por el OS
          // Solo reiniciar en errores recuperables que no sean error_busy en cadena
          if (!_isRecording || _recordingSeconds <= 2) return;
          if (val.errorMsg == 'error_busy') {
            // error_busy: esperar más tiempo, el OS aún no liberó el recurso
            _scheduleDebouncedRestart(delay: const Duration(milliseconds: 1200));
          } else if (val.errorMsg == 'error_client' ||
              val.errorMsg == 'error_speech_timeout') {
            // error_client / timeout: reinicio normal con delay estándar
            _scheduleDebouncedRestart(delay: const Duration(milliseconds: 800));
          }
          // Otros errores (error_no_match, etc.) los ignoramos — no reiniciar
        },
        onStatus: (val) {
          debugPrint('Speech onStatus: $val');
          // 'done' indica que el reconocedor terminó su sesión
          // SOLO reiniciar si estamos grabando y hay tiempo restante
          // NO reiniciar en 'notListening' porque viene justo antes de 'done'
          // y causaría dos reinicios simultáneos
          if (!_isRecording || _recordingSeconds <= 2) return;
          if (val == 'done') {
            _scheduleDebouncedRestart(delay: const Duration(milliseconds: 800));
          }
        },
      );
      if (_isSpeechAvailable) {
        await _resolveSpanishLocale();
      }
      _speechInitialized = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error initializing speech: $e");
    }
  }

  /// Programa un único restart con debounce — cancela cualquier restart pendiente.
  /// Esto evita que múltiples onError/onStatus disparen reinicios en cascada.
  void _scheduleDebouncedRestart({required Duration delay}) {
    if (_isRestarting) return; // Ya hay un restart en progreso
    _restartTimer?.cancel();
    _restartTimer = Timer(delay, () {
      if (_isRecording && mounted && _recordingSeconds > 2) {
        _restartListening();
      }
    });
  }

  Future<void> _resolveSpanishLocale() async {
    try {
      final locales = await _speech.locales();
      final systemLoc = await _speech.systemLocale();

      debugPrint('=== Speech Locale Debug ===');
      debugPrint('System locale: ${systemLoc?.localeId}');
      debugPrint('Available locales (${locales.length}):');
      for (final l in locales) {
        debugPrint('  ${l.localeId} - ${l.name}');
      }

      // Orden de preferencia explícito para español
      const preferredEsLocales = [
        'es_MX', 'es-MX', // México (muy común en Android)
        'es_ES', 'es-ES', // España
        'es_US', 'es-US', // Español (Estados Unidos)
        'es_AR', 'es-AR', // Argentina
        'es_CO', 'es-CO', // Colombia
        'es_419','es-419', // Español Latinoamérica
        'es',             // Genérico
      ];

      // Normalizar IDs de locales disponibles para comparación
      final availableNormMap = <String, String>{}; // normalized -> original
      for (final l in locales) {
        final norm = l.localeId.toLowerCase().replaceAll('-', '_');
        availableNormMap[norm] = l.localeId;
      }

      // Buscar en orden de preferencia
      String? chosen;
      for (final pref in preferredEsLocales) {
        final normPref = pref.toLowerCase().replaceAll('-', '_');
        if (availableNormMap.containsKey(normPref)) {
          chosen = availableNormMap[normPref];
          debugPrint('Found preferred Spanish locale: $pref -> $chosen');
          break;
        }
      }

      // Si no se encontró ninguno exacto, buscar cualquier que empiece con 'es'
      if (chosen == null) {
        final anyEs = availableNormMap.entries
            .where((e) => e.key.startsWith('es'))
            .map((e) => e.value)
            .toList();
        if (anyEs.isNotEmpty) {
          chosen = anyEs.first;
          debugPrint('Fallback to first es* locale: $chosen');
        }
      }

      // Si el sistema ya está en español, úsalo
      if (chosen == null && systemLoc != null) {
        final sysNorm = systemLoc.localeId.toLowerCase().replaceAll('-', '_');
        if (sysNorm.startsWith('es')) {
          chosen = systemLoc.localeId;
          debugPrint('Using system Spanish locale: $chosen');
        }
      }

      // Último recurso: forzar es_ES
      _currentLocaleId = chosen ?? 'es_ES';
      debugPrint('=== Final locale: $_currentLocaleId ===');
    } catch (e) {
      debugPrint('Error resolving Spanish locale: $e');
      _currentLocaleId = 'es_ES';
    }
  }


  @override
  void dispose() {
    _pulseController.dispose();
    _recordingTimer?.cancel();
    _restartTimer?.cancel(); // Cancelar cualquier restart pendiente
    if (_speech.isListening) {
      try {
        _speech.stop();
      } catch (_) {}
    }
    _answerTextController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await _loadSavedProgress();
    await _loadCurriculum();
    await _loadCompletedBosses();
  }

  Future<void> _loadCompletedBosses() async {
    try {
      final userId = await UserService.getUserId();
      final bosses = await _bossRepo.getCompletedBosses(userId);
      if (mounted) {
        setState(() {
          _completedBosses.addAll(bosses);
        });
      }
    } catch (e) {
      debugPrint("Error loading completed bosses: $e");
    }
  }

  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDiff = prefs.getString('saved_difficulty') ?? 'normal';
      setState(() {
        _difficulty = savedDiff;
      });
    } catch (e) {
      debugPrint("Error reading preferences: $e");
    }
  }

  Future<void> _loadCurriculum() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/curriculum.json');
      final data = await compute(_parseCurriculumJson, jsonString);

      final worldsJson = (data['worlds'] as List?) ?? [];
      final mockJson = (data['mockInterviews'] as List?) ?? [];

      final prefs = await SharedPreferences.getInstance();
      final loadedWorlds = worldsJson.map((w) => World.fromJson(w as Map<String, dynamic>)).toList();

      for (final w in loadedWorlds) {
        final defVal = (w.id == 'mundo_0') ? 1 : 0;
        _completedLevels[w.id] = prefs.getInt('progress_${w.id}') ?? defVal;
      }

      List<InterviewQuestion> allMock = List.from(MockInterviewCatalog.allQuestions);
      if (mockJson.isNotEmpty) {
        final parsed = mockJson.map((m) => InterviewQuestion.fromJson(m as Map<String, dynamic>)).toList();
        for (final q in parsed) {
          final idx = allMock.indexWhere((item) => item.id == q.id);
          if (idx >= 0) {
            allMock[idx] = q;
          } else {
            allMock.add(q);
          }
        }
      }

      final savedDiff = prefs.getString('saved_difficulty') ?? 'normal';

      setState(() {
        _worlds = loadedWorlds;
        _mockQuestions = allMock;
        _difficulty = savedDiff;
        _isLoading = false;
      });

      // Actualizar en segundo plano desde el servidor si hay preguntas nuevas
      _mockRepo.getQuestions().then((remoteQuestions) {
        if (mounted && remoteQuestions.isNotEmpty) {
          setState(() {
            _mockQuestions = remoteQuestions;
          });
        }
      }).catchError((_) {});
    } catch (e) {
      debugPrint("Error loading curriculum: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProgress(String worldId, int newCompletedLevel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('progress_$worldId', newCompletedLevel);
    } catch (e) {
      debugPrint("Error saving progress: $e");
    }
  }

  Future<void> _setDifficulty(String newDiff) async {
    setState(() => _difficulty = newDiff);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_difficulty', newDiff);
    } catch (e) {
      debugPrint("Error saving difficulty: $e");
    }

    if (mounted) {
      final label = newDiff == 'easy'
          ? '⚡ Modo Ágil activado: 5 preguntas por nivel'
          : (newDiff == 'hard'
              ? '🔥 Modo Senior activado: 10 preguntas por nivel'
              : '🎯 Modo Normal activado: 7 preguntas por nivel');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(milliseconds: 1400),
          backgroundColor: newDiff == 'hard'
              ? AppColors.duolingoOrange
              : (newDiff == 'easy' ? AppColors.duolingoBlue : AppColors.primaryGreen),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  int get _questionLimit {
    switch (_difficulty) {
      case 'easy':
        return 5;
      case 'hard':
        return 10;
      default:
        return 7;
    }
  }

  void _openLesson(Lesson lesson, int num, World world) async {
    final targetCount = _questionLimit; // 5, 7, o 10

    List<Exercise> exerciseSubset = List.from(lesson.exercises);
    if (exerciseSubset.length > targetCount) {
      exerciseSubset = exerciseSubset.take(targetCount).toList();
    } else if (exerciseSubset.length < targetCount) {
      // Complementar con ejercicios del mismo mundo sin duplicar IDs ni títulos
      final existingIds = exerciseSubset.map((e) => e.id).toSet();
      final existingTitles = exerciseSubset.map((e) => e.title.trim().toLowerCase()).toSet();

      for (final otherLesson in world.lessons) {
        if (otherLesson.id == lesson.id) continue;
        for (final ex in otherLesson.exercises) {
          final normTitle = ex.title.trim().toLowerCase();
          if (!existingIds.contains(ex.id) && !existingTitles.contains(normTitle)) {
            exerciseSubset.add(ex);
            existingIds.add(ex.id);
            existingTitles.add(normTitle);
            if (exerciseSubset.length >= targetCount) break;
          }
        }
        if (exerciseSubset.length >= targetCount) break;
      }
    }

    final customLesson = Lesson(
      id: '${lesson.id}_limit_${targetCount}_${DateTime.now().microsecondsSinceEpoch}',
      title: lesson.title,
      xpReward: (lesson.xpReward * (targetCount / 7.0)).round(),
      exercises: exerciseSubset,
    );

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(lesson: customLesson),
      ),
    );

    if (completed == true) {
      setState(() {
        _userXp += customLesson.xpReward;
      });
      final currentCompleted = _completedLevels[world.id] ?? 0;
      if (num > currentCompleted) {
        setState(() {
          _completedLevels[world.id] = num;
        });
        await _saveProgress(world.id, num);
      }
    }
  }

  void _openBossChallenge(World world) async {
    final boss = world.bossChallenge;
    if (boss == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El desafío final no está disponible para este mundo.")),
      );
      return;
    }

    final userId = await UserService.getUserId();
    final victory = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BossChallengeScreen(
          world: world,
          bossChallenge: boss,
          userId: userId,
        ),
      ),
    );

    if (victory == true) {
      setState(() {
        _completedBosses.add(world.id);
        _userXp += boss.xpReward;
      });
      await _bossRepo.recordBossDefeat(
        userId: userId,
        worldId: world.id,
        bossId: boss.id,
        score: 100,
        xpAwarded: boss.xpReward,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🏆 ¡VICTORIA ÉPICA! Derrotaste a ${boss.bossName} (+${boss.xpReward} XP) sincronizado con Supabase"),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Helpers de Mock Interview
  int get _wordCount {
    final text = _answerTextController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  bool _isConceptMentioned(String concept, String text) {
    if (text.isEmpty) return false;
    final normText = text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u');

    final normConcept = concept
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u');

    if (normConcept.contains('/')) {
      final subparts = normConcept.split(RegExp(r'\s*\/\s*'));
      if (subparts.any((sub) => sub.trim().isNotEmpty && normText.contains(sub.trim()))) {
        return true;
      }
    }
    if (normText.contains(normConcept)) return true;
    final parts = normConcept.split(RegExp(r'\s+'));
    return parts.where((p) => p.length > 3).any((p) => normText.contains(p));
  }

  // Métodos de Mock Interview
  void _startMockRecording() async {
    if (!_speechInitialized) {
      await _initSpeech();
    }
    // Reasegurar locale en español antes de iniciar
    await _resolveSpanishLocale();

    final question = _currentInterviewQuestion;
    final limit = question.timeLimitSeconds;

    setState(() {
      _isRecording = true;
      _recordingSeconds = limit;
      _accumulatedTranscript = '';
      _currentSessionTranscript = '';
      _answerTextController.clear();
      _aiEvaluation = null;
    });

    _startSpeechSession(limit);

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_recordingSeconds > 1) {
        setState(() => _recordingSeconds--);
      } else {
        _stopMockRecording();
      }
    });
  }

  Future<void> _startSpeechSession(int secondsRemaining) async {
    if (!_isSpeechAvailable || !_isRecording) return;
    _isRestarting = true;
    try {
      // Detener sesión anterior y esperar a que Android la libere
      if (_speech.isListening) {
        await _speech.stop();
        // Dar tiempo al OS Android para liberar el MediaRecorder
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!_isRecording || !mounted) {
        _isRestarting = false;
        return;
      }

      await _speech.listen(
        onResult: (result) {
          if (!mounted || !_isRecording || _mockInputMode != 'voice') return;
          setState(() {
            _currentSessionTranscript = result.recognizedWords;
            final full = _accumulatedTranscript.isEmpty
                ? _currentSessionTranscript
                : '$_accumulatedTranscript $_currentSessionTranscript';
            _answerTextController.text = full;
          });
          if (result.finalResult) {
            _commitCurrentSessionWords();
          }
        },
        // listenFor = tiempo real restante, pero mínimo 5s para evitar micro-sesiones
        listenFor: Duration(seconds: secondsRemaining.clamp(5, 300)),
        // pauseFor corto: 3s de silencio cierra la sesión y dispara 'done' para reiniciar
        pauseFor: const Duration(seconds: 3),
        localeId: _currentLocaleId,
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        ),
      );
      debugPrint('Speech session started: locale=$_currentLocaleId, secs=$secondsRemaining');
    } catch (e) {
      debugPrint("Error listening speech session: $e");
    } finally {
      // Siempre liberar el flag para que futuros reinicios puedan ejecutarse
      _isRestarting = false;
    }
  }

  void _commitCurrentSessionWords() {
    if (_currentSessionTranscript.trim().isNotEmpty) {
      if (_accumulatedTranscript.isEmpty) {
        _accumulatedTranscript = _currentSessionTranscript.trim();
      } else {
        _accumulatedTranscript = '$_accumulatedTranscript ${_currentSessionTranscript.trim()}';
      }
      _currentSessionTranscript = '';
    }
  }

  void _restartListening() {
    if (!_isRecording || _recordingSeconds <= 2 || _isRestarting || _mockInputMode != 'voice') return;
    _restartTimer?.cancel(); // Cancelar cualquier restart pendiente duplicado
    _commitCurrentSessionWords();
    _startSpeechSession(_recordingSeconds);
  }

  void _stopMockRecording({bool preserveUserInput = false}) async {
    _recordingTimer?.cancel();
    _restartTimer?.cancel(); // Evitar que se inicie una nueva sesion tras parar
    _isRestarting = false;   // Liberar guard por si habia un restart en vuelo
    if (_speech.isListening) {
      try {
        await _speech.stop();
      } catch (_) {}
    }
    _commitCurrentSessionWords();
    // Solo actualizar el controlador si estamos en modo voz y NO se pidió preservar el texto del usuario
    if (!preserveUserInput && _mockInputMode == 'voice' && _accumulatedTranscript.isNotEmpty) {
      _answerTextController.text = _accumulatedTranscript;
    }
    setState(() {
      _isRecording = false;
    });
  }

  void _evaluateWithAi() async {
    final text = _answerTextController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe o dicta una respuesta antes de evaluar.")),
      );
      return;
    }

    _stopMockRecording(preserveUserInput: true);

    final question = _currentInterviewQuestion;

    setState(() {
      _isEvaluatingAi = true;
      _aiEvaluation = null;
    });

    // Calcular checklist de conceptos en base al texto
    final localCovered = <String>[];
    final localMissed = <String>[];
    for (final c in question.keyConcepts) {
      if (_isConceptMentioned(c, text)) {
        localCovered.add(c);
      } else {
        localMissed.add(c);
      }
    }

    final userId = await UserService.getUserId();
    final eval = await _mockRepo.evaluateAnswer(
      userId: userId,
      questionId: question.id,
      transcript: text,
      durationSeconds: question.timeLimitSeconds - _recordingSeconds,
    );

    if (mounted && _mockRepo.lastNotice != null && eval == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mockRepo.lastNotice!),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    setState(() {
      _isEvaluatingAi = false;
      if (eval != null) {
        _aiEvaluation = AiEvaluationResult(
          score: eval.score,
          technicalScore: eval.technicalScore,
          communicationScore: eval.communicationScore,
          tradeoffScore: eval.tradeoffScore,
          seniorityVerdict: eval.seniorityVerdict,
          verdictBadge: eval.verdictBadge,
          conceptsCovered: eval.conceptsCovered.isNotEmpty ? eval.conceptsCovered : localCovered,
          conceptsMissed: eval.conceptsMissed.isNotEmpty ? eval.conceptsMissed : localMissed,
          strengths: eval.strengths,
          improvements: eval.improvements,
          feedback: eval.feedback,
          followUpQuestion: eval.followUpQuestion.isNotEmpty ? eval.followUpQuestion : question.followUpQuestion,
          idealResponse: eval.idealResponse.isNotEmpty ? eval.idealResponse : question.idealResponse,
          xpEarned: eval.xpEarned,
        );
      } else {
        final ratio = question.keyConcepts.isNotEmpty
            ? localCovered.length / question.keyConcepts.length
            : 0.5;
        final score = (40 + (ratio * 55)).round().clamp(30, 95);
        final techScore = (35 + (ratio * 60)).round().clamp(30, 98);
        final commScore = (50 + (text.split(RegExp(r'\s+')).length > 20 ? 35 : 15)).round().clamp(40, 95);
        final tradeScore = (35 + (ratio * 55)).round().clamp(30, 92);

        String verdict = 'Senior Java Engineer';
        String badge = '🎖️ SENIOR JAVA ENGINEER';
        if (score < 55) {
          verdict = 'Junior Java Developer';
          badge = '🌱 JUNIOR DEVELOPER';
        } else if (score < 75) {
          verdict = 'Mid-Level Java Engineer';
          badge = '⚡ MID-LEVEL ENGINEER';
        }

        _aiEvaluation = AiEvaluationResult(
          score: score,
          technicalScore: techScore,
          communicationScore: commScore,
          tradeoffScore: tradeScore,
          seniorityVerdict: verdict,
          verdictBadge: badge,
          conceptsCovered: localCovered.isNotEmpty ? localCovered : ['Fundamentos del problema'],
          conceptsMissed: localMissed,
          strengths: [
            'Estructura clara al abordar la pregunta técnica.',
            if (localCovered.isNotEmpty) 'Mención acertada de: ${localCovered.join(", ")}.'
          ],
          improvements: [
            if (localMissed.isNotEmpty) 'Faltó profundizar en: ${localMissed.join(", ")}.',
            'Menciona trade-offs de memoria y aislamiento.'
          ],
          feedback:
              'Demostraste comprensión conceptual. Para destacar en entrevistas Senior/Staff, relaciona siempre cada término con el ciclo de vida de los hilos y aislamiento de memoria.',
          followUpQuestion: question.followUpQuestion.isNotEmpty
              ? question.followUpQuestion
              : '¿Qué alternativa usarías si se requiere almacenar datos por petición de usuario?',
          idealResponse: question.idealResponse,
          xpEarned: 50,
        );
      }
    });
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

    final currentWorld = _worlds.isNotEmpty ? _worlds[_selectedWorldIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopGamificationBar(),
      body: currentWorld == null
          ? const Center(child: Text("Cargando datos...", style: TextStyle(color: Colors.white)))
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  // Selector de Mundos (0 al 10)
                  _buildWorldSelectorBar(),

                  // Pestañas Superiores de Modo (Lecciones, Repaso SM-2, Mock Interview)
                  _buildModeSwitcher(),

                  // Contenido dinámico según la pestaña activa
                  Expanded(
                    child: _buildCurrentTabContent(currentWorld),
                  ),
                ],
              ),
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
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.duolingoGold, size: 24),
              const SizedBox(width: 2),
              Text(
                "$_userXp XP",
                style: const TextStyle(
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
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          tooltip: 'Ajustes e Inmersión',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWorldSelectorBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedWorldIndex,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
          items: List.generate(_worlds.length, (idx) {
            final w = _worlds[idx];
            final prefix = w.badge.isNotEmpty ? "${w.badge} " : (idx == 0 ? "🐣 " : "🌱 ");
            return DropdownMenuItem<int>(
              value: idx,
              child: Text(
                "$prefix${w.title}",
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          onChanged: (newIdx) {
            if (newIdx != null) {
              if (_isRecording) {
                _stopMockRecording(preserveUserInput: true);
              }
              setState(() {
                _selectedWorldIndex = newIdx;
                _selectedMockQuestionIndex = 0;
                _aiEvaluation = null;
                _answerTextController.clear();
                _accumulatedTranscript = '';
                _currentSessionTranscript = '';
                final q = _currentInterviewQuestion;
                _recordingSeconds = q.timeLimitSeconds;
              });
            }
          },
        ),
      ),
    );
  }

  // Pestañas idénticas a index.html: LECCIONES & CAMINO | REPASO SM-2 | MOCK INTERVIEW
  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          _buildModeTab(AppTab.path, "LECCIONES & CAMINO"),
          _buildModeTab(AppTab.srs, "🧠 REPASO ($_srsDueCount)"),
          _buildModeTab(AppTab.mock, "🎙️ MOCK INTERVIEW"),
        ],
      ),
    );
  }

  Widget _buildModeTab(AppTab tab, String label) {
    final isActive = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Color(0xFF337A01),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(World currentWorld) {
    switch (_currentTab) {
      case AppTab.srs:
        return _buildSrsView();
      case AppTab.mock:
        return _buildMockInterviewView();
      case AppTab.path:
      default:
        return _buildPathView(currentWorld);
    }
  }

  // ==========================================
  // 1. VISTA DE CAMINO & LECCIONES (DUOLINGO)
  // ==========================================
  Widget _buildPathView(World currentWorld) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // Banner de Mock Interview
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildMockInterviewBanner(),
        ),

        // Tarjeta de Cabecera del Mundo actual
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildWorldHeaderCard(currentWorld),
        ),

        const SizedBox(height: 16),

        // Caminito serpenteante en S
        ..._buildZigzagPath(currentWorld),
      ],
    );
  }

  Widget _buildMockInterviewBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3A00), Color(0xFFFF9600)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Mock Interview Bajo Presión",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Preguntas trampa, audio y checklist técnico",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentTab = AppTab.mock);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("PROBAR", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldHeaderCard(World world) {
    final completedCount = _completedLevels[world.id] ?? 0;
    final totalLessons = world.lessons.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: world.color.withOpacity(0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: world.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedWorldIndex == 0 ? "MÓDULO ONBOARDING" : "MÓDULO $_selectedWorldIndex DE 10",
                  style: TextStyle(
                    color: world.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "$completedCount de $totalLessons Niveles",
                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            world.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            world.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildDiffButton("easy", "⚡ ÁGIL (5)"),
              const SizedBox(width: 8),
              _buildDiffButton("normal", "🎯 NORMAL (7)"),
              const SizedBox(width: 8),
              _buildDiffButton("hard", "🔥 SENIOR (10)"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiffButton(String key, String label) {
    final isSelected = _difficulty == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setDifficulty(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreenDark : AppColors.surfaceBorder,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildZigzagPath(World world) {
    final completedCount = _completedLevels[world.id] ?? 0;
    final totalLessons = world.lessons.length;
    final offsets = [-50.0, -25.0, 20.0, 55.0, 25.0, -20.0, -50.0, -25.0, 25.0, 0.0];
    final chestMilestone = totalLessons <= 5 ? 3 : 5;

    final widgets = <Widget>[];

    for (int i = 0; i < totalLessons; i++) {
      final lesson = world.lessons[i];
      final num = i + 1;
      final isCompleted = num <= completedCount;
      final isCurrent = num == completedCount + 1;
      final isLocked = num > completedCount + 1;
      final xOffset = offsets[i % offsets.length];

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Transform.translate(
              offset: Offset(xOffset, 0),
              child: _buildSteppingStoneNode(
                lesson: lesson,
                num: num,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLocked: isLocked,
                world: world,
              ),
            ),
          ),
        ),
      );

      if (num == chestMilestone) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Transform.translate(
                offset: const Offset(40, 0),
                child: _buildChestNode(),
              ),
            ),
          ),
        );
      }
    }

    final isBossUnlocked = completedCount >= totalLessons;
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 20),
        child: Center(
          child: _buildBossCastleNode(isBossUnlocked, world),
        ),
      ),
    );

    return widgets;
  }

  Widget _buildSteppingStoneNode({
    required Lesson lesson,
    required int num,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required World world,
  }) {
    Color bg;
    Color border;
    Color shadow;
    Widget icon;

    if (isCompleted) {
      bg = AppColors.primaryGreen;
      border = const Color(0xFF46A302);
      shadow = const Color(0xFF337A01);
      icon = const Icon(Icons.star_rounded, color: Colors.white, size: 34);
    } else if (isCurrent) {
      bg = AppColors.duolingoGold;
      border = const Color(0xFFD9A700);
      shadow = const Color(0xFFA88100);
      icon = const Icon(Icons.workspace_premium_rounded, color: Color(0xFF13141B), size: 34);
    } else {
      bg = AppColors.surface;
      border = AppColors.surfaceBorder;
      shadow = const Color(0xFF14151D);
      icon = const Icon(Icons.lock_rounded, color: AppColors.textDisabled, size: 28);
    }

    final stone = GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🔒 Completa los niveles anteriores del caminito para desbloquear esta lección."),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        _openLesson(lesson, num, world);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryGreen, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, offset: Offset(0, 4), blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "⚡ +${lesson.xpReward} XP • $_questionLimit preguntas",
                    style: const TextStyle(color: AppColors.duolingoGold, fontWeight: FontWeight.w800, fontSize: 10),
                  ),
                ],
              ),
            ),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bg,
              border: Border.all(color: border, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
                if (isCurrent)
                  BoxShadow(
                    color: AppColors.duolingoGold.withOpacity(0.4),
                    offset: const Offset(0, 0),
                    blurRadius: 18,
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                icon,
                Positioned(
                  bottom: 6,
                  child: Text(
                    "$num",
                    style: TextStyle(
                      color: isCurrent ? Colors.black87 : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isCurrent) {
      return ScaleTransition(scale: _pulseAnimation, child: stone);
    }
    return stone;
  }

  Widget _buildChestNode() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎁 ¡Abriste un Cofre de Recompensa! Recibiste +25 XP y +1 Vida ❤️"),
            backgroundColor: AppColors.duolingoPurple,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFCE82FF), Color(0xFF9B30FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFE2ADFF), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF6810B8),
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text("🎁", style: TextStyle(fontSize: 26)),
      ),
    );
  }

  Widget _buildBossCastleNode(bool isUnlocked, World world) {
    final isDefeated = _completedBosses.contains(world.id);
    final boss = world.bossChallenge;

    return GestureDetector(
      onTap: () {
        if (!isUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🔒 Debes completar los ${world.lessons.length} niveles del caminito para enfrentarte al Jefe Final."),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _openBossChallenge(world);
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: isDefeated
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF9600)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : (isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4B4B), Color(0xFFFF9600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null),
          color: (isUnlocked || isDefeated) ? null : AppColors.surface,
          border: Border.all(
            color: isDefeated
                ? Colors.amberAccent
                : (isUnlocked ? Colors.white : AppColors.surfaceBorder),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDefeated
                  ? const Color(0xFFA88100)
                  : (isUnlocked ? const Color(0xFFBA2222) : const Color(0xFF14151D)),
              offset: const Offset(0, 7),
              blurRadius: 0,
            ),
            if (isUnlocked || isDefeated)
              BoxShadow(
                color: isDefeated
                    ? AppColors.duolingoGold.withOpacity(0.7)
                    : AppColors.errorRed.withOpacity(0.6),
                offset: const Offset(0, 0),
                blurRadius: 22,
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isDefeated
                  ? "👑"
                  : (isUnlocked ? (boss?.bossAvatar ?? "🏰") : "🔒"),
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 2),
            Text(
              isDefeated ? "VENCIDO" : "DESAFÍO",
              style: TextStyle(
                color: (isUnlocked || isDefeated) ? const Color(0xFF13141B) : AppColors.textDisabled,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. VISTA DE REPASO ESPACIADO SM-2 (EBBINGHAUS)
  // ==========================================
  Widget _buildSrsView() {
    final card = _srsDemoCards[_srsCurrentCardIndex % _srsDemoCards.length];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Banner de Curva del Olvido
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2638), Color(0xFF161924)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CURVA DEL OLVIDO (EBBINGHAUS)",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            "82%",
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Retención Proyectada",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.duolingoGold.withOpacity(0.15),
                      border: Border.all(color: AppColors.duolingoGold),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "EF: 2.51",
                      style: TextStyle(
                        color: AppColors.duolingoGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildSrsStatBox("$_srsDueCount", "⏳ Para Hoy", AppColors.duolingoOrange),
                  const SizedBox(width: 8),
                  _buildSrsStatBox("4", "🌱 Aprendiendo", AppColors.duolingoBlue),
                  const SizedBox(width: 8),
                  _buildSrsStatBox("1", "👑 Dominadas", AppColors.primaryGreen),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tarjeta de Flashcard Interactiva SM-2
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.duolingoBlue.withOpacity(0.4), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.duolingoBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card['category'] ?? 'Java Core',
                      style: const TextStyle(
                        color: AppColors.duolingoBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Tarjeta ${_srsCurrentCardIndex + 1} de ${_srsDemoCards.length}",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                card['question']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              if (_srsShowAnswer) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.5)),
                  ),
                  child: Text(
                    card['answer']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "¿Qué tan fácil fue recordarlo?",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSrsRatingButton("No me acordé", AppColors.errorRed, 1),
                    const SizedBox(width: 6),
                    _buildSrsRatingButton("Difícil", AppColors.duolingoOrange, 3),
                    const SizedBox(width: 6),
                    _buildSrsRatingButton("Bien", AppColors.duolingoBlue, 4),
                    const SizedBox(width: 6),
                    _buildSrsRatingButton("Fácil", AppColors.primaryGreen, 5),
                  ],
                ),
              ] else
                ElevatedButton(
                  onPressed: () => setState(() => _srsShowAnswer = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("MOSTRAR RESPUESTA", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSrsStatBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSrsRatingButton(String label, Color color, int quality) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _srsShowAnswer = false;
            _srsCurrentCardIndex = (_srsCurrentCardIndex + 1) % _srsDemoCards.length;
            if (_srsDueCount > 0 && quality >= 4) {
              _srsDueCount--;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Intervalo SM-2 recalculado ($label)."),
              backgroundColor: color,
              duration: const Duration(milliseconds: 1200),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. VISTA DE MOCK INTERVIEW SIMULATOR CON IA
  // ==========================================
  Widget _buildAudioWaveVisualizer() {
    final heights = [14.0, 26.0, 32.0, 22.0, 16.0];
    final colors = [
      AppColors.duolingoBlue,
      AppColors.duolingoGold,
      AppColors.primaryGreen,
      const Color(0xFFA461D8),
      AppColors.duolingoOrange,
    ];

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final factor = (_pulseController.value + (index * 0.2)) % 1.0;
              final dynamicHeight = 8.0 + (heights[index] - 8.0) * (0.4 + 0.6 * factor);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 5,
                height: _isRecording ? dynamicHeight : 6,
                decoration: BoxDecoration(
                  color: _isRecording ? colors[index] : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMockInterviewView() {
    final question = _currentInterviewQuestion;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Selector de Pregunta de Entrevista con protección de overflow
        Row(
          children: [
            const Expanded(
              child: Text(
                "🎙️ SIMULADOR DE ENTREVISTA CON IA",
                style: TextStyle(
                  color: AppColors.duolingoOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: () {
                if (_isRecording) {
                  _stopMockRecording(preserveUserInput: true);
                }
                final list = _activeWorldQuestions;
                setState(() {
                  _selectedMockQuestionIndex =
                      (_selectedMockQuestionIndex + 1) % (list.isNotEmpty ? list.length : 1);
                  _aiEvaluation = null;
                  _answerTextController.clear();
                  _accumulatedTranscript = '';
                  _currentSessionTranscript = '';
                  final q = _currentInterviewQuestion;
                  _recordingSeconds = q.timeLimitSeconds;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Text("🎲", style: TextStyle(fontSize: 13)),
              label: const Text(
                "OTRA PREGUNTA",
                style: TextStyle(color: AppColors.duolingoGold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Tarjeta de la Pregunta adaptada al mundo activo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2638), Color(0xFF141724)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                    ),
                    child: Text(
                      _worlds.isNotEmpty && _selectedWorldIndex < _worlds.length
                          ? "${_worlds[_selectedWorldIndex].badge} ${_worlds[_selectedWorldIndex].title.split(':').first.toUpperCase()}"
                          : "🐣 MUNDO 0",
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    "PREGUNTA ${_activeWorldQuestions.isEmpty ? 1 : (_selectedMockQuestionIndex % _activeWorldQuestions.length) + 1} DE ${_activeWorldQuestions.length}",
                    style: const TextStyle(color: AppColors.textDisabled, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "🍃 ${question.category.toUpperCase()}",
                style: const TextStyle(
                  color: AppColors.duolingoGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                question.title,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: AppColors.duolingoBlue, width: 3)),
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text("⏱️ Tiempo: ${question.timeLimitSeconds}s", style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11.5, fontWeight: FontWeight.bold)),
                  const Text("💡 Rúbrica: 3 Ejes (Técnico, Estructura, Trade-offs)", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        // Checklist en vivo: Qué cosas mencionar
        if (question.keyConcepts.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF151922),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.checklist_rounded, size: 16, color: AppColors.duolingoGold),
                    SizedBox(width: 6),
                    Text(
                      "💡 PUNTOS CLAVE A CUBRIR (QUÉ COSAS DECIR):",
                      style: TextStyle(
                        color: AppColors.duolingoGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: question.keyConcepts.map((concept) {
                    final isMentioned = _isConceptMentioned(concept, _answerTextController.text);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isMentioned
                            ? AppColors.primaryGreen.withOpacity(0.2)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isMentioned ? AppColors.primaryGreen : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMentioned ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            size: 13,
                            color: isMentioned ? AppColors.primaryGreen : Colors.white54,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            concept,
                            style: TextStyle(
                              color: isMentioned ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: isMentioned ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Selector de Modo: Dictar por voz vs Escribir respuesta
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_mockInputMode != 'voice') {
                    setState(() => _mockInputMode = 'voice');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _mockInputMode == 'voice' ? AppColors.primaryGreen : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mockInputMode == 'voice' ? AppColors.primaryGreenDark : AppColors.surfaceBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text("🎙️ DICTAR POR VOZ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isRecording) {
                    _stopMockRecording(preserveUserInput: true);
                  }
                  setState(() => _mockInputMode = 'text');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _mockInputMode == 'text' ? AppColors.primaryGreen : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mockInputMode == 'text' ? AppColors.primaryGreenDark : AppColors.surfaceBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text("✍️ ESCRIBIR RESPUESTA", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Panel de Entrada (Voz o Texto)
        if (_mockInputMode == 'voice') ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isRecording ? AppColors.errorRed : AppColors.surfaceBorder,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "$_recordingSeconds s",
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: _recordingSeconds <= 10 ? AppColors.errorRed : AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isRecording
                      ? "🔴 Escuchando y transcribiendo en vivo... Habla con claridad."
                      : "Presiona el botón para comenzar a hablar. El sistema transcribirá tu voz en vivo.",
                  style: TextStyle(
                    color: _isRecording ? AppColors.errorRed : AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🇪🇸", style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        "Micrófono en Español (${_currentLocaleId.replaceAll('_', '-')})",
                        style: const TextStyle(color: AppColors.duolingoGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildAudioWaveVisualizer(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isRecording ? () => _stopMockRecording() : _startMockRecording,
                  icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 20),
                  label: Text(
                    _isRecording
                        ? "⏹️ DETENER GRABACIÓN"
                        : (_answerTextController.text.trim().isEmpty ? "🎙️ INICIAR RESPUESTA" : "🎙️ REINICIAR RESPUESTA"),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? AppColors.errorRed : AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 16),
                // Caja de Transcripción en tiempo real
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TRANSCRIPCIÓN EN TIEMPO REAL:",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          "$_wordCount palabras",
                          style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(minHeight: 85, maxHeight: 150),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                      ),
                      child: TextField(
                        controller: _answerTextController,
                        maxLines: null,
                        onChanged: (val) {
                          _accumulatedTranscript = val;
                          setState(() {});
                        },
                        style: const TextStyle(color: Color(0xFFECEFF4), fontSize: 13, height: 1.4),
                        decoration: const InputDecoration(
                          hintText: "Tu respuesta hablada o editada aparecerá aquí en tiempo real...",
                          hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Escribe tu respuesta técnica:",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                    Text("$_wordCount palabras",
                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                  ),
                  child: TextField(
                    controller: _answerTextController,
                    maxLines: 5,
                    onChanged: (val) {
                      _accumulatedTranscript = val;
                      setState(() {});
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.45),
                    decoration: const InputDecoration(
                      hintText: "Desarrolla aquí tu respuesta técnica para el entrevistador. Menciona mecanismos de la JVM, anotaciones, impacto en concurrencia y trade-offs...",
                      hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 12.5),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Botón Azul: EVALUAR RESPUESTA CON IA (+50 XP)
        ElevatedButton(
          onPressed: _isEvaluatingAi ? null : _evaluateWithAi,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.duolingoBlue,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: _isEvaluatingAi
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text("🧠 EVALUANDO CON IA...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                )
              : const Text(
                  "🤖 EVALUAR RESPUESTA CON IA (+50 XP)",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
        ),

        // Resultados de Evaluación con IA (Rúbrica de 3 ejes, veredicto y feedback)
        if (_aiEvaluation != null) ...[
          const SizedBox(height: 18),
          _buildAiEvaluationReport(question),
        ],

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildAiEvaluationReport(InterviewQuestion question) {
    final ev = _aiEvaluation!;
    Color badgeColor = AppColors.primaryGreen;
    if (ev.score >= 85) {
      badgeColor = AppColors.duolingoGold;
    } else if (ev.score >= 70) {
      badgeColor = AppColors.duolingoBlue;
    } else if (ev.score < 55) {
      badgeColor = AppColors.errorRed;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2333), Color(0xFF151822)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: badgeColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 6), blurRadius: 14),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Score General + Veredicto (Anti-overflow responsive)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CALIFICACIÓN GENERAL IA",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${ev.score}%",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: badgeColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            "Score Ponderado",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor, width: 1.5),
                  ),
                  child: Text(
                    ev.verdictBadge,
                    style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Desglose por 3 Ejes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DESGLOSE POR 3 EJES DE EVALUACIÓN:",
                  style: TextStyle(color: AppColors.duolingoGold, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
                const SizedBox(height: 10),
                _buildAxisScore("🎯 Precisión Técnica", ev.technicalScore, AppColors.primaryGreen),
                const SizedBox(height: 8),
                _buildAxisScore("🗣️ Estructura & Comunicación", ev.communicationScore, AppColors.duolingoBlue),
                const SizedBox(height: 8),
                _buildAxisScore("⚖️ Análisis de Trade-offs", ev.tradeoffScore, AppColors.duolingoOrange),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Checklist de Conceptos Detectados vs Faltantes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CONCEPTOS DETECTADOS POR LA IA:",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...ev.conceptsCovered.map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryGreen),
                        ),
                        child: Text("✅ $c",
                            style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w800)),
                      )),
                  ...ev.conceptsMissed.map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.errorRed.withOpacity(0.5)),
                        ),
                        child: Text("⚠️ $c",
                            style: const TextStyle(color: Color(0xFFFFA0A0), fontSize: 11, fontWeight: FontWeight.w700)),
                      )),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Feedback del Entrevistador
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.duolingoBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: AppColors.duolingoBlue, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FEEDBACK DEL ENTREVISTADOR:",
                  style: TextStyle(color: AppColors.duolingoBlue, fontSize: 10.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  ev.feedback,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.45),
                ),
              ],
            ),
          ),

          // Repregunta del Entrevistador (Follow-up)
          if (ev.followUpQuestion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.duolingoGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.duolingoGold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "⚡ REPREGUNTA DEL ENTREVISTADOR (FOLLOW-UP):",
                    style: TextStyle(color: AppColors.duolingoGold, fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\"${ev.followUpQuestion}\"",
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          // Respuesta Benchmark de Referencia (Staff Architect)
          if (ev.idealResponse.isNotEmpty) ...[
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                backgroundColor: AppColors.surface,
                collapsedBackgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                title: const Text(
                  "🏆 Ver Respuesta Benchmark (Staff Architect)",
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
                children: [
                  Text(
                    ev.idealResponse,
                    style: const TextStyle(color: Color(0xFFECEFF4), fontSize: 12, height: 1.45),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Botones de Acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _aiEvaluation = null;
                      _answerTextController.clear();
                      _recordingSeconds = question.timeLimitSeconds;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("🔄 OTRA VEZ", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    final list = _activeWorldQuestions;
                    setState(() {
                      _selectedMockQuestionIndex =
                          (_selectedMockQuestionIndex + 1) % (list.isNotEmpty ? list.length : 1);
                      _aiEvaluation = null;
                      _answerTextController.clear();
                      _accumulatedTranscript = '';
                      _currentSessionTranscript = '';
                      final q = _currentInterviewQuestion;
                      _recordingSeconds = q.timeLimitSeconds;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("🎲 SIGUIENTE", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAxisScore(String title, num score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
            Text("${score.toInt()}%", style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
