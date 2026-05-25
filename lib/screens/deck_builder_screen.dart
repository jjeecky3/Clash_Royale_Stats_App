import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/deck_analysis.dart';
import '../models/saved_deck.dart';
import '../services/card_library_service.dart';
import '../services/deck_analyzer_service.dart';
import '../services/deck_storage_service.dart';
import '../widgets/deck_card.dart';
import '../utils/image_helper.dart';
import '../config/deck_building_rules.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  final CardLibraryService _cardLibrary = CardLibraryService();
  final DeckAnalyzerService _analyzer = DeckAnalyzerService();
  final DeckStorageService _deckStorage = DeckStorageService();
  
  List<CardModel> _allCards = [];
  List<CardModel> _filteredCards = [];
  List<CardModel?> _currentDeck = List.filled(8, null);
  DeckAnalysis _analysis = DeckAnalysis.empty();
  List<SavedDeck> _savedDecks = [];
  
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRarity = 'All';
  int _selectedElixir = -1;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _loadSavedDecks();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final cards = await _cardLibrary.fetchAllCards();
      setState(() {
        _allCards = cards;
        _filteredCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load cards: $e')),
        );
      }
    }
  }

  void _filterCards() {
    setState(() {
      _filteredCards = _cardLibrary.filterCards(
        cards: _allCards,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        rarity: _selectedRarity == 'All' ? null : _selectedRarity,
        elixirCost: _selectedElixir == -1 ? null : _selectedElixir,
      );
    });
  }

  void _addCardToDeck(CardModel card) {
    // Check if card already in deck
    if (_currentDeck.any((c) => c?.name == card.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card already in deck!')),
      );
      return;
    }

    // Validate card addition using DeckBuildingRules
    final nonNullDeck = _currentDeck.whereType<CardModel>().toList();
    final validationError = DeckBuildingRules.validateCardAddition(card, nonNullDeck);
    
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: const Color(0xFFF44336),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Find first empty slot
    final emptyIndex = _currentDeck.indexWhere((c) => c == null);
    if (emptyIndex != -1) {
      setState(() {
        _currentDeck[emptyIndex] = card;
        
        // Apply deck ordering
        final orderedCards = DeckBuildingRules.orderDeckCards(_currentDeck.whereType<CardModel>().toList());
        _currentDeck = List<CardModel?>.filled(8, null);
        for (int i = 0; i < orderedCards.length; i++) {
          _currentDeck[i] = orderedCards[i];
        }
        
        _analyzeDeck();
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${card.name} added to deck'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck is full! Remove a card first.')),
      );
    }
  }

  void _removeCardFromDeck(int index) {
    setState(() {
      _currentDeck[index] = null;
      
      // Re-order remaining cards
      final orderedCards = DeckBuildingRules.orderDeckCards(_currentDeck.whereType<CardModel>().toList());
      _currentDeck = List<CardModel?>.filled(8, null);
      for (int i = 0; i < orderedCards.length; i++) {
        _currentDeck[i] = orderedCards[i];
      }
      
      _analyzeDeck();
    });
  }

  void _analyzeDeck() {
    final deck = _currentDeck.whereType<CardModel>().toList();
    setState(() {
      _analysis = _analyzer.analyzeDeck(deck);
    });
  }

  void _clearDeck() {
    setState(() {
      _currentDeck = List.filled(8, null);
      _analysis = DeckAnalysis.empty();
    });
  }

  Future<void> _loadSavedDecks() async {
    final decks = await _deckStorage.getSavedDecks();
    setState(() {
      _savedDecks = decks;
    });
  }

  Future<void> _saveDeck() async {
    final deck = _currentDeck.whereType<CardModel>().toList();
    if (deck.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete your deck (8 cards) before saving!')),
      );
      return;
    }

    // Check if can save more decks
    final canSave = await _deckStorage.canSaveMoreDecks();
    if (!canSave && _savedDecks.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 decks allowed. Delete a deck to save a new one.')),
      );
      return;
    }

    // Show dialog to name the deck
    final TextEditingController nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252D3D),
        title: const Text('Save Deck', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter deck name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    final savedDeck = SavedDeck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      cardNames: deck.map((c) => c.name).toList(),
      isEvolvedFlags: deck.map((c) => c.isEvolved).toList(),
      isHeroFlags: deck.map((c) => c.isHero).toList(),
      savedAt: DateTime.now(),
    );

    final success = await _deckStorage.saveDeck(savedDeck);
    if (success) {
      await _loadSavedDecks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Deck "$name" saved!')),
        );
      }
    }
  }

  Future<void> _loadDeck(SavedDeck savedDeck) async {
    // Find cards by name, evolved status, and hero status
    final List<CardModel?> loadedDeck = [];
    
    for (int i = 0; i < savedDeck.cardNames.length; i++) {
      final cardName = savedDeck.cardNames[i];
      final isEvolved = savedDeck.isEvolvedFlags[i];
      final isHero = i < savedDeck.isHeroFlags.length ? savedDeck.isHeroFlags[i] : false;
      
      final card = _allCards.firstWhere(
        (c) => c.name == cardName && c.isEvolved == isEvolved && c.isHero == isHero,
        orElse: () => _allCards.firstWhere(
          (c) => c.name == cardName,
          orElse: () => CardModel(
            name: cardName,
            level: 14,
            displayLevel: 14,
            rarity: 'common',
            hasEvolution: false,
          ),
        ),
      );
      
      loadedDeck.add(card);
    }
    
    // Fill remaining slots with null
    while (loadedDeck.length < 8) {
      loadedDeck.add(null);
    }
    
    setState(() {
      _currentDeck = loadedDeck;
      _analyzeDeck();
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Loaded deck "${savedDeck.name}"')),
      );
    }
  }

  Future<void> _showSavedDecks() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252D3D),
        title: Text('Saved Decks (${_savedDecks.length}/3)', 
          style: const TextStyle(color: Colors.white)),
        content: _savedDecks.isEmpty
            ? const Text('No saved decks yet', style: TextStyle(color: Colors.white54))
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _savedDecks.length,
                  itemBuilder: (context, index) {
                    final deck = _savedDecks[index];
                    return ListTile(
                      title: Text(deck.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${deck.cardNames.length} cards',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deckStorage.deleteDeck(deck.id);
                          await _loadSavedDecks();
                          Navigator.pop(context);
                          _showSavedDecks();
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _loadDeck(deck);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        return isMobile ? _buildMobileLayout() : _buildWebLayout();
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        backgroundColor: const Color(0xFF252D3D),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showSavedDecks,
            tooltip: 'Load Deck',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDeck,
            tooltip: 'Save Deck',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearDeck,
            tooltip: 'Clear Deck',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F1419),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Deck
            _buildDeckSection(),
            const Divider(color: Colors.white24, height: 1),
            // Analysis
            if (_currentDeck.whereType<CardModel>().length == 8)
              _buildAnalysisSection(),
            if (_currentDeck.whereType<CardModel>().length == 8)
              const Divider(color: Colors.white24, height: 1),
            // Card Library
            SizedBox(
              height: 600, // Fixed height for card library
              child: _buildCardLibrary(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        backgroundColor: const Color(0xFF252D3D),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showSavedDecks,
            tooltip: 'Load Deck',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDeck,
            tooltip: 'Save Deck',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearDeck,
            tooltip: 'Clear Deck',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F1419),
      body: Row(
        children: [
          // Card Library (left side)
          Expanded(
            flex: 2,
            child: _buildCardLibrary(),
          ),
          // Deck and Analysis (right side)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildDeckSection(),
                const Divider(color: Colors.white24, height: 1),
                Expanded(child: _buildAnalysisSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Deck',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_currentDeck.whereType<CardModel>().length}/8',
                style: TextStyle(
                  fontSize: 16,
                  color: _currentDeck.whereType<CardModel>().length == 8
                      ? const Color(0xFF4CAF50)
                      : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.6, // Balanced ratio for card display
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final card = _currentDeck[index];
              return GestureDetector(
                onTap: card != null ? () => _removeCardFromDeck(index) : null,
                child: card != null
                    ? Stack(
                        children: [
                          DeckCard(card: card),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF252D3D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white24,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 32,
                            color: Colors.white24,
                          ),
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    if (_currentDeck.whereType<CardModel>().length < 8) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Add 8 cards to analyze your deck',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deck Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Meta Rating
          _buildAnalysisCard(
            '⭐ Meta Rating',
            '${_analysis.metaRating}/10',
            _getMetaRatingColor(_analysis.metaRating),
          ),
          const SizedBox(height: 12),
          
          // Archetype
          _buildAnalysisCard(
            '🎯 Archetype',
            _analysis.deckArchetype,
            const Color(0xFF8A2BE2),
          ),
          const SizedBox(height: 12),
          
          // Average Elixir
          _buildAnalysisCard(
            '💧 Avg Elixir',
            _analysis.avgElixirCost.toStringAsFixed(1),
            const Color(0xFFC92C9D),
          ),
          const SizedBox(height: 16),
          
          // Win Conditions
          if (_analysis.winConditions.isNotEmpty) ...[
            _buildListSection('🏆 Win Conditions', _analysis.winConditions, const Color(0xFF4CAF50)),
            const SizedBox(height: 16),
          ],
          
          // Synergies
          if (_analysis.synergies.isNotEmpty) ...[
            _buildListSection('✨ Synergies', _analysis.synergies, const Color(0xFF00CED1)),
            const SizedBox(height: 16),
          ],
          
          // Weaknesses
          if (_analysis.weaknesses.isNotEmpty) ...[
            _buildListSection('⚠️ Weaknesses', _analysis.weaknesses, const Color(0xFFF44336)),
            const SizedBox(height: 16),
          ],
          
          // Recommendations
          if (_analysis.recommendations.isNotEmpty) ...[
            _buildListSection('💡 Recommendations', _analysis.recommendations, const Color(0xFFFFD700)),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getMetaRatingColor(int rating) {
    if (rating >= 8) return const Color(0xFF4CAF50);
    if (rating >= 6) return const Color(0xFFFFD700);
    if (rating >= 4) return const Color(0xFFFFA500);
    return const Color(0xFFF44336);
  }

  Widget _buildCardLibrary() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF252D3D),
          child: Column(
            children: [
              // Search
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search cards...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8A2BE2)),
                  filled: true,
                  fillColor: const Color(0xFF0F1419),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterCards();
                },
              ),
              const SizedBox(height: 12),
              // Rarity and Elixir filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRarity,
                      dropdownColor: const Color(0xFF252D3D),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F1419),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['All', 'Common', 'Rare', 'Epic', 'Legendary', 'Champion', 'Evolution', 'Hero']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedRarity = value!);
                        _filterCards();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedElixir,
                      dropdownColor: const Color(0xFF252D3D),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F1419),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: -1, child: Text('All Elixir')),
                        ...List.generate(10, (i) => i + 1)
                            .map((e) => DropdownMenuItem(value: e, child: Text('$e Elixir')))
                      ],
                      onChanged: (value) {
                        setState(() => _selectedElixir = value!);
                        _filterCards();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Card Grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.66, // Further reduced to eliminate all overflow
                  ),
                  itemCount: _filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = _filteredCards[index];
                    final isInDeck = _currentDeck.any((c) => c?.name == card.name);
                    
                    return GestureDetector(
                      onTap: () => _addCardToDeck(card),
                      child: Opacity(
                        opacity: isInDeck ? 0.5 : 1.0,
                        child: DeckCard(card: card),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
