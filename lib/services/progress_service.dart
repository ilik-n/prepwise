import 'package:hive/hive.dart';
import '../models/card_progress.dart';
import '../models/card_item.dart';
import '../models/cluster.dart';
import 'data_service.dart';

const int kMasteryThreshold = 3;
const int kSessionSize = 15;
const double kReviewRatio = 0.25;

class ProgressService {
  final DataService dataService;
  late final Box<CardProgress> _box;

  ProgressService({required this.dataService}) {
    _box = Hive.box<CardProgress>('cardProgress');
  }

  // ── Progress retrieval ────────────────────────────────────────────────────

  CardProgress progressFor(String cardId) {
    return _box.get(cardId) ?? CardProgress(cardId: cardId);
  }

  void saveProgress(CardProgress progress) {
    _box.put(progress.cardId, progress);
  }

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

  double get overallMastery =>
      totalCards == 0 ? 0.0 : totalMastered / totalCards;

  // ── Session card drawing ─────────────────────────────────────────────────

  List<CardItem> drawSession(List<CardItem> pool) {
    if (pool.isEmpty) return [];

    final mastered = pool.where((c) => progressFor(c.id).mastered).toList();
    final learning = pool.where((c) => !progressFor(c.id).mastered).toList();

    learning.sort((a, b) {
      final pa = progressFor(a.id);
      final pb = progressFor(b.id);
      if (pa.attemptsTotal == 0 && pb.attemptsTotal == 0) return 0;
      if (pa.attemptsTotal == 0) return 0;
      if (pb.attemptsTotal == 0) return -1;
      return pa.streak.compareTo(pb.streak);
    });

    final reviewSlots = (kSessionSize * kReviewRatio).round();
    final learningSlots = kSessionSize - reviewSlots;

    final sessionCards = <CardItem>[];

    final learningPick = learning.take(learningSlots * 2).toList()..shuffle();
    sessionCards.addAll(learningPick.take(learningSlots));

    if (mastered.isNotEmpty) {
      final reviewPick = List<CardItem>.from(mastered)..shuffle();
      sessionCards.addAll(reviewPick.take(reviewSlots));
    } else {
      final extra = learning.skip(learningSlots).toList()..shuffle();
      sessionCards.addAll(extra.take(reviewSlots));
    }

    sessionCards.shuffle();
    return sessionCards.take(kSessionSize).toList();
  }

  List<CardItem> poolForCluster(Cluster cluster) => cluster.cards;

  List<CardItem> get mixPool => dataService.allCards
      .where((c) => !progressFor(c.id).mastered)
      .toList();

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
