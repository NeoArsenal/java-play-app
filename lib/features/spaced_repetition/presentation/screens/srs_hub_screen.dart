import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/srs_controller.dart';
import '../../../quiz/domain/models/exercise.dart';

class SrsHubScreen extends ConsumerWidget {
  const SrsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srsState = ref.watch(srsProvider);
    final srsNotifier = ref.read(srsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "🧠 Memoria & Repaso SM-2",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: () => srsNotifier.loadSrsData(),
          ),
        ],
      ),
      body: srsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRetentionBanner(srsState.stats),
                  const SizedBox(height: 18),
                  if (srsState.isSessionCompleted)
                    _buildCompletedSessionView(srsState, srsNotifier)
                  else if (srsState.currentCard != null)
                    _buildActiveCardReview(srsState, srsNotifier)
                  else
                    _buildEmptyQueueView(srsNotifier),
                ],
              ),
            ),
    );
  }

  Widget _buildRetentionBanner(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2638), Color(0xFF161924)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 6), blurRadius: 12),
        ],
      ),
      child: Column(
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
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        stats.retentionRate,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Retención Proyectada",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold),
                ),
                child: Text(
                  "EF: ${stats.avgEaseFactor}",
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip("⏳ Para Hoy", "${stats.dueToday}", AppColors.orange),
              const SizedBox(width: 10),
              _buildStatChip("🌱 Aprendiendo", "${stats.learning}", AppColors.blue),
              const SizedBox(width: 10),
              _buildStatChip("👑 Dominadas", "${stats.mastered}", AppColors.primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCardReview(SrsState state, SrsNotifier notifier) {
    final card = state.currentCard!;
    final ex = card.exercise;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purple),
                ),
                child: Text(
                  "REPASO ${state.currentIndex + 1} DE ${state.dueCards.length}",
                  style: const TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                "Reps: ${card.repetitions} | Interv: ${card.intervalDays}d",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ex?.title ?? (ex is MultipleChoiceExercise ? ex.question : "Pregunta de repaso"),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
          ),
          if (ex?.codeSnippet != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.codeBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ex!.codeSnippet!,
                style: const TextStyle(fontFamily: 'monospace', color: AppColors.codeText, fontSize: 12.5),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (!state.isFlipped)
            ElevatedButton(
              onPressed: () => notifier.flipCard(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("MOSTRAR RESPUESTA TÉCNICA", style: TextStyle(fontWeight: FontWeight.w900)),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("💡 EXPLICACIÓN TÉCNICA", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(
                    ex?.explanation ?? "Concepto técnico clave para entrevistas.",
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "¿Qué tan fácil fue recordar este concepto?",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.rateCard(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Column(
                      children: [
                        Text("DIFÍCIL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        Text("1 día", style: TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.rateCard(3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: const Color(0xFF13141B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Column(
                      children: [
                        Text("BUENO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        Text("~6 días", style: TextStyle(fontSize: 10, color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.rateCard(5),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Column(
                      children: [
                        Text("FÁCIL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        Text("+16 días", style: TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedSessionView(SrsState state, SrsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 70),
          const SizedBox(height: 14),
          const Text(
            "¡Repaso Diario SM-2 Completado!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "Has consolidado ${state.reviewedCount} tarjetas en tu memoria a largo plazo.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => notifier.loadSrsData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("ACTUALIZAR ESTADO", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueueView(SrsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, color: AppColors.gold, size: 60),
          const SizedBox(height: 14),
          const Text(
            "¡Estás al día!",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            "No tienes tarjetas pendientes de repaso para hoy según tu curva de olvido.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => notifier.loadSrsData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("COMPROBAR DE NUEVO", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
