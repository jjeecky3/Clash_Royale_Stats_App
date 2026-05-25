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

    // Proxy for Clash Royale API
    router.get('/api/players/<tag>', (Request request, String tag) async {
      return await _proxyClashRoyaleApi('/players/$tag', request);
    });

    router.get('/api/players/<tag>/battlelog', (Request request, String tag) async {
      return await _proxyClashRoyaleApi('/players/$tag/battlelog', request);
    });

    // Add cards endpoint
    router.get('/api/cards', (Request request) async {
      return await _proxyClashRoyaleApi('/cards', request);
    });

    // Image proxy endpoint
    router.get('/api/image', _handleImageProxy);

    return router;
  }

  Future<Response> _proxyClashRoyaleApi(String endpoint, Request request) async {
    try {
      final uri = Uri.https('api.clashroyale.com', '/v1$endpoint');

      final response = await http.get(
        uri,
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
