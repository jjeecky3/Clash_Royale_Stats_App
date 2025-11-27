class PlayerData {
  final String name;
  final String tag;
  final int trophies;
  final int bestTrophies;
  final int expLevel;
  final int wins;
  final int losses;
  final int threeCrownWins;
  final List<Map<String, dynamic>> cards;
  final List<Map<String, dynamic>> currentDeck;
  final List<Map<String, dynamic>> battleLog;
  final List<Map<String, dynamic>>? badges;
  final Map<String, dynamic>? currentFavouriteCard;

  PlayerData({
    required this.name,
    required this.tag,
    required this.trophies,
    required this.bestTrophies,
    required this.expLevel,
    required this.wins,
    required this.losses,
    required this.threeCrownWins,
    required this.cards,
    required this.currentDeck,
    required this.battleLog,
    this.badges,
    this.currentFavouriteCard,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      name: json['name'] ?? 'Unknown',
      tag: json['tag'] ?? '',
      trophies: json['trophies'] ?? 0,
      bestTrophies: json['bestTrophies'] ?? 0,
      expLevel: json['expLevel'] ?? 1,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      threeCrownWins: json['threeCrownWins'] ?? 0,
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      currentDeck: (json['currentDeck'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      battleLog: (json['battleLog'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      currentFavouriteCard: json['currentFavouriteCard'] != null
          ? Map<String, dynamic>.from(json['currentFavouriteCard'])
          : null,
    );
  }
}
