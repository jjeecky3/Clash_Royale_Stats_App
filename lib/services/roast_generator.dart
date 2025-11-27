import 'dart:math';
import '../config/app_config.dart';
import '../models/roast.dart';
import '../models/stats.dart';

class RoastGenerator {
  final _random = Random();

  List<Roast> generateRoasts(Stats stats) {
    final roastsWithEmotes = <Roast>[];
    final winRate = stats.winRate;
    final avgCardLevel = stats.avgCardLevel;

    // Check win rate
    if (winRate < AppConfig.winRateThresholds['terrible']!) {
      final roastText = _getRandomRoast('low_win_rate')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1));
      // Use goblin cry if they have high card levels but low win rate
      final emote = avgCardLevel >= 10
          ? 'goblin_cry-removebg-preview.png'
          : '67-removebg-preview.png';
      roastsWithEmotes.add(Roast(text: roastText, emote: emote));
    } else if (winRate < AppConfig.winRateThresholds['mediocre']!) {
      final roastText = _getRandomRoast('low_win_rate')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1));
      roastsWithEmotes
          .add(Roast(text: roastText, emote: '67-removebg-preview.png'));
    }

    // Check trophies
    if (stats.trophies < AppConfig.trophyThresholds['low']!) {
      final roastText = _getRandomRoast('low_trophies')
          .replaceAll('{trophies}', stats.trophies.toString())
          .replaceAll('{king_level}', stats.kingLevel.toString());
      roastsWithEmotes
          .add(Roast(text: roastText, emote: 'goblin_cry-removebg-preview.png'));
    }

    // Check card levels
    if (avgCardLevel < 9) {
      final roastText = _getRandomRoast('card_levels')
          .replaceAll('{avg_card_level}', avgCardLevel.toStringAsFixed(1));
      roastsWithEmotes
          .add(Roast(text: roastText, emote: 'yawn-removebg-preview (1).png'));
    }

    // Check recent performance
    if (stats.recentBattles > 0 && stats.recentLosses >= 6) {
      final roastText = _getRandomRoast('losses')
          .replaceAll('{losses}', stats.recentLosses.toString())
          .replaceAll('{total_battles}', stats.recentBattles.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'hog-removebg-preview.png'));
    }

    // If no roasts (good player), give praise
    if (roastsWithEmotes.isEmpty) {
      final roastText = _getRandomRoast('good_performance')
          .replaceAll('{win_rate}', winRate.toStringAsFixed(1))
          .replaceAll('{trophies}', stats.trophies.toString());
      roastsWithEmotes.add(Roast(text: roastText, emote: 'king.png'));
    }

    return roastsWithEmotes;
  }

  String _getRandomRoast(String category) {
    final roasts = AppConfig.roasts[category] ?? [];
    if (roasts.isEmpty) return 'No roast available';
    return roasts[_random.nextInt(roasts.length)];
  }
}
