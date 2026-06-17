import '../models/card_item.dart';

enum AnswerState { unanswered, correct, wrong }

class SessionAnswer {
  final String cardId;
  final String chosen;
  final String correct;
  final AnswerState state;

  const SessionAnswer({
    required this.cardId,
    required this.chosen,
    required this.correct,
    required this.state,
  });

  bool get isCorrect => state == AnswerState.correct;
}

class SessionService {
  List<CardItem> _cards = [];
  int _currentIndex = 0;
  final List<SessionAnswer> _answers = [];
  bool _isActive = false;
  String _clusterId = '';

  // ── Session lifecycle ─────────────────────────────────────────────────────

  void startSession({
    required List<CardItem> cards,
    required String clusterId,
  }) {
    _cards = cards;
    _currentIndex = 0;
    _answers.clear();
    _isActive = true;
    _clusterId = clusterId;
  }

  void endSession() {
    _isActive = false;
  }

  // ── Current card ──────────────────────────────────────────────────────────

  CardItem? get currentCard =>
      (_isActive && _currentIndex < _cards.length) ? _cards[_currentIndex] : null;

  int get currentIndex => _currentIndex;
  int get totalCards => _cards.length;
  bool get isActive => _isActive;
  bool get isComplete => _currentIndex >= _cards.length;
  String get clusterId => _clusterId;
  List<SessionAnswer> get answers => List.unmodifiable(_answers);

  double get progressFraction =>
      _cards.isEmpty ? 0.0 : _currentIndex / _cards.length;

  // ── Answer submission ─────────────────────────────────────────────────────

  AnswerState submitAnswer(String chosen) {
    final card = currentCard;
    if (card == null) return AnswerState.unanswered;

    final isCorrect = chosen == card.correct;
    final answer = SessionAnswer(
      cardId: card.id,
      chosen: chosen,
      correct: card.correct,
      state: isCorrect ? AnswerState.correct : AnswerState.wrong,
    );
    _answers.add(answer);
    return answer.state;
  }

  void advance() {
    if (_currentIndex < _cards.length) {
      _currentIndex++;
    }
    if (isComplete) endSession();
  }

  // ── Summary stats ─────────────────────────────────────────────────────────

  int get correctCount => _answers.where((a) => a.isCorrect).length;
  int get wrongCount => _answers.where((a) => !a.isCorrect).length;
  double get scorePercent =>
      _answers.isEmpty ? 0.0 : correctCount / _answers.length;

  List<SessionAnswer> get wrongAnswers =>
      _answers.where((a) => !a.isCorrect).toList();
}
