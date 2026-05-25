import '../models/card.dart';

class DeckBuildingRules {
  // Maximum number of Champion + Hero cards combined (any combination)
  static const int maxHeroChampionCards = 2;
  
  // Maximum number of Evolution cards
  static const int maxEvolutionCards = 2;
  
  // Total cards in a deck
  static const int deckSize = 8;
  
  /// Validates if a card can be added to the current deck
  static String? validateCardAddition(CardModel card, List<CardModel> currentDeck) {
    // Check if deck is full
    if (currentDeck.length >= deckSize) {
      return 'Deck is full! Maximum $deckSize cards allowed.';
    }
    
    // Check Hero/Champion limit (combined)
    final heroChampionCount = currentDeck.where((c) => 
      c.rarity.toLowerCase() == 'champion' || c.isHero
    ).length;
    
    final isHeroOrChampion = card.rarity.toLowerCase() == 'champion' || card.isHero;
    
    if (isHeroOrChampion && heroChampionCount >= maxHeroChampionCards) {
      return 'Maximum $maxHeroChampionCards Hero/Champion cards allowed!\n(Any combination of Heroes and Champions)';
    }
    
    // Check Evolution card limit
    final evolutionCount = currentDeck.where((c) => c.isEvolved).length;
    
    if (card.isEvolved && evolutionCount >= maxEvolutionCards) {
      return 'Maximum $maxEvolutionCards Evolution cards allowed!';
    }
    
    return null; // Card can be added
  }
  
  /// Orders deck cards according to slot rules:
  /// - Slots 1-2 (top row left): Evolution cards
  /// - Slots 3-4 (top row right): Hero/Champion cards
  /// - Slots 5-8 (bottom row): Regular cards
  static List<CardModel> orderDeckCards(List<CardModel> cards) {
    final evolutionCards = cards.where((c) => c.isEvolved).toList();
    final heroChampionCards = cards.where((c) => 
      (c.rarity.toLowerCase() == 'champion' || c.isHero) && !c.isEvolved
    ).toList();
    final regularCards = cards.where((c) => 
      !c.isEvolved && c.rarity.toLowerCase() != 'champion' && !c.isHero
    ).toList();
    
    final orderedDeck = <CardModel>[];
    
    // Slots 1-2: Evolution cards (up to 2)
    orderedDeck.addAll(evolutionCards.take(2));
    
    // Slots 3-4: Hero/Champion cards (up to 2)
    orderedDeck.addAll(heroChampionCards.take(2));
    
    // Remaining slots: Regular cards
    orderedDeck.addAll(regularCards);
    
    return orderedDeck;
  }
}
