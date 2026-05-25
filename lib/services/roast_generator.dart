import 'dart:math';
import '../config/app_config.dart';
import '../models/roast.dart';
import '../models/stats.dart';

class RoastGenerator {
  final _random = Random();

  // Hated cards that trigger roasts
  static const List<String> hatedCards = [
    'Mega Knight',
    'Elite Barbarians',
    'X-Bow',
    'Electro Giant',
    'Freeze',
    'Rage',
    'Mirror',
    'Balloon',
    'Lumberjack',
  ];

  // Popular deck archetypes (key cards that define them)
  static const Map<String, List<String>> deckArchetypes = {
    '2.6 Hog Cycle': ['Hog Rider', 'Musketeer', 'Ice Golem', 'Cannon'],
    'Log Bait': ['Goblin Barrel', 'Princess', 'Rocket', 'Knight'],
    'X-Bow': ['X-Bow', 'Tesla', 'Archers'],
    'Golem Beatdown': ['Golem', 'Night Witch', 'Baby Dragon'],
    'Lava Hound': ['Lava Hound', 'Balloon', 'Miner'],
    'Bridge Spam': ['Battle Ram', 'Bandit', 'Royal Ghost'],
    'Graveyard': ['Graveyard', 'Freeze'],
  };

  List<Roast> generateRoasts(Stats stats) {
    final roastsWithEmotes = <Roast>[];
    final winRate = stats.winRate;
    final avgCardLevel = stats.avgCardLevel;

    // Check for hated cards
    final hatedCardsInDeck = _detectHatedCards(stats.currentDeck);
    if (hatedCardsInDeck.isNotEmpty) {
      final roastText = _getHatedCardRoast(hatedCardsInDeck);
      roastsWithEmotes.add(Roast(text: roastText, emote: 'goblin_cry-removebg-preview.png'));
    }

    // Check for meta/popular decks
    final detectedArchetype = _detectDeckArchetype(stats.currentDeck);
    if (detectedArchetype != null) {
      final roastText = _getArchetypeRoast(detectedArchetype);
      roastsWithEmotes.add(Roast(text: roastText, emote: 'yawn-removebg-preview (1).png'));
    }

    // Check win rate (STRICTER thresholds)
    if (winRate < 45) {
      final roastText = _getRandomRoast('terrible_win_rate')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1));
      final emote = avgCardLevel >= 12
          ? 'goblin_cry-removebg-preview.png'
          : '67-removebg-preview.png';
      roastsWithEmotes.add(Roast(text: roastText, emote: emote));
    } else if (winRate < 52) {
      final roastText = _getRandomRoast('low_win_rate')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1));
      roastsWithEmotes.add(Roast(text: roastText, emote: '67-removebg-preview.png'));
    }

    // Check trophies
    if (stats.trophies < AppConfig.trophyThresholds['low']!) {
      final roastText = _getRandomRoast('low_trophies')
          .replaceAll('{trophies}', stats.trophies.toString())
          .replaceAll('{king_level}', stats.kingLevel.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'goblin_cry-removebg-preview.png'));
    }

    // Check card levels (FIXED LOGIC - only roast if actually low)
    if (avgCardLevel < 11 && stats.kingLevel >= 11) {
      final roastText = _getRandomRoast('card_levels')
          .replaceAll('{avg_card_level}', avgCardLevel.toStringAsFixed(1));
      roastsWithEmotes.add(Roast(text: roastText, emote: 'yawn-removebg-preview (1).png'));
    }

    // Check recent performance
    if (stats.recentBattles > 0 && stats.recentLosses >= 6) {
      final roastText = _getRandomRoast('losses')
          .replaceAll('{losses}', stats.recentLosses.toString())
          .replaceAll('{total_battles}', stats.recentBattles.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'hog-removebg-preview.png'));
    }

    // Check for loss streak
    if (stats.currentStreak > 3 && stats.streakType == 'loss') {
      final roastText = _getRandomRoast('loss_streak')
          .replaceAll('{streak}', stats.currentStreak.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'goblin_cry-removebg-preview.png'));
    }

    // If no roasts (good player), give praise (STRICTER - need 60%+ win rate)
    if (roastsWithEmotes.isEmpty && winRate >= 60) {
      final roastText = _getRandomRoast('excellent_performance')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1))
          .replaceAll('{trophies}', stats.trophies.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'king.png'));
    } else if (roastsWithEmotes.isEmpty && winRate >= 55) {
      final roastText = _getRandomRoast('good_performance')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1))
          .replaceAll('{trophies}', stats.trophies.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'king.png'));
    } else if (roastsWithEmotes.isEmpty) {
      // Average player - neutral comment
      final roastText = _getRandomRoast('average_performance')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1));
      roastsWithEmotes.add(Roast(text: roastText, emote: '67-removebg-preview.png'));
    }

    return roastsWithEmotes;
  }

  List<String> _detectHatedCards(List<dynamic> deck) {
    final foundHatedCards = <String>[];
    for (var card in deck) {
      final cardName = card.name as String;
      if (hatedCards.contains(cardName)) {
        foundHatedCards.add(cardName);
      }
    }
    return foundHatedCards;
  }

  String? _detectDeckArchetype(List<dynamic> deck) {
    final deckCardNames = deck.map((card) => card.name as String).toList();
    
    for (var entry in deckArchetypes.entries) {
      final archetypeName = entry.key;
      final keyCards = entry.value;
      
      // Check if at least 3 key cards match
      int matches = 0;
      for (var keyCard in keyCards) {
        if (deckCardNames.contains(keyCard)) {
          matches++;
        }
      }
      
      if (matches >= 3) {
        return archetypeName;
      }
    }
    
    return null;
  }

  String _getHatedCardRoast(List<String> hatedCards) {
    final card = hatedCards.first;
    final roasts = {
      'Mega Knight': [
        'Mega Knight? Really? Let me guess, you also spam emotes when you win? 🙄',
        'Using Mega Knight is like using training wheels on a bicycle. Time to grow up! 🚴',
        'Mega Knight user detected! Your opponents are rolling their eyes right now. 👀',
      ],
      'Elite Barbarians': [
        'Elite Barbarians at the bridge? How original! Said no one ever. 🥱',
        'E-Barbs + Rage? Let me guess, you think you\'re a genius? 🤡',
        'Elite Barbarians... the card choice of people who gave up on strategy. 🤦',
      ],
      'X-Bow': [
        'X-Bow? Ah yes, the "I like to make games last 6 minutes" card. ⏰',
        'X-Bow defensive player spotted! Your opponents are falling asleep. 😴',
        'Using X-Bow? Hope you enjoy watching paint dry! 🎨',
      ],
      'Electro Giant': [
        'Electro Giant? The card for people who don\'t like thinking. ⚡',
        'E-Giant user! Your skill level is showing... and it\'s not good. 📉',
      ],
      'Freeze': [
        'Freeze spell? The ultimate "I have no skill" card! ❄️',
        'Using Freeze is basically admitting you can\'t win without cheese. 🧀',
      ],
      'Rage': [
        'Rage spell? Let me guess, you also spam it at the bridge? 😤',
        'Rage + anything = low skill gameplay. Change my mind. 🧠',
      ],
      'Mirror': [
        'Mirror? Double the spam, double the shame! 🪞',
        'Mirror card detected! Originality: 0/10. 📊',
      ],
      'Balloon': [
        'Balloon + Freeze? How predictable can you get? 🎈',
        'Balloon user! Your opponents saw that coming from a mile away. 👁️',
      ],
      'Lumberjack': [
        'Lumberjack + Balloon? The classic "no skill" combo! 🪓',
        'Lumberjack Rage? So original! (Not really) 🙃',
      ],
    };
    
    final cardRoasts = roasts[card] ?? ['Using $card? Interesting choice... 🤔'];
    return cardRoasts[_random.nextInt(cardRoasts.length)];
  }

  String _getArchetypeRoast(String archetype) {
    final roasts = {
      '2.6 Hog Cycle': [
        '2.6 Hog Cycle? How original! Only 2 million other players use it. 🐷',
        'Running 2.6? Let me guess, you watched a YouTube tutorial? 📺',
        '2.6 Hog Cycle detected! Creativity level: 0%. 📉',
      ],
      'Log Bait': [
        'Log Bait? The deck for people who love being annoying. 🪵',
        'Running Log Bait? Your opponents are groaning already. 😫',
        'Log Bait user! Because why be original when you can copy the meta? 🐑',
      ],
      'X-Bow': [
        'X-Bow deck? Hope you have 10 minutes per match! ⏱️',
        'X-Bow player detected! Your matches must be thrilling... for no one. 😴',
      ],
      'Golem Beatdown': [
        'Golem in the back? How predictable! Everyone saw that coming. 🗿',
        'Golem Beatdown? The "I have no elixir management skills" deck. 💎',
      ],
      'Bridge Spam': [
        'Bridge Spam? The deck for people with ADHD. 🌉',
        'Spamming at the bridge? Your strategy is as subtle as a brick. 🧱',
      ],
    };
    
    final archetypeRoasts = roasts[archetype] ?? ['Running $archetype? Interesting choice! 🤔'];
    return archetypeRoasts[_random.nextInt(archetypeRoasts.length)];
  }

  String _getRandomRoast(String category) {
    final roasts = AppConfig.roasts[category] ?? [];
    if (roasts.isEmpty) return 'No roast available';
    return roasts[_random.nextInt(roasts.length)];
  }
}
