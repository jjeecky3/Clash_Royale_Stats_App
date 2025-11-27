import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/player_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/roast_card.dart';
import '../widgets/deck_card.dart';
import '../utils/image_helper.dart';

class StatsScreen extends StatefulWidget {
  final String playerTag;

  const StatsScreen({super.key, required this.playerTag});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch player stats on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().fetchPlayerStats(widget.playerTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          if (provider.state == PlayerState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A2BE2)),
              ),
            );
          }

          if (provider.state == PlayerState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '😭',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      provider.errorMessage,
                      style: const TextStyle(
                        color: Color(0xFFF44336),
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: const Color(0xFF8A2BE2),
                      ),
                      child: const Text(
                        '← Back to Search',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.state != PlayerState.loaded || provider.stats == null) {
            return const SizedBox();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildMobileLayout(context, provider);
              } else {
                return _buildWebLayout(context, provider, constraints);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, PlayerProvider provider) {
    final stats = provider.stats!;
    final roasts = provider.roasts;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF252D3D),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(stats.name),
            background: Stack(
              fit: StackFit.expand,
              children: [
                const AnimatedBackground(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF252D3D).withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: stats.avatarIcon != null
                            ? ImageHelper.getImageProvider(stats.avatarIcon!)
                            : null,
                        backgroundColor: Colors.transparent,
                        child: stats.avatarIcon == null
                            ? const Text('🤴', style: TextStyle(fontSize: 40))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lvl ${stats.kingLevel}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    icon: '🏆',
                    label: 'Trophies',
                    value: stats.trophies.toString(),
                    subtext: 'Best: ${stats.bestTrophies}',
                  ),
                  StatCard(
                    icon: '📊',
                    label: 'Win Rate',
                    value: '${stats.winRate.toStringAsFixed(1)}%',
                    valueColor: stats.winRate >= 50
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    progressValue: stats.winRate / 100,
                    isGood: stats.winRate >= 50,
                  ),
                  StatCard(
                    icon: '⚔️',
                    label: 'Battles',
                    value: stats.totalBattles.toString(),
                    subtext: '${stats.wins}W / ${stats.losses}L',
                  ),
                  StatCard(
                    icon: '🎴',
                    label: 'Cards',
                    value: stats.totalCards.toString(),
                    subtext: 'Avg: ${stats.avgCardLevel.toStringAsFixed(1)}',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Roasts Section
              if (roasts.isNotEmpty) ...[
                Text(
                  '🔥 Roasts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: roasts.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 16),
                        child: RoastCard(
                          text: roasts[index].text,
                          emoteAsset: roasts[index].emote,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Deck Section
              if (stats.currentDeck.isNotEmpty) ...[
                Text(
                  '🎴 Current Deck',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stats.currentDeck.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        child: DeckCard(card: stats.currentDeck[index]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252D3D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(
                      'Win Rate',
                      '${stats.winRate.toStringAsFixed(1)}% (${stats.wins}W - ${stats.losses}L)',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                      'Recent Form',
                      '${stats.recentWinRate.toStringAsFixed(1)}% in last ${stats.recentBattles} games',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(
      BuildContext context, PlayerProvider provider, BoxConstraints constraints) {
    final stats = provider.stats!;
    final roasts = provider.roasts;

    return Stack(
      children: [
        const Positioned.fill(child: AnimatedBackground()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Player header
                PlayerHeader(
                  name: stats.name,
                  tag: stats.tag,
                  kingLevel: stats.kingLevel,
                  avatarUrl: stats.avatarIcon,
                ),
                const SizedBox(height: 32),
                // Stats grid
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth > 800
                          ? (constraints.maxWidth - 40) / 2
                          : constraints.maxWidth,
                      child: StatCard(
                        icon: '🏆',
                        label: 'Trophies',
                        value: stats.trophies.toString(),
                        subtext: 'Best: ${stats.bestTrophies}',
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 800
                          ? (constraints.maxWidth - 40) / 2
                          : constraints.maxWidth,
                      child: StatCard(
                        icon: '📊',
                        label: 'Win Rate',
                        value:
                            '${stats.winRate.toStringAsFixed(1)}% ${stats.winRate >= 50 ? '↑' : '↓'}',
                        valueColor: stats.winRate >= 50
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        progressValue: stats.winRate / 100,
                        isGood: stats.winRate >= 50,
                        subtext:
                            '${stats.winRate.toStringAsFixed(1)}% Win Rate',
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 800
                          ? (constraints.maxWidth - 40) / 2
                          : constraints.maxWidth,
                      child: StatCard(
                        icon: '⚔️',
                        label: 'Battles',
                        value: stats.totalBattles.toString(),
                        subtext: '${stats.wins}W / ${stats.losses}L',
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 800
                          ? (constraints.maxWidth - 40) / 2
                          : constraints.maxWidth,
                      child: StatCard(
                        icon: '👑',
                        label: 'Three Crown Wins',
                        value: stats.threeCrownWins.toString(),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 800
                          ? (constraints.maxWidth - 40) / 2
                          : constraints.maxWidth,
                      child: StatCard(
                        icon: '🎴',
                        label: 'Card Collection',
                        value: stats.totalCards.toString(),
                        subtext:
                            'Avg Level: ${stats.avgCardLevel.toStringAsFixed(1)}',
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 800
                          ? (constraints.maxWidth - 40) / 2
                          : constraints.maxWidth,
                      child: StatCard(
                        icon: stats.recentWinRate >= 50 ? '📈' : '📉',
                        label: 'Recent Performance',
                        value:
                            '${stats.recentWinRate.toStringAsFixed(1)}% ${stats.recentWinRate >= 50 ? '↑' : '↓'}',
                        valueColor: stats.recentWinRate >= 50
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        subtext:
                            '${stats.recentWins}W / ${stats.recentLosses}L (Last ${stats.recentBattles})',
                      ),
                    ),
                  ],
                ),
                if (roasts.isNotEmpty) ...[
                  const SizedBox(height: 48),
                  // Roast section
                  Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252D3D),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFF8C00),
                        width: 3,
                      ),
                    ),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ).createShader(bounds),
                          child: const Text(
                            '🔥 The Roast Zone 🔥',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: roasts.asMap().entries.map((entry) {
                            final index = entry.key;
                            final roast = entry.value;
                            return SizedBox(
                              width: constraints.maxWidth > 800
                                  ? (constraints.maxWidth - 24) / 2
                                  : constraints.maxWidth,
                              child: RoastCard(
                                text: roast.text,
                                emoteAsset: roast.emote,
                                index: index,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                if (stats.currentDeck.isNotEmpty) ...[
                  const SizedBox(height: 48),
                  // Current deck
                  const Text(
                    '🎴 Current Deck',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF2F2F2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: stats.currentDeck.map((card) {
                      return SizedBox(
                        width: 140,
                        child: DeckCard(card: card),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 48),
                // Performance summary
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252D3D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Performance Summary',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF2F2F2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSummaryItem(
                        'Overall Record:',
                        'You\'ve played ${stats.totalBattles} battles with ${stats.wins} wins and ${stats.losses} losses, giving you a win rate of ${stats.winRate.toStringAsFixed(1)}%. ' +
                            (stats.winRate >= 55
                                ? 'That\'s pretty solid! Keep crushing it! 💪'
                                : stats.winRate >= 50
                                    ? 'Not bad, you\'re holding your own out there! 👍'
                                    : 'There\'s definitely room for improvement! 📈'),
                      ),
                      const SizedBox(height: 24),
                      _buildSummaryItem(
                        'Trophy Progress:',
                        'Currently at ${stats.trophies} trophies. Your personal best is ${stats.bestTrophies}. ' +
                            (stats.trophies >= stats.bestTrophies
                                ? 'You\'re at your peak! 🎯'
                                : 'You\'re ${stats.bestTrophies - stats.trophies} trophies away from your best. Time to climb! ⬆️'),
                      ),
                      const SizedBox(height: 24),
                      _buildSummaryItem(
                        'Recent Form:',
                        'In your last ${stats.recentBattles} battles, you\'ve won ${stats.recentWins} and lost ${stats.recentLosses}. ' +
                            (stats.recentWinRate > stats.winRate
                                ? 'You\'re on fire! Your recent form is better than your overall average! 🔥'
                                : stats.recentWinRate < stats.winRate
                                    ? 'Hmm, you\'ve been struggling lately. Maybe time to switch up your deck? 🤔'
                                    : 'You\'re maintaining your usual pace. Consistency is key! ⚖️'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Search again button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Search Another Player'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2BE2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFFBFBFBF),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
