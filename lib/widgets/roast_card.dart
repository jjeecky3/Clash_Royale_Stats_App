import 'package:flutter/material.dart';

class RoastCard extends StatelessWidget {
  final String text;
  final String emoteAsset;
  final int index;

  const RoastCard({
    super.key,
    required this.text,
    required this.emoteAsset,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(
              color: Color(0xFFFF8C00),
              width: 6,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emote image
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/emotes/$emoteAsset',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('😭', style: TextStyle(fontSize: 60));
                },
              ),
            ),
            const SizedBox(width: 20),
            // Roast text
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFF2F2F2),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
