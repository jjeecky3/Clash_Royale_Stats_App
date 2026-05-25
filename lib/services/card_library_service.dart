import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../config/app_config.dart';
import '../utils/card_level_converter.dart';

class CardLibraryService {
  List<CardModel>? _cachedCards;
  
  Future<List<CardModel>> fetchAllCards() async {
    // Return cached cards if available
    if (_cachedCards != null) {
      return _cachedCards!;
    }

    try {
      final url = kIsWeb
          ? 'http://localhost:3000/api/cards'
          : 'https://api.clashroyale.com/v1/cards';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${AppConfig.apiToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        
        // Cards that have evolutions (complete and accurate list - 39 total)
        const evolutionCards = [
          'Barbarians',
          'Royal Giant',
          'Firecracker',
          'Skeletons',
          'Mortar',
          'Knight',
          'Royal Recruits',
          'Bats',
          'Archers',
          'Ice Spirit',
          'Valkyrie',
          'Bomber',
          'Wall Breakers',
          'Tesla',
          'Zap',
          'Battle Ram',
          'Wizard',
          'Goblin Barrel',
          'Goblin Giant',
          'Goblin Drill',
          'Goblin Cage',
          'P.E.K.K.A',
          'Mega Knight',
          'Electro Dragon',
          'Musketeer',
          'Cannon',
          'Giant Snowball',
          'Dart Goblin',
          'Lumberjack',
          'Hunter',
          'Executioner',
          'Witch',
          'Inferno Dragon',
          'Skeleton Barrel',
          'Furnace',
          'Baby Dragon',
          'Skeleton Army',
          'Royal Ghost',
          'Royal Hogs',
        ];
        
        // NEW: Hero cards from December 2025 update
        const heroCards = [
          'Hero Mini P.E.K.K.A',
          'Hero Musketeer',
          'Hero Knight',
          'Hero Giant',
        ];
        
        // Map Hero cards to their base card names for images
        const heroBaseCards = {
          'Hero Mini P.E.K.K.A': 'Mini P.E.K.K.A',
          'Hero Musketeer': 'Musketeer',
          'Hero Knight': 'Knight',
          'Hero Giant': 'Giant',
        };
        
        final List<CardModel> allCards = [];
        
        for (var cardJson in items) {
          final cardName = cardJson['name'] ?? '';
          final hasEvo = evolutionCards.contains(cardName);
          final isHeroCard = heroCards.contains(cardName);
          final iconUrls = cardJson['iconUrls'] as Map<String, dynamic>?;
          
          // Add normal version
          Map<String, String>? normalIconUrls;
          if (iconUrls != null) {
            // For normal version, use the 'medium' icon (not evolutionMedium)
            normalIconUrls = {
              'medium': iconUrls['medium'] ?? '',
            };
          }
          
          allCards.add(CardModel(
            name: cardName,
            level: cardJson['maxLevel'] ?? 14,
            displayLevel: cardJson['maxLevel'] ?? 14,
            iconUrls: normalIconUrls,
            rarity: (cardJson['rarity'] ?? 'common').toLowerCase(),
            elixirCost: cardJson['elixirCost'],
            hasEvolution: hasEvo,
            isEvolved: false,
            isHero: isHeroCard,
          ));
          
          // Add evolved version if card has evolution
          if (hasEvo) {
            Map<String, String>? evoIconUrls;
            
            // Check if we have a local evolution image for this card
            if (CardModel.evolutionCardImages.containsKey(cardName)) {
              // Use local evolution image
              evoIconUrls = {
                'medium': CardModel.evolutionCardImages[cardName]!,
              };
            } else if (iconUrls != null) {
              // For evolved version, use 'evolutionMedium' if available, fallback to 'medium'
              evoIconUrls = {
                'medium': iconUrls['evolutionMedium'] ?? iconUrls['medium'] ?? '',
              };
            }
            
            allCards.add(CardModel(
              name: cardName,
              level: cardJson['maxLevel'] ?? 14,
              displayLevel: cardJson['maxLevel'] ?? 14,
              iconUrls: evoIconUrls,
              rarity: (cardJson['rarity'] ?? 'common').toLowerCase(),
              elixirCost: cardJson['elixirCost'],
              hasEvolution: true,
              isEvolved: true, // This is the evolved variant
              isHero: false, // Evolved versions are not Heroes
            ));
          }
        }
        
        // Manually add Hero cards since they don't exist in API yet
        for (var heroCard in heroCards) {
          final baseCardName = heroBaseCards[heroCard] ?? heroCard.replaceAll('Hero ', '');
          
          // Find the base card to get its properties
          final baseCard = allCards.firstWhere(
            (c) => c.name == baseCardName && !c.isEvolved,
            orElse: () => CardModel(
              name: baseCardName,
              level: 14,
              displayLevel: 14,
              rarity: 'legendary',
              hasEvolution: false,
            ),
          );
          
          // Use hero image if available, otherwise use base card image
          Map<String, String>? heroIconUrls;
          if (CardModel.heroCardImages.containsKey(baseCardName)) {
            heroIconUrls = {
              'medium': CardModel.heroCardImages[baseCardName]!,
            };
          } else {
            heroIconUrls = baseCard.iconUrls;
          }
          
          // Create Hero card with hero image and properties
          allCards.add(CardModel(
            name: heroCard,
            level: 14,
            displayLevel: 14,
            iconUrls: heroIconUrls, // Use hero card's special image
            rarity: 'legendary', // Heroes are legendary rarity
            elixirCost: baseCard.elixirCost,
            hasEvolution: false,
            isEvolved: false,
            isHero: true, // Mark as Hero card
          ));
        }
        
        _cachedCards = allCards;

        // Sort by elixir cost, then by name
        _cachedCards!.sort((a, b) {
          final elixirCompare = (a.elixirCost ?? 0).compareTo(b.elixirCost ?? 0);
          if (elixirCompare != 0) return elixirCompare;
          return a.name.compareTo(b.name);
        });

        return _cachedCards!;
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      // Return empty list on error
      return [];
    }
  }

  List<CardModel> filterCards({
    List<CardModel>? cards,
    String? searchQuery,
    String? rarity,
    int? elixirCost,
  }) {
    var filtered = cards ?? _cachedCards ?? [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Normalize search query (remove dots, hyphens, spaces)
      final normalizedQuery = _normalizeSearchString(searchQuery);
      
      filtered = filtered.where((card) {
        final normalizedName = _normalizeSearchString(card.name);
        return normalizedName.contains(normalizedQuery);
      }).toList();
    }

    if (rarity != null && rarity != 'All') {
      if (rarity == 'Evolution') {
        // Filter for evolved variants only
        filtered = filtered.where((card) => card.isEvolved).toList();
      } else if (rarity == 'Hero') {
        // Filter for Hero cards only
        filtered = filtered.where((card) => card.isHero).toList();
      } else {
        // Filter by rarity - EXCLUDE evolved variants and Hero cards from rarity filters
        filtered = filtered.where((card) =>
            card.rarity.toLowerCase() == rarity.toLowerCase() && 
            !card.isEvolved && // Don't show EVO cards in rarity filters
            !card.isHero // Don't show Hero cards in rarity filters
        ).toList();
      }
    }

    if (elixirCost != null && elixirCost != -1) {
      filtered = filtered.where((card) =>
          card.elixirCost == elixirCost).toList();
    }

    return filtered;
  }

  // Normalize search string by removing special characters
  String _normalizeSearchString(String input) {
    return input
        .toLowerCase()
        .replaceAll('.', '')  // P.E.K.K.A → PEKKA
        .replaceAll('-', '')  // X-Bow → XBow
        .replaceAll(' ', ''); // Remove spaces
  }

  void clearCache() {
    _cachedCards = null;
  }
}
