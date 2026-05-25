import 'card.dart';
import 'battle_history_item.dart';

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
  final CardModel? favoriteCard; // Player's favorite card
  final int starPoints; // Star points earned
  final int totalExpPoints; // Total EXP
  final double avgElixirCost; // Average elixir cost of current deck
  final List<BattleHistoryItem> battleHistory; // Detailed battle history
  final int currentStreak; // Current win/loss streak (positive = wins, negative = losses)
  final String streakType; // 'win' or 'loss'
  final double threeCrownRate; // Percentage of wins that are 3-crown

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
    this.favoriteCard,
    required this.starPoints,
    required this.totalExpPoints,
    required this.avgElixirCost,
    required this.battleHistory,
    required this.currentStreak,
    required this.streakType,
    required this.threeCrownRate,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    final currentDeck = (json['current_deck'] as List<dynamic>?)
            ?.map((card) => CardModel.fromJson(
                card, card['displayLevel'] ?? card['level'] ?? 1))
            .toList() ??
        [];

    // Note: battleHistory is populated by StatsAnalyzer, not directly from basic JSON usually
    // But if we pass it in, we can parse it.
    // For now, we'll initialize it as empty if not present, and StatsAnalyzer will fill it.
    
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
      currentDeck: currentDeck,
      badgeIcon: json['badge_icon'],
      avatarIcon: json['avatar_icon'],
      favoriteCard: json['favorite_card'] != null
          ? CardModel.fromJson(json['favorite_card'],
              json['favorite_card']['level'] ?? 1)
          : null,
      starPoints: json['star_points'] ?? 0,
      totalExpPoints: json['total_exp_points'] ?? 0,
      avgElixirCost: (json['avg_elixir_cost'] ?? 0.0).toDouble(),
      battleHistory: [], // Will be populated by StatsAnalyzer
      currentStreak: json['current_streak'] ?? 0,
      streakType: json['streak_type'] ?? 'none',
      threeCrownRate: (json['three_crown_rate'] ?? 0.0).toDouble(),
    );
  }
  
  // Helper to create a copy with battle history
  Stats copyWith({
    List<BattleHistoryItem>? battleHistory,
    int? currentStreak,
    String? streakType,
    double? threeCrownRate,
  }) {
    return Stats(
      name: name,
      tag: tag,
      trophies: trophies,
      bestTrophies: bestTrophies,
      kingLevel: kingLevel,
      wins: wins,
      losses: losses,
      threeCrownWins: threeCrownWins,
      totalBattles: totalBattles,
      winRate: winRate,
      avgCardLevel: avgCardLevel,
      totalCards: totalCards,
      maxCardLevel: maxCardLevel,
      recentBattles: recentBattles,
      recentWins: recentWins,
      recentLosses: recentLosses,
      recentWinRate: recentWinRate,
      currentDeck: currentDeck,
      badgeIcon: badgeIcon,
      avatarIcon: avatarIcon,
      favoriteCard: favoriteCard,
      starPoints: starPoints,
      totalExpPoints: totalExpPoints,
      avgElixirCost: avgElixirCost,
      battleHistory: battleHistory ?? this.battleHistory,
      currentStreak: currentStreak ?? this.currentStreak,
      streakType: streakType ?? this.streakType,
      threeCrownRate: threeCrownRate ?? this.threeCrownRate,
    );
  }
}
