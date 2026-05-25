class CardModel {
  final String name;
  final int level; // Actual level from API
  final int displayLevel; // Display level after conversion
  final String rarity;
  final int? evolutionLevel;
  final bool hasEvolution;
  final bool isEvolved; // Indicates if this is the evolved variant
  final bool isHero; // NEW: Indicates if this is a Hero card (Dec 2025 update)
  final int? starLevel; // Star level (cosmetic upgrade)
  final int? elixirCost; // Elixir cost of the card
  final Map<String, String>? iconUrls;

  // List of hero card base names as returned by the API
  // IMPORTANT: These are the ONLY cards that have HERO versions
  // P.E.K.K.A and Hunter are  // Hero card base names (without "Hero " prefix)
  static const heroCardBaseNames = {
    'Knight',
    'Musketeer',
    'Mini P.E.K.K.A',
    'Giant',
  };
  
  // Hero card image URLs from Supercell Fankit
  // Using local assets since Fankit URLs require authentication
  static const heroCardImages = {
    'Knight': 'assets/images/heroes/hero_knight.png',
    'Musketeer': 'assets/images/heroes/hero_musketeer.png',
    'Mini P.E.K.K.A': 'assets/images/heroes/hero_mini_pekka.png',
    'Giant': 'assets/images/heroes/hero_giant.png',
  };
  
  // Evolution card images for cards where API provides incorrect/same image
  static const evolutionCardImages = {
    'Skeleton Army': 'assets/images/evolutions/evo_skeleton_army.png',
  };

  CardModel({
    required this.name,
    required this.level,
    required this.displayLevel,
    required this.rarity,
    this.evolutionLevel,
    required this.hasEvolution,
    this.isEvolved = false, // Default to normal version
    this.isHero = false, // Default to non-Hero
    this.starLevel,
    this.elixirCost,
    this.iconUrls,
  });

  factory CardModel.fromJson(Map<String, dynamic> json, int displayLevel, {int? deckPosition}) {
    final cardName = json['name'] ?? '';
    final evolutionLevel = json['evolutionLevel'] ?? 0;
    final rarity = json['rarity'] ?? 'common';
    
    // Debug: Print card data to see what we're getting
    if (cardName.contains('Mini P.E.K.K.A') || cardName.contains('Hunter') || cardName.contains('Skeleton Army') || cardName.contains('Musketeer') || cardName.contains('Knight') || cardName.contains('Giant')) {
      print('DEBUG Card: $cardName (position: $deckPosition)');
      print('  evolutionLevel: $evolutionLevel');
      print('  rarity: $rarity');
      print('  iconUrls: ${json['iconUrls']}');
    }
    
    // POSITION-BASED DETECTION WITH EVOLUTION LEVEL
    // Evolution level indicates unlock status:
    // - evolutionLevel = 1: Evolution only unlocked
    // - evolutionLevel = 2: Hero only unlocked
    // - evolutionLevel = 3: Both unlocked
    //
    // Deck slot positions:
    // - Slots 0-1 (first two): EVO slots
    // - Slots 2-3 (third and fourth): HERO/Champion slots
    // - Slots 4-7 (remaining): Normal slots
    
    bool isEvolved = false;
    bool isHero = false;
    
    if (deckPosition != null) {
      // EVO detection: Card is EVO if in slots 0-1 AND evolutionLevel is 1 or 3
      if (deckPosition >= 0 && deckPosition <= 1) {
        isEvolved = (evolutionLevel == 1 || evolutionLevel == 3);
      }
      
      // HERO detection: Card is HERO if in slots 2-3 AND evolutionLevel >= 2
      if (deckPosition >= 2 && deckPosition <= 3) {
        isHero = (evolutionLevel >= 2);
      }
    } else {
      // Fallback for cards without position (e.g., in card library)
      // Use the old logic but don't mark as evolved/hero
      isEvolved = false;
    }
    
    // Select the appropriate image URL based on card type
    Map<String, String>? finalIconUrls;
    if (isHero && heroCardImages.containsKey(cardName)) {
      // Use hero card image from Supercell Fankit
      finalIconUrls = {
        'medium': heroCardImages[cardName]!,
      };
    } else if (isEvolved && evolutionCardImages.containsKey(cardName)) {
      // Use local evolution image for cards where API provides incorrect image
      finalIconUrls = {
        'medium': evolutionCardImages[cardName]!,
      };
    } else if (json['iconUrls'] != null) {
      final iconUrls = json['iconUrls'] as Map<String, dynamic>;
      
      // DEBUG: Check Skeleton Army evolution URLs
      if (cardName == 'Skeleton Army') {
        print('=== SKELETON ARMY DEBUG ===');
        print('  isEvolved: $isEvolved');
        print('  evolutionLevel: $evolutionLevel');
        print('  deckPosition: $deckPosition');
        print('  Available iconUrls keys: ${iconUrls.keys.toList()}');
        print('  medium: ${iconUrls['medium']}');
        print('  evolutionMedium: ${iconUrls['evolutionMedium']}');
        print('  Using local asset: ${isEvolved && evolutionCardImages.containsKey(cardName)}');
        print('========================');
      }
      
      if (isEvolved && iconUrls['evolutionMedium'] != null) {
        // Use evolution image for evolved cards
        finalIconUrls = {
          'medium': iconUrls['evolutionMedium'] as String,
        };
      } else {
        // Use normal image
        finalIconUrls = {
          'medium': (iconUrls['medium'] ?? '') as String,
        };
      }
    }
    
    return CardModel(
      name: cardName,
      level: json['level'] ?? 1,
      displayLevel: displayLevel,
      rarity: rarity,
      evolutionLevel: evolutionLevel,
      hasEvolution: evolutionLevel > 0,
      isEvolved: isEvolved,
      isHero: isHero,
      starLevel: json['starLevel'],
      elixirCost: json['elixirCost'],
      iconUrls: finalIconUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'displayLevel': displayLevel,
      'rarity': rarity,
      'evolutionLevel': evolutionLevel,
      'hasEvolution': hasEvolution,
      'isEvolved': isEvolved,
      'isHero': isHero,
      'starLevel': starLevel,
      'elixirCost': elixirCost,
      'iconUrls': iconUrls,
    };
  }
}
