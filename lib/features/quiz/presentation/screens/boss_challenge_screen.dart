import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:java_play_app/core/constants/app_colors.dart';
import 'package:java_play_app/features/learning_path/domain/models/world.dart';
import 'package:java_play_app/features/learning_path/domain/models/boss_challenge.dart';
import 'package:java_play_app/features/learning_path/data/boss_repository.dart';
import 'package:java_play_app/features/quiz/domain/models/exercise.dart';
import '../widgets/types/multiple_choice_view.dart';
import '../widgets/types/spot_the_bug_view.dart';
import '../widgets/types/token_reorder_view.dart';

class BossChallengeScreen extends StatefulWidget {
  final World world;
  final BossChallenge bossChallenge;
  final String userId;

  const BossChallengeScreen({
    super.key,
    required this.world,
    required this.bossChallenge,
    this.userId = 'user_1',
  });

  @override
  State<BossChallengeScreen> createState() => _BossChallengeScreenState();
}

class _BossChallengeScreenState extends State<BossChallengeScreen> with SingleTickerProviderStateMixin {
  late final List<Exercise> _exercises;
  int _currentIndex = 0;
  int _playerLives = 3;
  late double _bossHp;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isFinished = false;
  bool _isVictory = false;
  bool _isSavingProgress = false;

  // Exercise state
  int? _selectedMultipleChoiceIndex;
  int? _selectedBugLineIndex;
  List<String> _userOrderedTokens = [];
  List<String> _availableTokens = [];

  bool _isVerified = false;
  bool _wasLastCorrect = false;

  final BossRepository _bossRepo = BossRepository();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _exercises = widget.bossChallenge.exercises.isNotEmpty
        ? widget.bossChallenge.exercises
        : const [
            MultipleChoiceExercise(
              id: 'fallback_boss_1',
              question: '¿Qué principio garantiza alta disponibilidad y resiliencia en la JVM?',
              options: [
                'Contratos claros, inmutabilidad y gestión adecuada del Garbage Collector',
                'Variables globales estáticas mutables',
                'Captura vacía de excepciones',
                'Hilos sin control'
              ],
              correctAnswerIndex: 0,
              explanation: 'La arquitectura robusta en Java se apoya en contratos limpios y concurrencia segura.',
            )
          ];

    _bossHp = 100.0;
    _remainingSeconds = widget.bossChallenge.timeLimitSeconds > 0
        ? widget.bossChallenge.timeLimitSeconds
        : 180;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initCurrentExercise();
    _startTimer();
  }

  void _initCurrentExercise() {
    _selectedMultipleChoiceIndex = null;
    _selectedBugLineIndex = null;
    _isVerified = false;
    _wasLastCorrect = false;

    if (_currentIndex < _exercises.length) {
      final current = _exercises[_currentIndex];
      if (current is TokenReorderExercise) {
        final shuffled = List<String>.from(current.tokens)..shuffle();
        _availableTokens = shuffled;
        _userOrderedTokens = [];
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _onDefeat(reason: "¡Se agotó el tiempo de la batalla!");
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _canVerify {
    if (_isVerified) return false;
    final current = _exercises[_currentIndex];
    if (current is MultipleChoiceExercise) {
      return _selectedMultipleChoiceIndex != null;
    }
    if (current is SpotTheBugExercise) {
      return _selectedBugLineIndex != null;
    }
    if (current is TokenReorderExercise) {
      return _userOrderedTokens.isNotEmpty;
    }
    return true;
  }

  void _verifyAnswer() {
    if (!_canVerify) return;
    HapticFeedback.mediumImpact();

    final current = _exercises[_currentIndex];
    bool isCorrect = false;

    if (current is MultipleChoiceExercise) {
      isCorrect = _selectedMultipleChoiceIndex == current.correctAnswerIndex;
    } else if (current is SpotTheBugExercise) {
      isCorrect = _selectedBugLineIndex == current.buggyLineIndex;
    } else if (current is TokenReorderExercise) {
      isCorrect = _userOrderedTokens.join(' ') == current.correctOrder.join(' ');
    } else {
      isCorrect = true;
    }

    setState(() {
      _isVerified = true;
      _wasLastCorrect = isCorrect;

      if (isCorrect) {
        final damage = 100.0 / _exercises.length;
        _bossHp = (_bossHp - damage).clamp(0.0, 100.0);
      } else {
        _playerLives--;
      }
    });

    if (_playerLives <= 0) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) _onDefeat(reason: "El Jefe agotó todas tus vidas");
      });
    } else if (_bossHp <= 0 || _currentIndex >= _exercises.length - 1) {
      // Si el jefe murió o llegamos al final con vidas
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) _onVictory();
      });
    }
  }

  void _proceedToNext() {
    if (_currentIndex + 1 < _exercises.length) {
      setState(() {
        _currentIndex++;
        _initCurrentExercise();
      });
    } else {
      _onVictory();
    }
  }

  Future<void> _onVictory() async {
    _timer?.cancel();
    setState(() {
      _isFinished = true;
      _isVictory = true;
      _isSavingProgress = true;
    });

    // Guardar victoria local y sincronizar con Supabase
    try {
      await _bossRepo.recordBossDefeat(
        userId: widget.userId,
        worldId: widget.world.id,
        bossId: widget.bossChallenge.id,
        score: 100,
        xpAwarded: widget.bossChallenge.xpReward,
      );
    } catch (e) {
      debugPrint("Error saving boss victory: $e");
    } finally {
      if (mounted) setState(() => _isSavingProgress = false);
    }
  }

  void _onDefeat({required String reason}) {
    _timer?.cancel();
    setState(() {
      _isFinished = true;
      _isVictory = false;
    });
  }

  void _restartBattle() {
    setState(() {
      _currentIndex = 0;
      _playerLives = 3;
      _bossHp = 100.0;
      _remainingSeconds = widget.bossChallenge.timeLimitSeconds > 0
          ? widget.bossChallenge.timeLimitSeconds
          : 180;
      _isFinished = false;
      _isVictory = false;
      _initCurrentExercise();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _isVictory ? _buildVictoryScreen() : _buildDefeatScreen();
    }

    final currentExercise = _exercises[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1017),
      appBar: _buildBossAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildBossBattleHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _buildCurrentExerciseView(currentExercise),
              ),
            ),
            _buildActionBottomBar(currentExercise),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBossAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF141522),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white70),
        onPressed: () => _confirmExit(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.errorRed, width: 1),
                ),
                child: const Text(
                  "BATALLA DE JEFE",
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.world.title.split(':').first,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            widget.bossChallenge.title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        // Vidas del Jugador
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: List.generate(3, (index) {
              final isAlive = index < _playerLives;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  isAlive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isAlive ? AppColors.errorRed : AppColors.textDisabled,
                  size: 24,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBossBattleHeader() {
    final timerAlert = _remainingSeconds < 30;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161826),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF282B3E), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar animado del Jefe
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4B4B), Color(0xFFFF9600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4B4B).withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.bossChallenge.bossAvatar,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.bossChallenge.bossName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: timerAlert ? AppColors.errorRed : const Color(0xFF252738),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                "${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Barra de Vida del Jefe (HP Bar)
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _bossHp / 100.0,
                              minHeight: 12,
                              backgroundColor: const Color(0xFF282A3A),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _bossHp > 40 ? const Color(0xFFFF4B4B) : const Color(0xFFFF9600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${_bossHp.toInt()}% HP",
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Indicador de Progreso del Examen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pregunta ${_currentIndex + 1} de ${_exercises.length}",
                style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                "Umbral de Aprobación: ${widget.bossChallenge.passThreshold}%",
                style: const TextStyle(color: AppColors.duolingoGold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExerciseView(Exercise exercise) {
    if (exercise is MultipleChoiceExercise) {
      return MultipleChoiceView(
        exercise: exercise,
        selectedIndex: _selectedMultipleChoiceIndex,
        onSelect: (idx) {
          if (!_isVerified) setState(() => _selectedMultipleChoiceIndex = idx);
        },
      );
    } else if (exercise is SpotTheBugExercise) {
      return SpotTheBugView(
        exercise: exercise,
        selectedLineIndex: _selectedBugLineIndex,
        onSelectLine: (idx) {
          if (!_isVerified) setState(() => _selectedBugLineIndex = idx);
        },
      );
    } else if (exercise is TokenReorderExercise) {
      return TokenReorderView(
        exercise: exercise,
        userOrderedTokens: _userOrderedTokens,
        availableTokens: _availableTokens,
        onSelectToken: (token) {
          if (!_isVerified) {
            setState(() {
              _availableTokens.remove(token);
              _userOrderedTokens.add(token);
            });
          }
        },
        onRemoveToken: (idx) {
          if (!_isVerified) {
            setState(() {
              final token = _userOrderedTokens.removeAt(idx);
              _availableTokens.add(token);
            });
          }
        },
      );
    }

    return Center(
      child: Text(
        exercise.title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildActionBottomBar(Exercise currentExercise) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _isVerified
            ? (_wasLastCorrect ? const Color(0xFF14301B) : const Color(0xFF381519))
            : const Color(0xFF161826),
        border: Border(
          top: BorderSide(
            color: _isVerified
                ? (_wasLastCorrect ? AppColors.primaryGreen : AppColors.errorRed)
                : const Color(0xFF282B3E),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isVerified) ...[
            Row(
              children: [
                Icon(
                  _wasLastCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: _wasLastCorrect ? AppColors.primaryGreen : AppColors.errorRed,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _wasLastCorrect ? "¡GOLPE CRÍTICO AL JEFE!" : "¡ATAQUE BLOQUEADO!",
                    style: TextStyle(
                      color: _wasLastCorrect ? AppColors.primaryGreen : AppColors.errorRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currentExercise.explanation,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isVerified
                  ? _proceedToNext
                  : (_canVerify ? _verifyAnswer : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVerified
                    ? (_wasLastCorrect ? AppColors.primaryGreen : AppColors.errorRed)
                    : const Color(0xFFFF9600),
                disabledBackgroundColor: const Color(0xFF2E303E),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _isVerified ? "CONTINUAR" : "LANZAR ATAQUE",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1017),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC800), Color(0xFFFF9600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC800).withOpacity(0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text("🏆", style: TextStyle(fontSize: 54)),
                ),
                const SizedBox(height: 24),
                const Text(
                  "¡JEFE DERROTADO!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Has conquistado el ${widget.world.title}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.duolingoGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.duolingoGold, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("⭐", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        "+${widget.bossChallenge.xpReward} XP GANADOS",
                        style: const TextStyle(
                          color: AppColors.duolingoGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_done_rounded, color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _isSavingProgress ? "Sincronizando con Supabase..." : "Guardado en Supabase PostgreSQL",
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text(
                      "CONTINUAR EN EL CAMINITO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefeatScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1017),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.errorRed.withOpacity(0.15),
                    border: Border.all(color: AppColors.errorRed, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text("💀", style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 24),
                const Text(
                  "EL JEFE FUE DEMASIADO FUERTE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "No te desanimes. Revisa los conceptos del módulo, afina tu memoria y vuelve a intentarlo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _restartBattle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "REINTENTAR DESAFÍO",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "VOLVER AL MAPA",
                    style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F29),
        title: const Text("¿Abandonar la Batalla de Jefe?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Perderás el progreso de este combate contra el Jefe.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("SEGUIR LUCHANDO", style: TextStyle(color: AppColors.primaryGreen)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text("SALIR", style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
