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

    return Container(
      padding: const EdgeInsets.all(12),
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
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox(
                width: 90,
                height: 90,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                size: 90,
                color: Colors.grey,
              ),
            )
          else
            const SizedBox(
              width: 90,
              height: 90,
              child: Icon(Icons.image, size: 90, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          // Card name
          Text(
            card.name,
            style: const TextStyle(
              color: Color(0xFFF2F2F2),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (card.hasEvolution)
            const Text(
              '⚡',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 4),
          // Card level
          Text(
            'Lv ${card.displayLevel}',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          // Rarity
          Text(
            _capitalize(card.rarity),
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
