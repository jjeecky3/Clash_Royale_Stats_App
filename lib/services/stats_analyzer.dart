import '../models/player_data.dart';
import '../models/stats.dart';
import '../models/card.dart';
import '../models/battle_history_item.dart';
import '../utils/card_level_converter.dart';

class StatsAnalyzer {
  Stats analyzeStats(PlayerData playerData) {
    // Basic info
    final name = playerData.name;
    final tag = playerData.tag;
    final trophies = playerData.trophies;
    final bestTrophies = playerData.bestTrophies;
    final kingLevel = playerData.expLevel;
    final wins = playerData.wins;
    final losses = playerData.losses;
    final threeCrownWins = playerData.threeCrownWins;

    // Calculate win rate
    final totalBattles = wins + losses;
    final winRate =
        totalBattles > 0 ? (wins / totalBattles * 100).roundToDouble() : 0.0;

    // Card analysis - convert to display levels
    final cards = playerData.cards;
    double avgCardLevel = 0;
    int totalCards = 0;
    int maxCardLevel = 0;

    if (cards.isNotEmpty) {
      final displayLevels = cards.map((card) {
        final starLevel = card['level'] ?? 1;
        final rarity = card['rarity'] ?? 'common';
        return CardLevelConverter.convertCardLevel(starLevel, rarity);
      }).toList();

      avgCardLevel = displayLevels.reduce((a, b) => a + b) / displayLevels.length;
      totalCards = cards.length;
      maxCardLevel = displayLevels.reduce((a, b) => a > b ? a : b);

      // Round to 1 decimal place
      avgCardLevel = (avgCardLevel * 10).round() / 10;
    }

    // Battle log analysis
    final battleLog = playerData.battleLog;
    int recentBattles = 0;
    int recentWins = 0;
    int recentLosses = 0;
    double recentWinRate = 0;

    if (battleLog.isNotEmpty) {
      final recentBattlesList = battleLog.take(10).toList();
      recentBattles = recentBattlesList.length;

      recentWins = recentBattlesList.where((battle) {
        final team = battle['team'] as List<dynamic>?;
        final opponent = battle['opponent'] as List<dynamic>?;

        if (team == null || opponent == null || team.isEmpty || opponent.isEmpty) {
          return false;
        }

        final teamCrowns = team[0]['crowns'] ?? 0;
        final opponentCrowns = opponent[0]['crowns'] ?? 0;

        return teamCrowns > opponentCrowns;
      }).length;

      recentLosses = recentBattles - recentWins;
      recentWinRate = recentBattles > 0
          ? ((recentWins / recentBattles * 100) * 10).round() / 10
          : 0.0;
    }

    // Current deck - process to add display levels and calculate avg elixir
    double totalElixir = 0;
    int cardsWithElixir = 0;

    final currentDeck = <CardModel>[];
    for (var i = 0; i < playerData.currentDeck.length; i++) {
      final card = playerData.currentDeck[i];
      final starLevel = card['level'] ?? 1;
      final rarity = card['rarity'] ?? 'common';
      final displayLevel = CardLevelConverter.convertCardLevel(starLevel, rarity);
      
      // Calculate elixir
      if (card['elixirCost'] != null) {
        totalElixir += card['elixirCost'];
        cardsWithElixir++;
      }

      // Pass deck position (i) to enable position-based EVO/HERO detection
      currentDeck.add(CardModel.fromJson(card, displayLevel, deckPosition: i));
    }

    final avgElixirCost = cardsWithElixir > 0 
        ? (totalElixir / cardsWithElixir * 10).round() / 10 
        : 0.0;

    // Extract icon URLs
    String? badgeIcon;
    if (playerData.badges != null && playerData.badges!.isNotEmpty) {
      final firstBadge = playerData.badges![0];
      if (firstBadge['iconUrls'] != null) {
        badgeIcon = firstBadge['iconUrls']['large'];
      }
    }

    String? avatarIcon;
    if (playerData.currentFavouriteCard != null) {
      final iconUrls = playerData.currentFavouriteCard!['iconUrls'];
      if (iconUrls != null) {
        avatarIcon = iconUrls['medium'];
      }
    }
    
    // Process favorite card
    // Note: currentFavouriteCard doesn't include level, only maxLevel and rarity
    CardModel? favoriteCard;
    if (playerData.currentFavouriteCard != null) {
      final card = playerData.currentFavouriteCard!;
      // Use 0 as displayLevel since we don't have the actual level
      favoriteCard = CardModel.fromJson(card, 0);
    }

    // Parse battle history
    final battleHistory = playerData.battleLog.map((battle) {
      return BattleHistoryItem.fromJson(battle, tag);
    }).toList();

    // Calculate current win/loss streak
    int currentStreak = 0;
    String streakType = 'none';
    
    if (battleHistory.isNotEmpty) {
      bool? lastResult;
      for (var battle in battleHistory) {
        bool isWin = battle.isVictory;
        
        if (lastResult == null) {
          lastResult = isWin;
          currentStreak = 1;
          streakType = isWin ? 'win' : 'loss';
        } else if (lastResult == isWin) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    // Calculate three crown rate
    double threeCrownRate = 0.0;
    if (wins > 0) {
      threeCrownRate = (threeCrownWins / wins * 100 * 10).round() / 10;
    }

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
      starPoints: playerData.starPoints,
      totalExpPoints: playerData.totalExpPoints,
      avgElixirCost: avgElixirCost,
      battleHistory: battleHistory,
      currentStreak: currentStreak,
      streakType: streakType,
      threeCrownRate: threeCrownRate,
    );
  }
}
