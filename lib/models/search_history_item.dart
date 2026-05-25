class SearchHistoryItem {
  final String playerTag;
  final String playerName;
  final DateTime searchedAt;

  SearchHistoryItem({
    required this.playerTag,
    required this.playerName,
    required this.searchedAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'playerTag': playerTag,
      'playerName': playerName,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      playerTag: json['playerTag'] as String,
      playerName: json['playerName'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
    );
  }
}
