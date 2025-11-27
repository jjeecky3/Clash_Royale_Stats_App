class CardLevelConverter {
  /// Convert API star level to displayed card level.
  /// Clash Royale uses different progressions based on rarity:
  /// - Common: 1-14 (star 1-14 = display 1-14)
  /// - Rare: 1-11 (star 1-11 = display 3-13)
  /// - Epic: 1-8 (star 1-8 = display 6-13)
  /// - Legendary: 1-5 (star 1-5 = display 9-13)
  /// - Champion: 1-3 (star 1-3 = display 11-13)
  static int convertCardLevel(int starLevel, String rarity) {
    final rarityLower = rarity.toLowerCase();

    switch (rarityLower) {
      case 'common':
        return starLevel; // 1-14 maps directly
      case 'rare':
        return starLevel + 2; // 1-11 becomes 3-13
      case 'epic':
        return starLevel + 5; // 1-8 becomes 6-13
      case 'legendary':
        return starLevel + 8; // 1-5 becomes 9-13
      case 'champion':
        return starLevel + 10; // 1-3 becomes 11-13
      default:
        return starLevel; // Fallback
    }
  }

  /// Format player tag to ensure it starts with #
  static String formatPlayerTag(String tag) {
    String formattedTag = tag.trim().toUpperCase();
    if (!formattedTag.startsWith('#')) {
      formattedTag = '#$formattedTag';
    }
    return formattedTag;
  }
}
