import 'card.dart';
import '../utils/card_level_converter.dart';
import 'package:intl/intl.dart';

class BattleHistoryItem {
  final String type;
  final DateTime battleTime;
  final String arenaName;
  final String gameModeName;
  final int teamCrowns;
  final int opponentCrowns;
  final int trophyChange; // For the player
  final String opponentName;
  final String opponentTag;
  final String? opponentClanName;
  final int opponentKingLevel;
  final int opponentTrophies;
  final String? opponentIcon;
  final List<CardModel> teamDeck;
  final List<CardModel> opponentDeck;
  final bool isVictory;
  final bool isDraw;
  final double playerElixirLeaked;
  final double opponentElixirLeaked;
  final int playerKingTowerHp;
  final int opponentKingTowerHp;
  final List<int> playerPrincessTowersHp;
  final List<int> opponentPrincessTowersHp;

  BattleHistoryItem({
    required this.type,
    required this.battleTime,
    required this.arenaName,
    required this.gameModeName,
    required this.teamCrowns,
    required this.opponentCrowns,
    required this.trophyChange,
    required this.opponentName,
    required this.opponentTag,
    this.opponentClanName,
    required this.opponentKingLevel,
    required this.opponentTrophies,
    this.opponentIcon,
    required this.teamDeck,
    required this.opponentDeck,
    required this.isVictory,
    required this.isDraw,
    required this.playerElixirLeaked,
    required this.opponentElixirLeaked,
    required this.playerKingTowerHp,
    required this.opponentKingTowerHp,
    required this.playerPrincessTowersHp,
    required this.opponentPrincessTowersHp,
  });

  // Helper getters
  String get result => isVictory ? 'victory' : isDraw ? 'draw' : 'defeat';
  String get gameMode => gameModeName;
  String get arena => arenaName;
  String get formattedTime => DateFormat('MMM d, h:mm a').format(battleTime);
  
  // Player getters (for consistency with detail screen)
  int get playerCrowns => teamCrowns;
  List<CardModel> get playerDeck => teamDeck;

  factory BattleHistoryItem.fromJson(Map<String, dynamic> json, String playerTag) {
    // Determine which side is the player (team) and which is opponent
    final teamList = json['team'] as List<dynamic>;
    final opponentList = json['opponent'] as List<dynamic>;
    
    final teamData = teamList.isNotEmpty ? teamList[0] : {};
    final opponentData = opponentList.isNotEmpty ? opponentList[0] : {};

    final teamCrowns = teamData['crowns'] ?? 0;
    final opponentCrowns = opponentData['crowns'] ?? 0;
    
    // Parse decks
    List<CardModel> parseDeck(List<dynamic>? cards) {
      if (cards == null) return [];
      final deck = <CardModel>[];
      for (var i = 0; i < cards.length; i++) {
        final card = cards[i];
        final starLevel = card['level'] ?? 1;
        final rarity = card['rarity'] ?? 'common';
        final displayLevel = CardLevelConverter.convertCardLevel(starLevel, rarity);
        // Pass deck position for position-based EVO/HERO detection
        deck.add(CardModel.fromJson(card, displayLevel, deckPosition: i));
      }
      return deck;
    }

    final teamDeck = parseDeck(teamData['cards']);
    final opponentDeck = parseDeck(opponentData['cards']);

    // Determine result
    bool isVictory = teamCrowns > opponentCrowns;
    bool isDraw = teamCrowns == opponentCrowns;
    
    // Parse time
    DateTime battleTime;
    try {
      final timeStr = json['battleTime'] as String;
      if (timeStr.length >= 15) {
        final formatted = '${timeStr.substring(0, 4)}-${timeStr.substring(4, 6)}-${timeStr.substring(6, 8)}T${timeStr.substring(9, 11)}:${timeStr.substring(11, 13)}:${timeStr.substring(13)}';
        battleTime = DateTime.parse(formatted);
      } else {
        battleTime = DateTime.now();
      }
    } catch (e) {
      battleTime = DateTime.now();
    }

    // Parse tower HP
    List<int> parsePrincessTowers(List<dynamic>? towers) {
      if (towers == null) return [];
      return towers.map((hp) => hp as int).toList();
    }

    return BattleHistoryItem(
      type: json['type'] ?? 'Unknown',
      battleTime: battleTime,
      arenaName: json['arena']?['name'] ?? 'Unknown Arena',
      gameModeName: json['gameMode']?['name'] ?? 'Ladder',
      teamCrowns: teamCrowns,
      opponentCrowns: opponentCrowns,
      trophyChange: teamData['trophyChange'] ?? 0,
      opponentName: opponentData['name'] ?? 'Unknown',
      opponentTag: opponentData['tag'] ?? '',
      opponentClanName: opponentData['clan']?['name'],
      opponentKingLevel: opponentData['kingTowerHitPoints'] != null ? 
          ((opponentData['kingTowerHitPoints'] as int) / 400).round() : 1,
      opponentTrophies: opponentData['startingTrophies'] ?? 0,
      opponentIcon: opponentData['iconUrls']?['medium'],
      teamDeck: teamDeck,
      opponentDeck: opponentDeck,
      isVictory: isVictory,
      isDraw: isDraw,
      playerElixirLeaked: (teamData['elixirLeaked'] ?? 0.0).toDouble(),
      opponentElixirLeaked: (opponentData['elixirLeaked'] ?? 0.0).toDouble(),
      playerKingTowerHp: teamData['kingTowerHitPoints'] ?? 0,
      opponentKingTowerHp: opponentData['kingTowerHitPoints'] ?? 0,
      playerPrincessTowersHp: parsePrincessTowers(teamData['princessTowersHitPoints']),
      opponentPrincessTowersHp: parsePrincessTowers(opponentData['princessTowersHitPoints']),
    );
  }
}
