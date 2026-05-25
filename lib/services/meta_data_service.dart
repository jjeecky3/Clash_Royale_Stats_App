class MetaDeck {
  final String name;
  final List<String> cardNames;
  final double winRate;
  final double usageRate;
  final int rank;
  final String archetype;

  MetaDeck({
    required this.name,
    required this.cardNames,
    required this.winRate,
    required this.usageRate,
    required this.rank,
    required this.archetype,
  });
}

class BrokenCard {
  final String cardName;
  final double winRate;
  final double usageRate;
  final String reason;

  BrokenCard({
    required this.cardName,
    required this.winRate,
    required this.usageRate,
    required this.reason,
  });
}

class MetaDataService {
  // Curated meta data based on current game state
  static List<MetaDeck> getPopularDecks() {
    return [
      MetaDeck(
        name: 'Hog Cycle 2.6',
        cardNames: ['Hog Rider', 'Musketeer', 'Ice Spirit', 'Skeletons', 'Ice Golem', 'Cannon', 'Fireball', 'The Log'],
        winRate: 54.2,
        usageRate: 12.5,
        rank: 1,
        archetype: 'Cycle',
      ),
      MetaDeck(
        name: 'Lava Loon',
        cardNames: ['Lava Hound', 'Balloon', 'Mega Minion', 'Tombstone', 'Arrows', 'Fireball', 'Barbarians', 'Skeleton Army'],
        winRate: 53.8,
        usageRate: 8.3,
        rank: 2,
        archetype: 'Beatdown',
      ),
      MetaDeck(
        name: 'Log Bait',
        cardNames: ['Goblin Barrel', 'Princess', 'Knight', 'Rocket', 'Goblin Gang', 'Ice Spirit', 'Inferno Tower', 'The Log'],
        winRate: 52.9,
        usageRate: 10.1,
        rank: 3,
        archetype: 'Control',
      ),
      MetaDeck(
        name: 'Pekka Bridge Spam',
        cardNames: ['P.E.K.K.A', 'Battle Ram', 'Bandit', 'Electro Wizard', 'Magic Archer', 'Poison', 'Zap', 'Royal Ghost'],
        winRate: 52.5,
        usageRate: 7.8,
        rank: 4,
        archetype: 'Bridge Spam',
      ),
      MetaDeck(
        name: 'Golem Beatdown',
        cardNames: ['Golem', 'Night Witch', 'Baby Dragon', 'Lumberjack', 'Mega Minion', 'Tornado', 'Lightning', 'The Log'],
        winRate: 51.8,
        usageRate: 6.5,
        rank: 5,
        archetype: 'Beatdown',
      ),
      MetaDeck(
        name: 'X-Bow Cycle',
        cardNames: ['X-Bow', 'Tesla', 'Archers', 'Ice Spirit', 'Skeletons', 'Knight', 'Fireball', 'The Log'],
        winRate: 51.2,
        usageRate: 5.9,
        rank: 6,
        archetype: 'Siege',
      ),
      MetaDeck(
        name: 'Miner Poison',
        cardNames: ['Miner', 'Poison', 'Valkyrie', 'Bats', 'Spear Goblins', 'Ice Spirit', 'Inferno Tower', 'The Log'],
        winRate: 50.9,
        usageRate: 5.2,
        rank: 7,
        archetype: 'Control',
      ),
      MetaDeck(
        name: 'Royal Giant',
        cardNames: ['Royal Giant', 'Fisherman', 'Hunter', 'Mother Witch', 'Earthquake', 'Fireball', 'The Log', 'Electro Spirit'],
        winRate: 50.5,
        usageRate: 4.8,
        rank: 8,
        archetype: 'Beatdown',
      ),
    ];
  }

  static List<BrokenCard> getBrokenCards() {
    return [
      BrokenCard(
        cardName: 'Electro Giant',
        winRate: 58.3,
        usageRate: 15.2,
        reason: 'Extremely high win rate with reflection damage',
      ),
      BrokenCard(
        cardName: 'Mega Knight',
        winRate: 56.7,
        usageRate: 22.1,
        reason: 'Dominates mid-ladder with jump damage',
      ),
      BrokenCard(
        cardName: 'Firecracker',
        winRate: 55.9,
        usageRate: 18.5,
        reason: 'High value for elixir cost',
      ),
      BrokenCard(
        cardName: 'Phoenix',
        winRate: 55.2,
        usageRate: 12.8,
        reason: 'Resurrection mechanic too strong',
      ),
      BrokenCard(
        cardName: 'Monk',
        winRate: 54.8,
        usageRate: 16.3,
        reason: 'Ability deflection is overpowered',
      ),
    ];
  }

  // Search decks containing specific cards
  static List<MetaDeck> searchDecksByCards(List<String> cardNames) {
    final allDecks = getPopularDecks();
    
    return allDecks.where((deck) {
      // Check if deck contains all specified cards
      return cardNames.every((cardName) => 
        deck.cardNames.any((deckCard) => 
          deckCard.toLowerCase().contains(cardName.toLowerCase())
        )
      );
    }).toList();
  }

  // Generate deck link for copying
  static String generateDeckLink(List<String> cardNames) {
    // This is a placeholder format - actual Clash Royale deck links use a specific format
    // Format: clashroyale://copyDeck?deck=CARD_IDS
    // For now, we'll create a readable format
    return 'Deck: ${cardNames.join(', ')}';
  }
}
