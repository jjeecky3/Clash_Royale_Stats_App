import '../models/card.dart';
import '../models/deck_analysis.dart';

class DeckAnalyzerService {
  // Win condition cards
  static const Map<String, List<String>> winConditionCategories = {
    'Beatdown': ['Golem', 'Giant', 'Lava Hound', 'Electro Giant', 'Royal Giant'],
    'Siege': ['X-Bow', 'Mortar'],
    'Control': ['Graveyard', 'Miner', 'Goblin Barrel'],
    'Bridge Spam': ['Battle Ram', 'Ram Rider', 'Royal Hogs', 'Bandit'],
    'Cycle': ['Hog Rider', 'Miner', 'Wall Breakers'],
  };

  // Card synergies (card1 + card2)
  static const Map<String, List<String>> synergyPairs = {
    'Golem': ['Night Witch', 'Baby Dragon', 'Lightning', 'Tornado'],
    'Hog Rider': ['Earthquake', 'Freeze', 'Fireball', 'Log'],
    'Balloon': ['Lumberjack', 'Freeze', 'Miner', 'Lava Hound'],
    'Graveyard': ['Freeze', 'Poison', 'Knight', 'Ice Wizard'],
    'X-Bow': ['Tesla', 'Archers', 'Ice Golem', 'Log'],
    'Goblin Barrel': ['Princess', 'Rocket', 'Log', 'Knight'],
    'Miner': ['Poison', 'Wall Breakers', 'Goblin Gang'],
    'Giant': ['Musketeer', 'Mini P.E.K.K.A', 'Mega Minion'],
    'Lava Hound': ['Balloon', 'Miner', 'Tombstone'],
    'Royal Hogs': ['Earthquake', 'Fireball', 'Royal Delivery'],
  };

  DeckAnalysis analyzeDeck(List<CardModel> deck) {
    if (deck.length != 8) {
      return DeckAnalysis.empty();
    }

    final avgElixir = _calculateAvgElixir(deck);
    final cardTypes = _analyzeCardTypes(deck);
    final winConditions = _detectWinConditions(deck);
    final synergies = _detectSynergies(deck);
    final weaknesses = _detectWeaknesses(deck);
    final archetype = _determineArchetype(winConditions);
    final metaRating = _calculateMetaRating(deck, weaknesses, synergies);
    final recommendations = _generateRecommendations(deck, weaknesses, avgElixir);

    return DeckAnalysis(
      avgElixirCost: avgElixir,
      cardTypeDistribution: cardTypes,
      winConditions: winConditions,
      synergies: synergies,
      weaknesses: weaknesses,
      metaRating: metaRating,
      recommendations: recommendations,
      deckArchetype: archetype,
    );
  }

  double _calculateAvgElixir(List<CardModel> deck) {
    if (deck.isEmpty) return 0.0;
    final total = deck.map((c) => c.elixirCost ?? 0).reduce((a, b) => a + b);
    return total / deck.length;
  }

  Map<String, int> _analyzeCardTypes(List<CardModel> deck) {
    final types = <String, int>{
      'Troop': 0,
      'Spell': 0,
      'Building': 0,
    };

    for (var card in deck) {
      final type = _getCardType(card.name);
      types[type] = (types[type] ?? 0) + 1;
    }

    return types;
  }

  String _getCardType(String cardName) {
    // Spells
    const spells = [
      'Zap', 'Fireball', 'Arrows', 'Rocket', 'Lightning', 'Freeze',
      'Poison', 'Tornado', 'Rage', 'Clone', 'Heal Spirit', 'Earthquake',
      'Graveyard', 'Mirror', 'The Log', 'Snowball', 'Barbarian Barrel',
      'Royal Delivery', 'Giant Snowball'
    ];

    // Buildings
    const buildings = [
      'Cannon', 'Tesla', 'Inferno Tower', 'Bomb Tower', 'X-Bow',
      'Mortar', 'Tombstone', 'Goblin Hut', 'Barbarian Hut', 'Furnace',
      'Elixir Collector', 'Goblin Cage', 'Goblin Drill'
    ];

    if (spells.contains(cardName)) return 'Spell';
    if (buildings.contains(cardName)) return 'Building';
    return 'Troop';
  }

  List<String> _detectWinConditions(List<CardModel> deck) {
    final winCons = <String>[];
    final deckCardNames = deck.map((c) => c.name).toList();

    for (var category in winConditionCategories.entries) {
      for (var winCon in category.value) {
        if (deckCardNames.contains(winCon)) {
          winCons.add('$winCon (${category.key})');
        }
      }
    }

    return winCons;
  }

  List<String> _detectSynergies(List<CardModel> deck) {
    final synergies = <String>[];
    final deckCardNames = deck.map((c) => c.name).toList();

    for (var entry in synergyPairs.entries) {
      final mainCard = entry.key;
      final synergyCards = entry.value;

      if (deckCardNames.contains(mainCard)) {
        for (var synergyCard in synergyCards) {
          if (deckCardNames.contains(synergyCard)) {
            synergies.add('$mainCard + $synergyCard');
          }
        }
      }
    }

    return synergies;
  }

  List<String> _detectWeaknesses(List<CardModel> deck) {
    final weaknesses = <String>[];
    final deckCardNames = deck.map((c) => c.name).toList();

    // Check for air defense
    const airDefense = [
      'Musketeer', 'Archers', 'Mega Minion', 'Bats', 'Minions',
      'Wizard', 'Executioner', 'Baby Dragon', 'Inferno Dragon',
      'Tesla', 'Inferno Tower', 'Hunter', 'Magic Archer', 'Firecracker'
    ];
    if (!deckCardNames.any((card) => airDefense.contains(card))) {
      weaknesses.add('Weak to air attacks - lacks anti-air defense');
    }

    // Check for splash damage
    const splash = [
      'Wizard', 'Valkyrie', 'Baby Dragon', 'Bomber', 'Executioner',
      'Bowler', 'Dark Prince', 'Mega Knight', 'Fireball', 'Poison',
      'Arrows', 'Zap', 'The Log'
    ];
    if (!deckCardNames.any((card) => splash.contains(card))) {
      weaknesses.add('Weak to swarm - lacks splash damage');
    }

    // Check for heavy spell
    const heavySpells = ['Fireball', 'Poison', 'Lightning', 'Rocket'];
    if (!deckCardNames.any((card) => heavySpells.contains(card))) {
      weaknesses.add('No heavy spell - vulnerable to support troops');
    }

    // Check for building
    const buildings = [
      'Cannon', 'Tesla', 'Inferno Tower', 'Bomb Tower', 'Tombstone',
      'Goblin Cage'
    ];
    if (!deckCardNames.any((card) => buildings.contains(card))) {
      weaknesses.add('No defensive building - vulnerable to beatdown');
    }

    // Check average elixir
    final avgElixir = _calculateAvgElixir(deck);
    if (avgElixir > 4.0) {
      weaknesses.add('High elixir cost - may struggle in fast-paced matches');
    } else if (avgElixir < 3.0) {
      weaknesses.add('Very low elixir - may lack defensive power');
    }

    // Check for win condition
    if (_detectWinConditions(deck).isEmpty) {
      weaknesses.add('⚠️ CRITICAL: No clear win condition!');
    }

    return weaknesses;
  }

  String _determineArchetype(List<String> winConditions) {
    if (winConditions.isEmpty) return 'Unknown';

    for (var winCon in winConditions) {
      if (winCon.contains('Beatdown')) return 'Beatdown';
      if (winCon.contains('Siege')) return 'Siege';
      if (winCon.contains('Control')) return 'Control';
      if (winCon.contains('Bridge Spam')) return 'Bridge Spam';
      if (winCon.contains('Cycle')) return 'Cycle';
    }

    return 'Hybrid';
  }

  int _calculateMetaRating(List<CardModel> deck, List<String> weaknesses, List<String> synergies) {
    int rating = 5; // Start at 5/10

    // Bonus for synergies
    rating += (synergies.length * 0.5).round();

    // Penalty for weaknesses
    rating -= weaknesses.length;

    // Bonus for balanced elixir
    final avgElixir = _calculateAvgElixir(deck);
    if (avgElixir >= 3.0 && avgElixir <= 4.0) {
      rating += 1;
    }

    // Bonus for having win condition
    if (_detectWinConditions(deck).isNotEmpty) {
      rating += 1;
    }

    // Clamp between 1-10
    return rating.clamp(1, 10);
  }

  List<String> _generateRecommendations(List<CardModel> deck, List<String> weaknesses, double avgElixir) {
    final recommendations = <String>[];

    if (weaknesses.any((w) => w.contains('air'))) {
      recommendations.add('Add anti-air cards like Musketeer or Mega Minion');
    }

    if (weaknesses.any((w) => w.contains('swarm'))) {
      recommendations.add('Add splash damage like Valkyrie or Wizard');
    }

    if (weaknesses.any((w) => w.contains('heavy spell'))) {
      recommendations.add('Add Fireball or Poison for support troops');
    }

    if (weaknesses.any((w) => w.contains('building'))) {
      recommendations.add('Add Tesla or Cannon for defense');
    }

    if (avgElixir > 4.0) {
      recommendations.add('Consider replacing high-cost cards with cheaper alternatives');
    }

    if (weaknesses.any((w) => w.contains('win condition'))) {
      recommendations.add('⚠️ Add a win condition like Hog Rider, Giant, or Miner');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Deck looks solid! Practice and refine your strategy.');
    }

    return recommendations;
  }
}
