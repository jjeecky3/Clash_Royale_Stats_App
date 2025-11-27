import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ApiProxy {
  final String apiToken;
  final String apiBaseUrl = 'https://api.clashroyale.com/v1';

  ApiProxy(this.apiToken);

  Router get router {
    final router = Router();

    // Player stats endpoint
    router.get('/api/player/<tag>', _handlePlayerRequest);
    
    // Battle log endpoint (if needed separately)
    router.get('/api/player/<tag>/battlelog', _handleBattleLogRequest);
    
    // Image proxy endpoint for CDN images
    router.get('/api/image', _handleImageProxy);

    return router;
  }

  Future<Response> _handlePlayerRequest(Request request, String tag) async {
    try {
      // Format player tag (add # if missing)
      final formattedTag = tag.startsWith('#') ? tag : '#$tag';
      
      // Fetch player profile
      final profileUri = Uri.https(
        'api.clashroyale.com',
        '/v1/players/$formattedTag',
      );

      final profileResponse = await http.get(
        profileUri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json',
        },
      );

      if (profileResponse.statusCode != 200) {
        return Response(
          profileResponse.statusCode,
          body: profileResponse.body,
          headers: _corsHeaders(),
        );
      }

      final playerData = json.decode(profileResponse.body);

      // Fetch battle log
      final battleLogUri = Uri.https(
        'api.clashroyale.com',
        '/v1/players/$formattedTag/battlelog',
      );

      final battleLogResponse = await http.get(
        battleLogUri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json',
        },
      );

      if (battleLogResponse.statusCode == 200) {
        playerData['battleLog'] = json.decode(battleLogResponse.body);
      } else {
        playerData['battleLog'] = [];
      }

      return Response.ok(
        json.encode(playerData),
        headers: {
          'Content-Type': 'application/json',
          ..._corsHeaders(),
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _corsHeaders(),
      );
    }
  }

  Future<Response> _handleBattleLogRequest(Request request, String tag) async {
    try {
      final formattedTag = tag.startsWith('#') ? tag : '#$tag';
      
      final battleLogUri = Uri.https(
        'api.clashroyale.com',
        '/v1/players/$formattedTag/battlelog',
      );

      final response = await http.get(
        battleLogUri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json',
        },
      );

      return Response(
        response.statusCode,
        body: response.body,
        headers: {
          'Content-Type': 'application/json',
          ..._corsHeaders(),
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _corsHeaders(),
      );
    }
  }

  Future<Response> _handleImageProxy(Request request) async {
    try {
      // Get the image URL from query parameter
      final imageUrl = request.url.queryParameters['url'];
      
      if (imageUrl == null || imageUrl.isEmpty) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing url parameter'}),
          headers: _corsHeaders(),
        );
      }

      // Fetch the image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        return Response(
          response.statusCode,
          body: response.body,
          headers: _corsHeaders(),
        );
      }

      // Return image with CORS headers
      return Response.ok(
        response.bodyBytes,
        headers: {
          'Content-Type': response.headers['content-type'] ?? 'image/png',
          ..._corsHeaders(),
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: _corsHeaders(),
      );
    }
  }

  Map<String, String> _corsHeaders() {
    return {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };
  }
}
