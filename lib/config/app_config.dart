import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String apiBaseUrl = 'https://api.clashroyale.com/v1';
  
  // API token priority:
  // 1. --dart-define (String.fromEnvironment)
  // 2. .env file (dotenv.env)
  static String get apiToken {
    const envToken = String.fromEnvironment('CLASH_ROYALE_API_TOKEN');
    if (envToken.isNotEmpty) {
      return envToken;
    }
    return dotenv.env['CLASH_ROYALE_API_TOKEN'] ?? '';
  }

  // Clash Royale inspired color palette
  static const Color crBlue = Color(0xFF4A90E2);
  static const Color crBlueDark = Color(0xFF1E3A5F);
  static const Color crPurple = Color(0xFF8A2BE2);
  static const Color crGold = Color(0xFFFFD700);
  static const Color crOrange = Color(0xFFFF8C00);
  static const Color crRed = Color(0xFFF44336);
  static const Color crGreen = Color(0xFF4CAF50);

  // Dark theme colors
  static const Color bgDark = Color(0xFF1A1F2E);
  static const Color bgDarker = Color(0xFF0F1419);
  static const Color bgCard = Color(0xFF252D3D);
  static const Color bgCardHover = Color(0xFF2D3748);
  static const Color textPrimary = Color(0xFFF2F2F2);
  static const Color textSecondary = Color(0xFFBFBFBF);
  static const Color textMuted = Color(0xFF8C8C8C);

  // Roast configuration
  static const Map<String, int> winRateThresholds = {
    'terrible': 40,
    'mediocre': 50,
  };

  static const Map<String, int> trophyThresholds = {
    'low': 3000,
  };

  static const Map<String, List<String>> roasts = {
    'terrible_win_rate': [
      'With a {win_rate}% win rate, maybe Clash Royale isn\'t your game... have you tried Candy Crush? 🍬',
      '{win_rate}%? That\'s not a win rate, that\'s a cry for help! 😭',
      'A {win_rate}% win rate means you\'re basically donating trophies. Very generous! 🎁',
    ],
    'low_win_rate': [
      'With a {win_rate}% win rate, you might want to reconsider your deck... or maybe just reconsider playing! 😅',
      '{win_rate}% win rate? The AI must be carrying you in those wins! 🤖',
      'A {win_rate}% win rate means you lose more than you win. Time to hit the practice arena! 📚',
    ],
    'low_trophies': [
      '{trophies} trophies at King Level {king_level}? Your opponents must be celebrating! 🎉',
      'Only {trophies} trophies? Even the training camp bots have more! 🤖',
      '{trophies} trophies suggests you might be better at watching than playing! 👀',
    ],
    'card_levels': [
      'Average card level {avg_card_level}? Time to open some chests! 📦',
      'With average card level {avg_card_level}, you\'re bringing a wooden sword to a lightsaber fight! ⚔️',
      'Average card level {avg_card_level}? Your opponents are laughing before the match even starts! 😂',
    ],
    'losses': [
      'You lost {losses} out of {total_battles} recent battles. Maybe it\'s time for a break? ☕',
      '{losses} losses recently? Your deck is crying for help! 😭',
      '{losses} losses in {total_battles} games? Ouch! That\'s gotta hurt. 🤕',
    ],
    'loss_streak': [
      '{streak} losses in a row? Time to uninstall and reinstall... might help! 🔄',
      'A {streak} loss streak? Even your cards want to quit! 🏳️',
      '{streak} straight losses? The game is trying to tell you something! 📢',
    ],
    'excellent_performance': [
      '{win_rate}% win rate and {trophies} trophies? You\'re absolutely crushing it! Keep dominating! 👑',
      'Impressive stats! You\'re actually good at this game! 🏆',
      'Great performance! Your opponents must be scared when they see you! 💪',
      '{win_rate}%? Now that\'s what I call skill! Your opponents don\'t stand a chance! ⚡',
    ],
    'good_performance': [
      '{win_rate}% win rate and {trophies} trophies? Not bad, not bad at all! Keep it up! 👍',
      'Solid performance! You know what you\'re doing! 💪',
      '{win_rate}%? Pretty good! You\'re above average for sure! 📈',
    ],
    'average_performance': [
      '{win_rate}% win rate? You\'re perfectly average. Congrats on being... average! 🤷',
      'With a {win_rate}% win rate, you\'re neither good nor bad. Just... there. 😐',
      '{win_rate}%? You\'re the definition of mediocre. Not an insult, just facts! 📊',
    ],
  };
}
