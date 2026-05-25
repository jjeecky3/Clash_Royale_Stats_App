import 'package:flutter/material.dart';
import '../models/battle_history_item.dart';
import '../models/card.dart';
import '../utils/image_helper.dart';

class BattleDetailScreen extends StatelessWidget {
  final BattleHistoryItem battle;

  const BattleDetailScreen({
    super.key,
    required this.battle,
  });

  @override
  Widget build(BuildContext context) {
    final isVictory = battle.result == 'victory';
    final isDraw = battle.result == 'draw';
    final resultColor = isVictory
        ? const Color(0xFF4CAF50)
        : isDraw
            ? const Color(0xFFFFA726)
            : const Color(0xFFF44336);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252D3D),
        title: Text(
          battle.gameMode,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Result Header
            _buildResultHeader(resultColor, isVictory, isDraw),
            const SizedBox(height: 24),

            // Battle Info
            _buildBattleInfo(),
            const SizedBox(height: 24),

            // Player Stats
            _buildSectionTitle('Your Performance'),
            const SizedBox(height: 12),
            _buildPlayerStats(),
            const SizedBox(height: 24),

            // Opponent Info
            _buildSectionTitle('Opponent'),
            const SizedBox(height: 12),
            _buildOpponentInfo(),
            const SizedBox(height: 24),

            // Deck Comparison
            _buildSectionTitle('Deck Comparison'),
            const SizedBox(height: 12),
            _buildDeckComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(Color resultColor, bool isVictory, bool isDraw) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            resultColor.withOpacity(0.3),
            resultColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            isVictory ? '🏆 VICTORY' : isDraw ? '🤝 DRAW' : '💀 DEFEAT',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCrownDisplay(battle.playerCrowns, true),
              const SizedBox(width: 32),
              const Text(
                'VS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 32),
              _buildCrownDisplay(battle.opponentCrowns, false),
            ],
          ),
          if (battle.trophyChange != 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: battle.trophyChange > 0
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : const Color(0xFFF44336).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    battle.trophyChange > 0 ? '+' : '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: battle.trophyChange > 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                    ),
                  ),
                  Text(
                    '${battle.trophyChange}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: battle.trophyChange > 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCrownDisplay(int crowns, bool isPlayer) {
    return Column(
      children: [
        Text(
          isPlayer ? 'YOU' : 'OPPONENT',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '👑',
                style: TextStyle(
                  fontSize: 24,
                  color: index < crowns ? null : Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBattleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('⚔️ Game Mode', battle.gameMode),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow('🏟️ Arena', battle.arena),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow('🕐 Time', battle.formattedTime),
        ],
      ),
    );
  }

  Widget _buildPlayerStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildStatRow('💧 Elixir Leaked', '${battle.playerElixirLeaked.toStringAsFixed(1)}'),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow('🏰 King Tower HP', '${battle.playerKingTowerHp}'),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow('🗼 Princess Towers HP', battle.playerPrincessTowersHp.join(', ')),
        ],
      ),
    );
  }

  Widget _buildOpponentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF44336).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (battle.opponentIcon != null)
                CircleAvatar(
                  radius: 24,
                  backgroundImage: ImageHelper.getImageProvider(battle.opponentIcon!),
                  backgroundColor: Colors.transparent,
                )
              else
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white24,
                  child: Text('👤', style: TextStyle(fontSize: 24)),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      battle.opponentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      battle.opponentTag,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lvl ${battle.opponentKingLevel}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow('🏆 Trophies', '${battle.opponentTrophies}'),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow('💧 Elixir Leaked', '${battle.opponentElixirLeaked.toStringAsFixed(1)}'),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow('🏰 King Tower HP', '${battle.opponentKingTowerHp}'),
          const Divider(color: Colors.white24, height: 24),
          _buildStatRow('🗼 Princess Towers HP', battle.opponentPrincessTowersHp.join(', ')),
        ],
      ),
    );
  }

  Widget _buildDeckComparison() {
    final playerAvgElixir = battle.playerDeck.isEmpty
        ? 0.0
        : battle.playerDeck
                .map((c) => c.elixirCost ?? 0)
                .reduce((a, b) => a + b) /
            battle.playerDeck.length;
    final opponentAvgElixir = battle.opponentDeck.isEmpty
        ? 0.0
        : battle.opponentDeck
                .map((c) => c.elixirCost ?? 0)
                .reduce((a, b) => a + b) /
            battle.opponentDeck.length;

    return Column(
      children: [
        // Average Elixir Comparison
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF252D3D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'Your Avg',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '💧 ${playerAvgElixir.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'VS',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              Column(
                children: [
                  const Text(
                    'Opponent Avg',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '💧 ${opponentAvgElixir.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFFF44336),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Your Deck
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF252D3D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Deck',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 12),
              _buildDeckGrid(battle.playerDeck),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Opponent Deck
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF252D3D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF44336).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Opponent Deck',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF44336),
                ),
              ),
              const SizedBox(height: 12),
              _buildDeckGrid(battle.opponentDeck),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeckGrid(List<CardModel> deck) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.5, // Lower ratio = more vertical space
      ),
      itemCount: deck.length,
      itemBuilder: (context, index) {
        return _buildCompactCard(deck[index]);
      },
    );
  }

  // Compact card widget for grid view
  Widget _buildCompactCard(CardModel card) {
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
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getRarityColor(card.rarity).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elixir cost badge
          if (card.elixirCost != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFC92C9D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                '${card.elixirCost}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Card image
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: imageUrl != null
                  ? (imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 20, color: Colors.grey),
                        )
                      : Image(
                          image: ImageHelper.getImageProvider(imageUrl),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 20, color: Colors.grey),
                        ))
                  : const Icon(Icons.image, size: 20, color: Colors.grey),
            ),
          ),
          // Card level
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Lv ${card.level}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF8C8C8C);
      case 'rare':
        return const Color(0xFFFF8C00);
      case 'epic':
        return const Color(0xFFC92C9D);
      case 'legendary':
        return const Color(0xFFFFD700);
      case 'champion':
        return const Color(0xFF00CED1);
      default:
        return const Color(0xFF8C8C8C);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
