import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/meta_data_service.dart';
import '../services/card_library_service.dart';
import '../models/card.dart';
import '../config/deck_building_rules.dart';

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  State<TrackProgressScreen> createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CardLibraryService _cardLibrary = CardLibraryService();
  List<CardModel> _allCards = [];
  List<String> _selectedCards = [];
  List<MetaDeck> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _cardLibrary.fetchAllCards();
    setState(() {
      _allCards = cards;
    });
  }

  void _copyDeckToClipboard(List<String> cardNames) {
    final deckText = MetaDataService.generateDeckLink(cardNames);
    Clipboard.setData(ClipboardData(text: deckText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Deck copied to clipboard!'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        title: const Text('Track Progress'),
        backgroundColor: const Color(0xFF252D3D),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8A2BE2),
          tabs: const [
            Tab(text: 'Popular Decks'),
            Tab(text: 'Deck Search'),
            Tab(text: 'Broken Cards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPopularDecksTab(),
          _buildDeckSearchTab(),
          _buildBrokenCardsTab(),
        ],
      ),
    );
  }

  Widget _buildPopularDecksTab() {
    final popularDecks = MetaDataService.getPopularDecks();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: popularDecks.length,
      itemBuilder: (context, index) {
        final deck = popularDecks[index];
        return _buildDeckCard(deck);
      },
    );
  }

  Widget _buildDeckCard(MetaDeck deck) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F2E),
            const Color(0xFF252D3D),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: deck.rank <= 3 ? const Color(0xFFFFD700) : const Color(0xFF3A4152),
          width: deck.rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (deck.rank <= 3 ? const Color(0xFFFFD700) : const Color(0xFF8A2BE2)).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: deck.rank <= 3 
                        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                        : [const Color(0xFF8A2BE2), const Color(0xFF6A1BB2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (deck.rank <= 3 ? const Color(0xFFFFD700) : const Color(0xFF8A2BE2)).withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '#${deck.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A2BE2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deck.archetype,
                            style: const TextStyle(
                              color: Color(0xFF8A2BE2),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF8A2BE2)),
                onPressed: () => _copyDeckToClipboard(deck.cardNames),
                tooltip: 'Copy Deck',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStat('Win', '${deck.winRate}%', const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildStat('Usage', '${deck.usageRate}%', const Color(0xFF2196F3)),
            ],
          ),
          const SizedBox(height: 16),
          // Card Grid (4x2 layout like reference image)
          _buildCardGrid(deck.cardNames),
        ],
      ),
    );
  }

  Widget _buildCardGrid(List<String> cardNames) {
    // Find actual card models and order them according to deck rules
    final cardModels = cardNames.map((name) {
      return _allCards.firstWhere(
        (c) => c.name == name,
        orElse: () => CardModel(
          name: name,
          level: 14,
          displayLevel: 14,
          rarity: 'common',
          hasEvolution: false,
        ),
      );
    }).toList();
    
    // Order cards according to deck slot rules
    final orderedCards = DeckBuildingRules.orderDeckCards(cardModels);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // First row (4 cards): Slots 1-2 Evolution, Slots 3-4 Hero/Champion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: orderedCards.take(4).map((card) => _buildCardImageFromModel(card as CardModel)).toList(),
          ),
          const SizedBox(height: 8),
          // Second row (4 cards): Regular cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: orderedCards.skip(4).take(4).map((card) => _buildCardImageFromModel(card as CardModel)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardImageFromModel(CardModel card) {
    final imageUrl = card.iconUrls?['medium'];

    return Container(
      width: 60,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRarityColor(card.rarity),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRarityColor(card.rarity).withOpacity(0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: imageUrl != null
            ? (imageUrl.startsWith('assets/')
                ? Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF252D3D),
                        child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 24),
                      );
                    },
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF252D3D),
                        child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 24),
                      );
                    },
                  ))
            : Container(
                color: const Color(0xFF252D3D),
                child: Center(
                  child: Text(
                    card.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF9E9E9E);
      case 'rare':
        return const Color(0xFFFF9800);
      case 'epic':
        return const Color(0xFF9C27B0);
      case 'legendary':
        return const Color(0xFFFFD700);
      case 'champion':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _buildStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardChip(String cardName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A4152)),
      ),
      child: Text(
        cardName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDeckSearchTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A1F2E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select cards to find decks:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedCards.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedCards.map((card) {
                    return Chip(
                      label: Text(card),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedCards.remove(card);
                          _searchResults = MetaDataService.searchDecksByCards(_selectedCards);
                        });
                      },
                      backgroundColor: const Color(0xFF8A2BE2),
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showCardPicker(),
                icon: const Icon(Icons.add),
                label: const Text('Add Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                ),
              ),
              if (_selectedCards.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Found ${_searchResults.length} deck(s)',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Select cards to search for decks',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildDeckCard(_searchResults[index]);
                  },
                ),
        ),
      ],
    );
  }

  void _showCardPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              const Text(
                'Select a card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _allCards.length,
                  itemBuilder: (context, index) {
                    final card = _allCards[index];
                    if (_selectedCards.contains(card.name)) return const SizedBox();
                    
                    return ListTile(
                      title: Text(
                        card.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        card.rarity,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCards.add(card.name);
                          _searchResults = MetaDataService.searchDecksByCards(_selectedCards);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrokenCardsTab() {
    final brokenCards = MetaDataService.getBrokenCards();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: brokenCards.length,
      itemBuilder: (context, index) {
        final card = brokenCards[index];
        return _buildBrokenCardItem(card);
      },
    );
  }

  Widget _buildBrokenCardItem(BrokenCard card) {
    // Find the card in our library
    final cardModel = _allCards.firstWhere(
      (c) => c.name == card.cardName,
      orElse: () => CardModel(
        name: card.cardName,
        level: 14,
        displayLevel: 14,
        rarity: 'common',
        hasEvolution: false,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F2E),
            const Color(0xFF2A1F2E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF44336), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF44336).withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Image
          _buildCardImageFromModel(cardModel),
          const SizedBox(width: 16),
          // Card Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Color(0xFFF44336), size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.cardName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStat('Win', '${card.winRate}%', const Color(0xFFF44336)),
                    const SizedBox(width: 16),
                    _buildStat('Usage', '${card.usageRate}%', Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252D3D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.reason,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
