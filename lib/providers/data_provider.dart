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
