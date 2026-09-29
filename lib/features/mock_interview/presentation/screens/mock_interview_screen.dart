import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../domain/models/interview_question.dart';

class MockInterviewScreen extends StatefulWidget {
  final InterviewQuestion question;

  const MockInterviewScreen({super.key, required this.question});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRecording = false;
  bool _isFinished = false;
  final Set<int> _checkedConcepts = {};

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.question.timeLimitSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isFinished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "SIMULADOR DE ENTREVISTA",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppColors.duolingoOrange,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.question.title,
                style: const TextStyle(
                  color: AppColors.duolingoGold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.question.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              // Timer & Recording status card
              Container(
                padding: const EdgeInsets.all(20),
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
                      "$_remainingSeconds s",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: _remainingSeconds <= 10
                            ? AppColors.errorRed
                            : AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRecording
                          ? "🔴 Grabando tu respuesta técnica en voz alta..."
                          : _isFinished
                              ? "✅ Tiempo concluido. Autoevalúa tu respuesta:"
                              : "Prepárate y pulsa grabar para responder bajo presión",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                    ),
                    const SizedBox(height: 16),
                    if (!_isFinished)
                      ElevatedButton.icon(
                        onPressed: _isRecording ? _stopRecording : _startRecording,
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        label: Text(_isRecording ? "TERMINAR RESPUESTA" : "INICIAR GRABACIÓN"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isRecording ? AppColors.errorRed : AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isFinished) ...[
                const SizedBox(height: 24),
                const Text(
                  "CONCEPTOS CLAVE A MENCIONAR",
                  style: TextStyle(
                    color: AppColors.duolingoBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(widget.question.keyConcepts.length, (idx) {
                  final concept = widget.question.keyConcepts[idx];
                  final isChecked = _checkedConcepts.contains(idx);
                  return CheckboxListTile(
                    value: isChecked,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryGreen,
                    title: Text(
                      concept,
                      style: TextStyle(
                        color: isChecked ? Colors.white : AppColors.textSecondary,
                        fontSize: 14.5,
                        fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _checkedConcepts.add(idx);
                        } else {
                          _checkedConcepts.remove(idx);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 20),
                const Text(
                  "RESPUESTA TÉCNICA IDEAL",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Text(
                    widget.question.idealResponse,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    final scoreRatio = _checkedConcepts.length / widget.question.keyConcepts.length;
                    final xp = (scoreRatio * 50).round();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.successBg,
                        content: Text("¡Autoevaluación guardada! +$xp XP sumados a tu racha."),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("GUARDAR AUTOEVALUACIÓN"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
