import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_deck.dart';

class DeckStorageService {
  static const String _savedDecksKey = 'saved_decks';
  static const int maxSavedDecks = 3;

  // Save a deck
  Future<bool> saveDeck(SavedDeck deck) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final decks = await getSavedDecks();
      
      // Check if we're at max capacity and this is a new deck
      if (decks.length >= maxSavedDecks && !decks.any((d) => d.id == deck.id)) {
        return false; // Can't save more than max decks
      }
      
      // Remove existing deck with same ID if updating
      decks.removeWhere((d) => d.id == deck.id);
      
      // Add new deck
      decks.add(deck);
      
      // Save to preferences
      final jsonList = decks.map((d) => d.toJson()).toList();
      await prefs.setString(_savedDecksKey, json.encode(jsonList));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all saved decks
  Future<List<SavedDeck>> getSavedDecks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedDecksKey);
      
      if (jsonString == null) return [];
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => SavedDeck.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete a deck
  Future<bool> deleteDeck(String deckId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final decks = await getSavedDecks();
      
      decks.removeWhere((d) => d.id == deckId);
      
      final jsonList = decks.map((d) => d.toJson()).toList();
      await prefs.setString(_savedDecksKey, json.encode(jsonList));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if can save more decks
  Future<bool> canSaveMoreDecks() async {
    final decks = await getSavedDecks();
    return decks.length < maxSavedDecks;
  }
}
