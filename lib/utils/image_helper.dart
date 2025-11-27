import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageHelper {
  /// Get proxied image URL for web, original for mobile
  static String getImageUrl(String originalUrl) {
    if (kIsWeb) {
      // Proxy through local server on web
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'http://localhost:3000/api/image?url=$encodedUrl';
    }
    return originalUrl;
  }

  /// Create CachedNetworkImageProvider with proxy support
  static ImageProvider getImageProvider(String imageUrl) {
    final proxyUrl = getImageUrl(imageUrl);
    
    if (kIsWeb) {
      // On web, use NetworkImage (CachedNetworkImage doesn't work well on web)
      return NetworkImage(proxyUrl);
    }
    
    return CachedNetworkImageProvider(imageUrl);
  }
}
