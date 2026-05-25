class DeckAnalysis {
  final double avgElixirCost;
  final Map<String, int> cardTypeDistribution;
  final List<String> winConditions;
  final List<String> synergies;
  final List<String> weaknesses;
  final int metaRating; // 1-10
  final List<String> recommendations;
  final String deckArchetype;

  DeckAnalysis({
    required this.avgElixirCost,
    required this.cardTypeDistribution,
    required this.winConditions,
    required this.synergies,
    required this.weaknesses,
    required this.metaRating,
    required this.recommendations,
    required this.deckArchetype,
  });

  factory DeckAnalysis.empty() {
    return DeckAnalysis(
      avgElixirCost: 0.0,
      cardTypeDistribution: {},
      winConditions: [],
      synergies: [],
      weaknesses: [],
      metaRating: 0,
      recommendations: [],
      deckArchetype: 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgElixirCost': avgElixirCost,
      'cardTypeDistribution': cardTypeDistribution,
      'winConditions': winConditions,
      'synergies': synergies,
      'weaknesses': weaknesses,
      'metaRating': metaRating,
      'recommendations': recommendations,
      'deckArchetype': deckArchetype,
    };
  }

  factory DeckAnalysis.fromJson(Map<String, dynamic> json) {
    return DeckAnalysis(
      avgElixirCost: (json['avgElixirCost'] ?? 0.0).toDouble(),
      cardTypeDistribution: Map<String, int>.from(json['cardTypeDistribution'] ?? {}),
      winConditions: List<String>.from(json['winConditions'] ?? []),
      synergies: List<String>.from(json['synergies'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      metaRating: json['metaRating'] ?? 0,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      deckArchetype: json['deckArchetype'] ?? 'Unknown',
    );
  }
}
