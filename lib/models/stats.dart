import 'card.dart';

class Stats {
  final String name;
  final String tag;
  final int trophies;
  final int bestTrophies;
  final int kingLevel;
  final int wins;
  final int losses;
  final int threeCrownWins;
  final int totalBattles;
  final double winRate;
  final double avgCardLevel;
  final int totalCards;
  final int maxCardLevel;
  final int recentBattles;
  final int recentWins;
  final int recentLosses;
  final double recentWinRate;
  final List<CardModel> currentDeck;
  final String? badgeIcon;
  final String? avatarIcon;

  Stats({
    required this.name,
    required this.tag,
    required this.trophies,
    required this.bestTrophies,
    required this.kingLevel,
    required this.wins,
    required this.losses,
    required this.threeCrownWins,
    required this.totalBattles,
    required this.winRate,
    required this.avgCardLevel,
    required this.totalCards,
    required this.maxCardLevel,
    required this.recentBattles,
    required this.recentWins,
    required this.recentLosses,
    required this.recentWinRate,
    required this.currentDeck,
    this.badgeIcon,
    this.avatarIcon,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      name: json['name'] ?? 'Unknown',
      tag: json['tag'] ?? '',
      trophies: json['trophies'] ?? 0,
      bestTrophies: json['best_trophies'] ?? 0,
      kingLevel: json['king_level'] ?? 1,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      threeCrownWins: json['three_crown_wins'] ?? 0,
      totalBattles: json['total_battles'] ?? 0,
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
      avgCardLevel: (json['avg_card_level'] ?? 0.0).toDouble(),
      totalCards: json['total_cards'] ?? 0,
      maxCardLevel: json['max_card_level'] ?? 0,
      recentBattles: json['recent_battles'] ?? 0,
      recentWins: json['recent_wins'] ?? 0,
      recentLosses: json['recent_losses'] ?? 0,
      recentWinRate: (json['recent_win_rate'] ?? 0.0).toDouble(),
      currentDeck: (json['current_deck'] as List<dynamic>?)
              ?.map((card) => CardModel.fromJson(
                  card, card['displayLevel'] ?? card['level'] ?? 1))
              .toList() ??
          [],
      badgeIcon: json['badge_icon'],
      avatarIcon: json['avatar_icon'],
    );
  }
}
