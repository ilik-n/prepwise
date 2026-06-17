import 'package:flutter/foundation.dart';
import '../services/session_service.dart';
import '../models/card_item.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _service;

  SessionProvider(this._service);

  SessionService get session => _service;

  CardItem? get currentCard => _service.currentCard;
  int get currentIndex => _service.currentIndex;
  int get totalCards => _service.totalCards;
  bool get isActive => _service.isActive;
  bool get isComplete => _service.isComplete;
  double get progressFraction => _service.progressFraction;
  int get correctCount => _service.correctCount;
  double get scorePercent => _service.scorePercent;

  void startSession({required List<CardItem> cards, required String clusterId}) {
    _service.startSession(cards: cards, clusterId: clusterId);
    notifyListeners();
  }

  AnswerState submitAnswer(String chosen) {
    final result = _service.submitAnswer(chosen);
    notifyListeners();
    return result;
  }

  void advance() {
    _service.advance();
    notifyListeners();
  }
}
