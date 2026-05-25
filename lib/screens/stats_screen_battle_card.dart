import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/battle_history_item.dart';
import '../utils/image_helper.dart';
import 'battle_detail_screen.dart';

class BattleCardHelper {
  static Widget buildMobileBattleCard(BuildContext context, BattleHistoryItem battle) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BattleDetailScreen(battle: battle),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF252D3D),
          borderRadius: BorderRadius.circular(12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Result
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: battle.isVictory
                        ? const Color(0xFF4CAF50)
                        : battle.isDraw
                            ? Colors.orange
                            : const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    battle.isVictory
                        ? '🏆 ${battle.teamCrowns}-${battle.opponentCrowns}'
                        : battle.isDraw
                            ? '🤝 ${battle.teamCrowns}-${battle.opponentCrowns}'
                            : '💀 ${battle.teamCrowns}-${battle.opponentCrowns}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Trophy change
                if (battle.trophyChange != 0)
                  Row(
                    children: [
                      Icon(
                        battle.trophyChange > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: battle.trophyChange > 0
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        size: 14,
                      ),
                      Text(
                        '${battle.trophyChange.abs()}',
                        style: TextStyle(
                          color: battle.trophyChange > 0
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'vs ${battle.opponentName}',
              style: const TextStyle(
                color: Color(0xFFF2F2F2),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${battle.gameModeName} • ${_formatTime(battle.battleTime)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
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
