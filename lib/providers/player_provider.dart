import 'package:flutter/foundation.dart';
import '../models/player_data.dart';
import '../models/stats.dart';
import '../models/roast.dart';
import '../services/api_service.dart';
import '../services/stats_analyzer.dart';
import '../services/roast_generator.dart';
import '../services/search_history_service.dart';

enum PlayerState {
  initial,
  loading,
  loaded,
  error,
}

class PlayerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StatsAnalyzer _statsAnalyzer = StatsAnalyzer();
  final RoastGenerator _roastGenerator = RoastGenerator();
  final SearchHistoryService _historyService = SearchHistoryService();

  PlayerState _state = PlayerState.initial;
  PlayerData? _playerData;
  Stats? _stats;
  List<Roast> _roasts = [];
  String _errorMessage = '';

  PlayerState get state => _state;
  PlayerData? get playerData => _playerData;
  Stats? get stats => _stats;
  List<Roast> get roasts => _roasts;
  String get errorMessage => _errorMessage;

  Future<void> fetchPlayerStats(String playerTag) async {
    _state = PlayerState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Fetch player data from API
      _playerData = await _apiService.fetchPlayerData(playerTag);

      // Analyze stats
      _stats = _statsAnalyzer.analyzeStats(_playerData!);

      // Generate roasts
      _roasts = _roastGenerator.generateRoasts(_stats!);

      // Save to search history
      await _historyService.addSearch(_stats!.tag, _stats!.name);

      _state = PlayerState.loaded;
      notifyListeners();
    } on ApiException catch (e) {
      _state = PlayerState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = PlayerState.error;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
    }
  }

  void reset() {
    _state = PlayerState.initial;
    _playerData = null;
    _stats = null;
    _roasts = [];
    _errorMessage = '';
    notifyListeners();
  }
}
