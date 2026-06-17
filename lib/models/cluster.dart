import 'card_item.dart';

class Cluster {
  final String id;
  final String title;
  final String subtitle;
  final List<String> prepositions;
  final List<String> introRules;
  final String contrastNote;
  final List<CardItem> cards;

  const Cluster({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.prepositions,
    required this.introRules,
    required this.contrastNote,
    required this.cards,
  });

  factory Cluster.fromJson(Map<String, dynamic> json, List<CardItem> clusterCards) =>
      Cluster(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        prepositions: List<String>.from(json['prepositions'] as List),
        introRules: List<String>.from(json['intro_rules'] as List),
        contrastNote: json['contrast_note'] as String? ?? '',
        cards: clusterCards,
      );
}
