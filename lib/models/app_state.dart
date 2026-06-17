import 'package:hive/hive.dart';

part 'app_state.g.dart';

@HiveType(typeId: 1)
class AppState extends HiveObject {
  @HiveField(0)
  String lastClusterId;

  @HiveField(1)
  int totalSessionsCompleted;

  AppState({
    this.lastClusterId = '',
    this.totalSessionsCompleted = 0,
  });
}
