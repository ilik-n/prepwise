import 'package:hive/hive.dart';

part 'card_progress.g.dart';

@HiveType(typeId: 0)
class CardProgress extends HiveObject {
  @HiveField(0)
  String cardId;

  @HiveField(1)
  int streak;

  @HiveField(2)
  int attemptsTotal;

  @HiveField(3)
  int correctTotal;

  @HiveField(4)
  bool mastered;

  @HiveField(5)
  int lastSeenTimestamp;

  CardProgress({
    required this.cardId,
    this.streak = 0,
    this.attemptsTotal = 0,
    this.correctTotal = 0,
    this.mastered = false,
    this.lastSeenTimestamp = 0,
  });

  void recordCorrect() {
    attemptsTotal++;
    correctTotal++;
    streak++;
    if (streak >= 3) mastered = true;
    lastSeenTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (isInBox) save();
  }

  void recordWrong() {
    attemptsTotal++;
    streak = 0;
    mastered = false;
    lastSeenTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (isInBox) save();
  }
}
