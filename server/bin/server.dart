import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:dotenv/dotenv.dart';
import '../lib/api_proxy.dart';

void main() async {
  // Load environment variables
  final env = DotEnv();
  try {
    env.load(['../assets/.env']);
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    print('Make sure CLASH_ROYALE_API_TOKEN is set in environment');
  }

  final apiToken = env['CLASH_ROYALE_API_TOKEN'] ?? 
                   Platform.environment['CLASH_ROYALE_API_TOKEN'] ?? '';

  if (apiToken.isEmpty) {
    print('ERROR: CLASH_ROYALE_API_TOKEN not found!');
    print('Please set it in assets/.env or as an environment variable');
    exit(1);
  }

  // Create API proxy
  final apiProxy = ApiProxy(apiToken);

  // Create pipeline with CORS middleware
  final handler = Pipeline()
      .addMiddleware(_corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(apiProxy.router.call);

  // Start server
  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    3000,
  );

  print('🚀 Clash Royale API Proxy Server running on http://localhost:${server.port}');
  print('📡 Forwarding requests to Clash Royale API');
  print('Press Ctrl+C to stop');
}

Middleware _corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Handle OPTIONS preflight requests
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }

      // Process request and add CORS headers to response
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    };
  };
}
