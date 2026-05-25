class SavedDeck {
  final String id;
  final String name;
  final List<String> cardNames; // Store card names
  final List<bool> isEvolvedFlags; // Store whether each card is evolved
  final List<bool> isHeroFlags; // Store whether each card is a hero
  final DateTime savedAt;

  SavedDeck({
    required this.id,
    required this.name,
    required this.cardNames,
    required this.isEvolvedFlags,
    required this.isHeroFlags,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNames': cardNames,
      'isEvolvedFlags': isEvolvedFlags,
      'isHeroFlags': isHeroFlags,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedDeck.fromJson(Map<String, dynamic> json) {
    return SavedDeck(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cardNames: List<String>.from(json['cardNames'] ?? []),
      isEvolvedFlags: List<bool>.from(json['isEvolvedFlags'] ?? []),
      isHeroFlags: List<bool>.from(json['isHeroFlags'] ?? List.filled(json['cardNames']?.length ?? 0, false)),
      savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
