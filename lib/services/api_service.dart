import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/player_data.dart';
import '../utils/card_level_converter.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String apiToken = AppConfig.apiToken;
  
  // Use localhost proxy for web, direct API for mobile
  final String proxyUrl = 'http://localhost:3000/api';

  /// Fetch player data from Clash Royale API
  Future<PlayerData> fetchPlayerData(String playerTag) async {
    final formattedTag = CardLevelConverter.formatPlayerTag(playerTag);
    
    try {
      // On web: use local proxy server to avoid CORS
      // On mobile: call API directly
      final Uri profileUri;
      final Map<String, String> headers;
      
      if (kIsWeb) {
        // Remove # from tag for URL
        final tagWithoutHash = formattedTag.replaceAll('#', '');
        profileUri = Uri.parse('$proxyUrl/player/$tagWithoutHash');
        headers = {'Accept': 'application/json'};
      } else {
        profileUri = Uri.https(
          'api.clashroyale.com',
          '/v1/players/$formattedTag',
        );
        headers = {
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json',
        };
      }

      final profileResponse = await http.get(profileUri, headers: headers);

      if (profileResponse.statusCode != 200) {
        throw ApiException(
          statusCode: profileResponse.statusCode,
          message: _getErrorMessage(profileResponse.statusCode),
        );
      }

      final playerData = json.decode(profileResponse.body);
      
      // Fetch battle log from separate endpoint
      final battleLogUri = Uri.parse('$baseUrl/players/${Uri.encodeComponent(playerTag)}/battlelog');
      final battleLogResponse = await http.get(battleLogUri, headers: headers);
      
      if (battleLogResponse.statusCode == 200) {
        final battleLogData = json.decode(battleLogResponse.body) as List<dynamic>;
        playerData['battleLog'] = battleLogData;
      } else {
        // If battle log fetch fails, just use empty list
        playerData['battleLog'] = [];
      }
      
      return PlayerData.fromJson(playerData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 0,
        message: 'Error fetching data: ${e.toString()}',
      );
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 403:
        return 'Invalid API token or access forbidden. Please check your configuration.';
      case 404:
        return 'Player not found. Please check the player tag.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      case 429:
        return 'Rate limit exceeded. Please wait a moment before trying again.';
      default:
        return 'Error: $statusCode - An unexpected error occurred.';
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
