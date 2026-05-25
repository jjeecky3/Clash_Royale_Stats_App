import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../utils/image_helper.dart';

class DeckCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DeckCard({
    super.key,
    required this.card,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = card.iconUrls?['medium'];
    
    // Debug: Print card info to see what we're rendering
    print('DeckCard rendering: ${card.name}');
    print('  isEvolved: ${card.isEvolved}');
    print('  isHero: ${card.isHero}');
    print('  rarity: ${card.rarity}');
    print('  imageUrl: $imageUrl');
    print('  iconUrls: ${card.iconUrls}');

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 140;

        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 6 : 10),
            decoration: BoxDecoration(
              color: const Color(0xFF252D3D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRarityColor(card.rarity).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRarityColor(card.rarity).withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main card content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Elixir Cost (Top Left)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (card.elixirCost != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC92C9D),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  size: isMobile ? 9 : 11,
                                  color: Colors.white,
                                ),
                                Text(
                                  '${card.elixirCost}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 9 : 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        const SizedBox.shrink(),
                      ],
                    ),
                    
                    // Card image
                    SizedBox(
                      width: isMobile ? 60 : 80,
                      height: isMobile ? 72 : 96,
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.startsWith('assets/')
                                  ? Image.asset(
                                      imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                        );
                                      },
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: ImageHelper.getImageUrl(imageUrl),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[800],
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                      ),
                                    ),
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                    ),
                    
                    // Star Levels
                    if (card.starLevel != null && card.starLevel! > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            card.starLevel!,
                            (index) => Icon(
                              Icons.star,
                              size: isMobile ? 10 : 14,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ),

                    // Card name
                    Text(
                      card.name,
                      style: TextStyle(
                        color: const Color(0xFFF2F2F2),
                        fontSize: isMobile ? 11 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                  ],
                ),
                
                // EVO badge overlay (top-right)
                if (card.isEvolved)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text(
                        'EVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // HERO badge overlay (top-right)
                if (card.isHero)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Text(
                        'HERO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF8C8C8C); // Gray
      case 'rare':
        return const Color(0xFFFF8C00); // Orange
      case 'epic':
        return const Color(0xFF9C27B0); // Purple
      case 'legendary':
        return const Color(0xFFFFD700); // Gold
      case 'champion':
        return const Color(0xFF00D4FF); // Cyan
      default:
        return const Color(0xFF8C8C8C); // Default Gray
    }
  }
}
