import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/srs_repository.dart';
import '../../domain/models/srs_card.dart';
import '../../domain/models/srs_stats.dart';

class SrsState {
  final List<SrsCard> dueCards;
  final int currentIndex;
  final bool isFlipped;
  final SrsStats stats;
  final bool isLoading;
  final bool isSessionCompleted;
  final int reviewedCount;

  const SrsState({
    this.dueCards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.stats = const SrsStats(),
    this.isLoading = false,
    this.isSessionCompleted = false,
    this.reviewedCount = 0,
  });

  SrsCard? get currentCard => (currentIndex < dueCards.length) ? dueCards[currentIndex] : null;

  SrsState copyWith({
    List<SrsCard>? dueCards,
    int? currentIndex,
    bool? isFlipped,
    SrsStats? stats,
    bool? isLoading,
    bool? isSessionCompleted,
    int? reviewedCount,
  }) {
    return SrsState(
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isSessionCompleted: isSessionCompleted ?? this.isSessionCompleted,
      reviewedCount: reviewedCount ?? this.reviewedCount,
    );
  }
}

class SrsNotifier extends StateNotifier<SrsState> {
  final SrsRepository _repository;
  final String userId;

  SrsNotifier(this._repository, {this.userId = 'user_1'}) : super(const SrsState()) {
    loadSrsData();
  }

  Future<void> loadSrsData() async {
    state = state.copyWith(isLoading: true);
    final stats = await _repository.getStats(userId);
    final due = await _repository.getDueCards(userId);
    state = state.copyWith(
      stats: stats,
      dueCards: due,
      currentIndex: 0,
      isFlipped: false,
      isSessionCompleted: due.isEmpty,
      isLoading: false,
    );
  }

  void flipCard() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  Future<void> rateCard(int quality) async {
    final current = state.currentCard;
    if (current == null) return;

    // Submit review to backend (calculates SM-2, updates Supabase & awards +10 XP)
    await _repository.submitReview(
      userId: userId,
      exerciseId: current.exerciseId,
      worldId: current.worldId,
      quality: quality,
    );

    final nextIndex = state.currentIndex + 1;
    final isFinished = nextIndex >= state.dueCards.length;

    state = state.copyWith(
      currentIndex: nextIndex,
      isFlipped: false,
      isSessionCompleted: isFinished,
      reviewedCount: state.reviewedCount + 1,
    );

    if (isFinished) {
      final updatedStats = await _repository.getStats(userId);
      state = state.copyWith(stats: updatedStats);
    }
  }
}

final srsRepositoryProvider = Provider<SrsRepository>((ref) => SrsRepository());

final srsProvider = StateNotifierProvider<SrsNotifier, SrsState>((ref) {
  final repo = ref.watch(srsRepositoryProvider);
  return SrsNotifier(repo);
});
