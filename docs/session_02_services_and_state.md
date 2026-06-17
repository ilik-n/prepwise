# Session 02 — Services and State Management

## Goal
Wire up Hive persistence, load card data from JSON, build the three service
classes, and set up Provider. After this session: the app boots, Hive is
initialized, JSON data is loaded into memory, and all providers are available
in the widget tree.

---

## Step 1 — Initialize Hive in main.dart

Replace `lib/main.dart` entirely:

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/card_progress.dart';
import 'models/app_state.dart';
import 'services/data_service.dart';
import 'services/progress_service.dart';
import 'services/session_service.dart';
import 'providers/data_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/session_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(CardProgressAdapter());
  Hive.registerAdapter(AppStateAdapter());
  await Hive.openBox<CardProgress>('cardProgress');
  await Hive.openBox<AppState>('appState');

  // Data service — loads JSON synchronously after asset load
  final dataService = DataService();
  await dataService.load();

  final progressService = ProgressService(dataService: dataService);
  final sessionService = SessionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>.value(value: dataService),
        ChangeNotifierProvider(create: (_) => DataProvider(dataService)),
        ChangeNotifierProvider(create: (_) => ProgressProvider(progressService)),
        ChangeNotifierProvider(create: (_) => SessionProvider(sessionService)),
      ],
      child: const PrepWiseApp(),
    ),
  );
}

class PrepWiseApp extends StatelessWidget {
  const PrepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A7CA5)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

---

## Step 2 — DataService

Create `lib/services/data_service.dart`.

Responsibilities:
- Load `assets/data/prepositions.json` from the bundle.
- Parse it into typed Dart objects.
- Provide fast lookup by cluster ID, card ID, and rule ID.

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/cluster.dart';
import '../models/card_item.dart';
import '../models/rule.dart';

class DataService {
  late final Map<String, Rule> _rules;
  late final List<Cluster> _clusters;
  late final Map<String, CardItem> _cardById;
  late final Map<String, Cluster> _clusterById;

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/prepositions.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    // Parse rules
    final rulesJson = json['rules'] as Map<String, dynamic>;
    _rules = rulesJson.map(
      (key, value) => MapEntry(key, Rule.fromJson(value as Map<String, dynamic>)),
    );

    // Parse all cards into a flat map first
    _cardById = {};
    for (final clusterJson in (json['clusters'] as List)) {
      final clusterMap = clusterJson as Map<String, dynamic>;
      for (final cardJson in (clusterMap['cards'] as List)) {
        final card = CardItem.fromJson(cardJson as Map<String, dynamic>);
        _cardById[card.id] = card;
      }
    }

    // Parse clusters, injecting their cards
    _clusters = [];
    _clusterById = {};
    for (final clusterJson in (json['clusters'] as List)) {
      final clusterMap = clusterJson as Map<String, dynamic>;
      final clusterId = clusterMap['id'] as String;
      final clusterCards = _cardById.values
          .where((c) => c.clusterId == clusterId)
          .toList();
      final cluster = Cluster.fromJson(clusterMap, clusterCards);
      _clusters.add(cluster);
      _clusterById[cluster.id] = cluster;
    }
  }

  List<Cluster> get clusters => _clusters;

  Cluster? clusterById(String id) => _clusterById[id];

  CardItem? cardById(String id) => _cardById[id];

  Rule? ruleById(String id) => _rules[id];

  List<CardItem> get allCards => _cardById.values.toList();

  /// All famous-tagged cards across all clusters.
  List<CardItem> get famousCards =>
      _cardById.values.where((c) => c.isFamous).toList();

  /// All irregular/collocation-tagged cards across all clusters.
  List<CardItem> get irregularCards =>
      _cardById.values.where((c) => c.isIrregular).toList();
}
```

---

## Step 3 — ProgressService

Create `lib/services/progress_service.dart`.

Responsibilities:
- Read/write `CardProgress` objects from/to Hive.
- Provide mastery statistics per cluster and overall.
- Draw a session card list from a given cluster (or all clusters for "mix").

```dart
import 'package:hive/hive.dart';
import '../models/card_progress.dart';
import '../models/card_item.dart';
import '../models/cluster.dart';
import 'data_service.dart';

const int kMasteryThreshold = 3;   // correct streak needed
const int kSessionSize = 15;       // cards per session
const double kReviewRatio = 0.25;  // 25% of session = mastered card review

class ProgressService {
  final DataService dataService;
  late final Box<CardProgress> _box;

  ProgressService({required this.dataService}) {
    _box = Hive.box<CardProgress>('cardProgress');
  }

  // ── Progress retrieval ────────────────────────────────────────────────────

  CardProgress progressFor(String cardId) {
    return _box.get(cardId) ??
        CardProgress(cardId: cardId);
  }

  void saveProgress(CardProgress progress) {
    _box.put(progress.cardId, progress);
  }

  /// Returns 0.0–1.0 representing mastery ratio for a cluster.
  double clusterMastery(Cluster cluster) {
    if (cluster.cards.isEmpty) return 0.0;
    final mastered = cluster.cards
        .where((c) => progressFor(c.id).mastered)
        .length;
    return mastered / cluster.cards.length;
  }

  int clusterMasteredCount(Cluster cluster) =>
      cluster.cards.where((c) => progressFor(c.id).mastered).length;

  int get totalMastered =>
      dataService.allCards.where((c) => progressFor(c.id).mastered).length;

  int get totalCards => dataService.allCards.length;

  /// Mastery 0.0–1.0 across all cards.
  double get overallMastery =>
      totalCards == 0 ? 0.0 : totalMastered / totalCards;

  // ── Session card drawing ─────────────────────────────────────────────────

  /// Draws [kSessionSize] cards from [pool], weighted toward unmastered/low-streak.
  /// [kReviewRatio] of slots are filled with mastered cards for review.
  List<CardItem> drawSession(List<CardItem> pool) {
    if (pool.isEmpty) return [];

    final mastered = pool.where((c) => progressFor(c.id).mastered).toList();
    final learning = pool.where((c) => !progressFor(c.id).mastered).toList();

    // Sort learning cards: most struggled first (highest attempts, lowest streak)
    learning.sort((a, b) {
      final pa = progressFor(a.id);
      final pb = progressFor(b.id);
      // Unseen cards (0 attempts) have middle priority
      if (pa.attemptsTotal == 0 && pb.attemptsTotal == 0) return 0;
      if (pa.attemptsTotal == 0) return 0;
      if (pb.attemptsTotal == 0) return -1;
      return pa.streak.compareTo(pb.streak); // lower streak = higher priority
    });

    final reviewSlots = (kSessionSize * kReviewRatio).round();
    final learningSlots = kSessionSize - reviewSlots;

    final sessionCards = <CardItem>[];

    // Fill learning slots
    final learningPick = learning.take(learningSlots * 2).toList()..shuffle();
    sessionCards.addAll(learningPick.take(learningSlots));

    // Fill review slots from mastered (if any)
    if (mastered.isNotEmpty) {
      final reviewPick = List<CardItem>.from(mastered)..shuffle();
      sessionCards.addAll(reviewPick.take(reviewSlots));
    } else {
      // No mastered cards yet — fill extra slots from learning
      final extra = learning.skip(learningSlots).toList()..shuffle();
      sessionCards.addAll(extra.take(reviewSlots));
    }

    sessionCards.shuffle();
    return sessionCards.take(kSessionSize).toList();
  }

  /// Pool for a specific cluster.
  List<CardItem> poolForCluster(Cluster cluster) => cluster.cards;

  /// Pool for "Mix it up" — all non-mastered cards across all clusters.
  List<CardItem> get mixPool => dataService.allCards
      .where((c) => !progressFor(c.id).mastered)
      .toList();

  /// Pool for "Famous Lines" mode.
  List<CardItem> get famousPool => dataService.famousCards;

  // ── Progress recording ───────────────────────────────────────────────────

  void recordCorrect(String cardId) {
    final p = progressFor(cardId);
    p.recordCorrect();
    saveProgress(p);
  }

  void recordWrong(String cardId) {
    final p = progressFor(cardId);
    p.recordWrong();
    saveProgress(p);
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  Future<void> resetAll() async {
    await _box.clear();
  }

  Future<void> resetCluster(Cluster cluster) async {
    for (final card in cluster.cards) {
      await _box.delete(card.id);
    }
  }
}
```

---

## Step 4 — SessionService

Create `lib/services/session_service.dart`.

Responsibilities:
- Hold the state of one active practice session in memory.
- Track current card index, answers given, and whether the session is complete.

```dart
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

  /// Submit an answer for the current card. Returns the AnswerState.
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

  /// Advance to the next card after showing feedback.
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
```

---

## Step 5 — Providers

### lib/providers/data_provider.dart

```dart
import 'package:flutter/foundation.dart';
import '../services/data_service.dart';
import '../models/cluster.dart';
import '../models/card_item.dart';
import '../models/rule.dart';

class DataProvider extends ChangeNotifier {
  final DataService _service;

  DataProvider(this._service);

  List<Cluster> get clusters => _service.clusters;
  List<CardItem> get famousCards => _service.famousCards;

  Cluster? cluster(String id) => _service.clusterById(id);
  CardItem? card(String id) => _service.cardById(id);
  Rule? rule(String id) => _service.ruleById(id);
}
```

### lib/providers/progress_provider.dart

```dart
import 'package:flutter/foundation.dart';
import '../services/progress_service.dart';
import '../models/card_item.dart';
import '../models/card_progress.dart';
import '../models/cluster.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _service;

  ProgressProvider(this._service);

  ProgressService get service => _service;

  CardProgress progressFor(String cardId) => _service.progressFor(cardId);

  double clusterMastery(Cluster cluster) => _service.clusterMastery(cluster);

  int clusterMasteredCount(Cluster cluster) =>
      _service.clusterMasteredCount(cluster);

  int get totalMastered => _service.totalMastered;
  int get totalCards => _service.totalCards;
  double get overallMastery => _service.overallMastery;

  void recordCorrect(String cardId) {
    _service.recordCorrect(cardId);
    notifyListeners();
  }

  void recordWrong(String cardId) {
    _service.recordWrong(cardId);
    notifyListeners();
  }

  List<CardItem> drawSession(List<CardItem> pool) =>
      _service.drawSession(pool);

  List<CardItem> poolForCluster(Cluster cluster) =>
      _service.poolForCluster(cluster);

  List<CardItem> get mixPool => _service.mixPool;
  List<CardItem> get famousPool => _service.famousPool;

  Future<void> resetAll() async {
    await _service.resetAll();
    notifyListeners();
  }

  Future<void> resetCluster(Cluster cluster) async {
    await _service.resetCluster(cluster);
    notifyListeners();
  }
}
```

### lib/providers/session_provider.dart

```dart
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
```

---

## Step 6 — Update main.dart AppState Box

In `main.dart`, ensure the `appState` box is opened and an initial `AppState`
is stored if it doesn't already exist:

```dart
// After opening boxes, before runApp:
final appStateBox = Hive.box<AppState>('appState');
if (appStateBox.isEmpty) {
  appStateBox.add(AppState());
}
```

---

## Verification

In `HomeScreen` (temporary — will be replaced in Session 03), add this debug output:

```dart
// Inside build(), after obtaining providers:
final data = context.read<DataProvider>();
print('Clusters loaded: ${data.clusters.length}');
print('Total cards: ${data.clusters.fold(0, (sum, c) => sum + c.cards.length)}');
```

Run `flutter run` and confirm in the console:
- `Clusters loaded: 7`
- `Total cards:` shows a number close to 310 (or whatever the JSON contains)
- No Hive errors in the log
- `flutter analyze` passes with no errors

Commit on branch `feature/services` before starting Session 03.
