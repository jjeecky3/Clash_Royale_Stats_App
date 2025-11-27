import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/card.dart';
import '../utils/image_helper.dart';

class DeckCard extends StatelessWidget {
  final CardModel card;

  const DeckCard({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (card.hasEvolution &&
        card.iconUrls != null &&
        card.iconUrls!.containsKey('evolutionMedium')) {
      imageUrl = card.iconUrls!['evolutionMedium'];
    } else if (card.iconUrls != null &&
        card.iconUrls!.containsKey('medium')) {
      imageUrl = card.iconUrls!['medium'];
    }

    // Use LayoutBuilder for responsive sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        // More compact for mobile (typically width < 140)
        final bool isMobile = constraints.maxWidth < 140;

        return Container(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFF252D3D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card image
              if (imageUrl != null)
                CachedNetworkImage(
                  imageUrl: ImageHelper.getImageUrl(imageUrl),
                  width: isMobile ? 60 : 90,
                  height: isMobile ? 60 : 90,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => SizedBox(
                    width: isMobile ? 60 : 90,
                    height: isMobile ? 60 : 90,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    size: isMobile ? 60 : 90,
                    color: Colors.grey,
                  ),
                )
              else
                SizedBox(
                  width: isMobile ? 60 : 90,
                  height: isMobile ? 60 : 90,
                  child: Icon(Icons.image, size: isMobile ? 60 : 90, color: Colors.grey),
                ),
              SizedBox(height: isMobile ? 4 : 8),
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
              if (card.hasEvolution)
                Text(
                  '⚡',
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: isMobile ? 12 : 16,
                  ),
                ),
              SizedBox(height: isMobile ? 2 : 4),
              // Card level
              Text(
                'Lv ${card.displayLevel}',
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: isMobile ? 1 : 2),
              // Rarity
              Text(
                _capitalize(card.rarity),
                style: TextStyle(
                  color: const Color(0xFF8C8C8C),
                  fontSize: isMobile ? 9 : 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
