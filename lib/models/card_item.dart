class CardItem {
  final String id;
  final String clusterId;
  final String sentence;
  final String correct;
  final List<String> distractors;
  final String ruleId;
  final List<String> tags;
  final bool isFamous;
  final bool isIrregular;
  final String? source;

  const CardItem({
    required this.id,
    required this.clusterId,
    required this.sentence,
    required this.correct,
    required this.distractors,
    required this.ruleId,
    required this.tags,
    required this.isFamous,
    required this.isIrregular,
    this.source,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
        id: json['id'] as String,
        clusterId: json['cluster_id'] as String,
        sentence: json['sentence'] as String,
        correct: json['correct'] as String,
        distractors: List<String>.from(json['distractors'] as List),
        ruleId: json['rule_id'] as String,
        tags: List<String>.from(json['tags'] as List),
        isFamous: json['is_famous'] as bool,
        isIrregular: json['is_irregular'] as bool,
        source: json['source'] as String?,
      );

  List<String> get options {
    final all = [correct, ...distractors];
    all.shuffle();
    return all;
  }

  int get difficulty {
    if (tags.contains('difficulty_3')) return 3;
    if (tags.contains('difficulty_2')) return 2;
    return 1;
  }
}
