import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_history_item.dart';

class SearchHistoryService {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;

  /// Get all search history items, ordered by most recent first
  Future<List<SearchHistoryItem>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);

    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map((item) => SearchHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Add a new search to history
  /// If the player tag already exists, update it with new timestamp
  Future<void> addSearch(String playerTag, String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    List<SearchHistoryItem> history = await getSearchHistory();

    // Remove existing entry for this player tag if it exists
    history.removeWhere((item) => item.playerTag == playerTag);

    // Add new entry at the beginning
    history.insert(
      0,
      SearchHistoryItem(
        playerTag: playerTag,
        playerName: playerName,
        searchedAt: DateTime.now(),
      ),
    );

    // Keep only the most recent items
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }

    // Save to SharedPreferences
    final String historyJson = json.encode(
      history.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_historyKey, historyJson);
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
