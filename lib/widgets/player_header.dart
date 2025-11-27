import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_helper.dart';

class PlayerHeader extends StatelessWidget {
  final String name;
  final String tag;
  final int kingLevel;
  final String? avatarUrl;

  const PlayerHeader({
    super.key,
    required this.name,
    required this.tag,
    required this.kingLevel,
    this.avatarUrl,
  });

  @override  
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5A4FCF),
            Color(0xFF4A90E2),
            Color(0xFF5AA0E8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFF5A3B99)],
              ),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFFF8C00),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Level badge at top
                Positioned(
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A3B99),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$kingLevel',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Crown
                const Positioned(
                  top: 20,
                  child: Text('👑', style: TextStyle(fontSize: 20)),
                ),
                // Avatar or emoji
                if (avatarUrl != null)
                  CachedNetworkImage(
                    imageUrl: ImageHelper.getImageUrl(avatarUrl!),
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Text('🤴', style: TextStyle(fontSize: 45)),
                  )
                else
                  const Text('🤴', style: TextStyle(fontSize: 45)),
                // Stars at bottom
                const Positioned(
                  bottom: 14,
                  child: Text('⭐⭐⭐', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD700),
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 4,
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
}
