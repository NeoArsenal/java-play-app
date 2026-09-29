enum ExerciseType {
  flashcard,
  multipleChoice,
  fillBlank,
  tokenReorder,
  spotTheBug,
}

abstract class Exercise {
  final String id;
  final ExerciseType type;
  final String? codeSnippet;
  final String explanation;

  const Exercise({
    required this.id,
    required this.type,
    this.codeSnippet,
    required this.explanation,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    switch (typeStr) {
      case 'FLASHCARD':
        return FlashcardExercise.fromJson(json);
      case 'MULTIPLE_CHOICE':
        return MultipleChoiceExercise.fromJson(json);
      case 'FILL_BLANK':
        return FillBlankExercise.fromJson(json);
      case 'TOKEN_REORDER':
        return TokenReorderExercise.fromJson(json);
      case 'SPOT_THE_BUG':
        return SpotTheBugExercise.fromJson(json);
      default:
        throw UnimplementedError('Tipo de ejercicio no soportado: $typeStr');
    }
  }
}

class FlashcardExercise extends Exercise {
  final String title;

  const FlashcardExercise({
    required super.id,
    required this.title,
    super.codeSnippet,
    required super.explanation,
  }) : super(type: ExerciseType.flashcard);

  factory FlashcardExercise.fromJson(Map<String, dynamic> json) {
    return FlashcardExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      codeSnippet: json['codeSnippet'] as String?,
      explanation: json['explanation'] as String,
    );
  }
}

class MultipleChoiceExercise extends Exercise {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const MultipleChoiceExercise({
    required super.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    super.codeSnippet,
    required super.explanation,
  }) : super(type: ExerciseType.multipleChoice);

  factory MultipleChoiceExercise.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceExercise(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      codeSnippet: json['codeSnippet'] as String?,
      explanation: json['explanation'] as String,
    );
  }
}

class FillBlankExercise extends Exercise {
  final String question;
  final String codeTemplate;
  final List<String> correctAnswers;
  final List<String> options;

  const FillBlankExercise({
    required super.id,
    required this.question,
    required this.codeTemplate,
    required this.correctAnswers,
    required this.options,
    super.codeSnippet,
    required super.explanation,
  }) : super(type: ExerciseType.fillBlank);

  factory FillBlankExercise.fromJson(Map<String, dynamic> json) {
    return FillBlankExercise(
      id: json['id'] as String,
      question: json['question'] as String,
      codeTemplate: json['codeTemplate'] as String,
      correctAnswers: List<String>.from(json['correctAnswers'] as List),
      options: List<String>.from(json['options'] as List),
      codeSnippet: json['codeSnippet'] as String?,
      explanation: json['explanation'] as String,
    );
  }
}

class TokenReorderExercise extends Exercise {
  final String question;
  final List<String> tokens;
  final List<String> correctOrder;

  const TokenReorderExercise({
    required super.id,
    required this.question,
    required this.tokens,
    required this.correctOrder,
    super.codeSnippet,
    required super.explanation,
  }) : super(type: ExerciseType.tokenReorder);

  factory TokenReorderExercise.fromJson(Map<String, dynamic> json) {
    return TokenReorderExercise(
      id: json['id'] as String,
      question: json['question'] as String,
      tokens: List<String>.from(json['tokens'] as List),
      correctOrder: List<String>.from(json['correctOrder'] as List),
      codeSnippet: json['codeSnippet'] as String?,
      explanation: json['explanation'] as String,
    );
  }
}

class SpotTheBugExercise extends Exercise {
  final String question;
  final List<String> codeLines;
  final int buggyLineIndex;

  const SpotTheBugExercise({
    required super.id,
    required this.question,
    required this.codeLines,
    required this.buggyLineIndex,
    super.codeSnippet,
    required super.explanation,
  }) : super(type: ExerciseType.spotTheBug);

  factory SpotTheBugExercise.fromJson(Map<String, dynamic> json) {
    return SpotTheBugExercise(
      id: json['id'] as String,
      question: json['question'] as String,
      codeLines: List<String>.from(json['codeLines'] as List),
      buggyLineIndex: json['buggyLineIndex'] as int,
      codeSnippet: json['codeSnippet'] as String?,
      explanation: json['explanation'] as String,
    );
  }
}
