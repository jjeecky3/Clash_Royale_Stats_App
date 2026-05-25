import 'package:flutter/material.dart';
import '../models/battle_history_item.dart';
import '../utils/image_helper.dart';
import '../screens/battle_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class BattleHistoryWidget extends StatelessWidget {
  final List<BattleHistoryItem> battles;

  const BattleHistoryWidget({
    super.key,
    required this.battles,
  });

  @override
  Widget build(BuildContext context) {
    if (battles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚔️ Battle History',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF2F2F2),
          ),
        ),
        const SizedBox(height: 16),
        ...battles.take(10).map((battle) => _buildBattleCard(context, battle)),
      ],
    );
  }

  Widget _buildBattleCard(BuildContext context, BattleHistoryItem battle) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BattleDetailScreen(battle: battle),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252D3D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: battle.isVictory
                ? const Color(0xFF4CAF50).withOpacity(0.5)
                : battle.isDraw
                    ? Colors.orange.withOpacity(0.5)
                    : const Color(0xFFF44336).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Result, Time, Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Result badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: battle.isVictory
                        ? const Color(0xFF4CAF50)
                        : battle.isDraw
                            ? Colors.orange
                            : const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        battle.isVictory
                            ? '🏆 VICTORY'
                            : battle.isDraw
                                ? '🤝 DRAW'
                                : '💀 DEFEAT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${battle.teamCrowns} - ${battle.opponentCrowns}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trophy change
                if (battle.trophyChange != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: battle.trophyChange > 0
                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                          : const Color(0xFFF44336).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          battle.trophyChange > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: battle.trophyChange > 0
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${battle.trophyChange.abs()}',
                          style: TextStyle(
                            color: battle.trophyChange > 0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Battle info
            Row(
              children: [
                Text(
                  '${battle.gameModeName} • ${battle.arenaName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(battle.battleTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Opponent info
            Row(
              children: [
                const Text(
                  'vs ',
                  style: TextStyle(
                    color: Color(0xFF8C8C8C),
                    fontSize: 14,
                  ),
                ),
                Text(
                  battle.opponentName,
                  style: const TextStyle(
                    color: Color(0xFFF2F2F2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (battle.opponentClanName != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '[${battle.opponentClanName}]',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Decks preview (first 4 cards from each)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Deck',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: battle.teamDeck.take(4).map((card) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _buildMiniCard(card),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opponent Deck',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: battle.opponentDeck.take(4).map((card) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _buildMiniCard(card),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 14,
                  color: Colors.white.withOpacity(0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap for details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(dynamic card) {
    String? imageUrl;
    if (card.iconUrls != null && card.iconUrls!.containsKey('medium')) {
      imageUrl = card.iconUrls!['medium'];
    }

    return Container(
      width: 32,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Card image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl.startsWith('assets/')
                  ? Image.asset(
                      imageUrl,
                      width: 32,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, size: 16, color: Colors.grey),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 32,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
            )
          else
            const Icon(Icons.image, size: 20, color: Colors.grey),
          
          // EVO badge (top-right corner)
          if (card.isEvolved)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0), // Purple for EVO
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'EVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // HERO badge (top-right corner)
          if (card.isHero)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'HERO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
