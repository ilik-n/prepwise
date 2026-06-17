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

  List<CardItem> get famousCards =>
      _cardById.values.where((c) => c.isFamous).toList();

  List<CardItem> get irregularCards =>
      _cardById.values.where((c) => c.isIrregular).toList();
}
