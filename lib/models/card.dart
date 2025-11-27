class CardModel {
  final String name;
  final int level; // Star level from API
  final int displayLevel; // Display level after conversion
  final String rarity;
  final int? evolutionLevel;
  final bool hasEvolution;
  final Map<String, String>? iconUrls;

  CardModel({
    required this.name,
    required this.level,
    required this.displayLevel,
    required this.rarity,
    this.evolutionLevel,
    required this.hasEvolution,
    this.iconUrls,
  });

  factory CardModel.fromJson(Map<String, dynamic> json, int displayLevel) {
    return CardModel(
      name: json['name'] ?? '',
      level: json['level'] ?? 1,
      displayLevel: displayLevel,
      rarity: json['rarity'] ?? 'common',
      evolutionLevel: json['evolutionLevel'],
      hasEvolution: (json['evolutionLevel'] ?? 0) > 0,
      iconUrls: json['iconUrls'] != null
          ? Map<String, String>.from(json['iconUrls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'displayLevel': displayLevel,
      'rarity': rarity,
      'evolutionLevel': evolutionLevel,
      'hasEvolution': hasEvolution,
      'iconUrls': iconUrls,
    };
  }
}
