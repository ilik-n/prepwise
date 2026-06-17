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
