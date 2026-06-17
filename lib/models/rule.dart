class Rule {
  final String id;
  final String short;
  final String example;

  const Rule({required this.id, required this.short, required this.example});

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        id: json['id'] as String,
        short: json['short'] as String,
        example: json['example'] as String,
      );
}
