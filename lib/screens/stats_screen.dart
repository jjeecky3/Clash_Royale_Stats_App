import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/player_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/roast_card.dart';
import '../widgets/deck_card.dart';
import '../widgets/battle_history_widget.dart';
import '../utils/image_helper.dart';
import 'stats_screen_battle_card.dart';

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
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 4),
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
                      const SizedBox(height: 4),
                      // EXP and Star Points
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeaderStat('✨', '${stats.starPoints}'),
                          const SizedBox(width: 8),
                          _buildHeaderStat('📈', '${(stats.totalExpPoints / 1000).toStringAsFixed(1)}k XP'),
                        ],
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
                    subtext: 'Avg: Lvl ${stats.avgCardLevel.toStringAsFixed(1)}',
                  ),
                  if (stats.favoriteCard != null)
                    StatCard(
                      icon: '❤️',
                      label: 'Favorite Card',
                      value: stats.favoriteCard!.name,
                      subtext: _capitalize(stats.favoriteCard!.rarity),
                    ),
                  if (stats.currentStreak > 0)
                    StatCard(
                      icon: stats.streakType == 'win' ? '🔥' : '💀',
                      label: '${_capitalize(stats.streakType)} Streak',
                      value: '${stats.currentStreak}',
                      valueColor: stats.streakType == 'win'
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                      subtext: stats.streakType == 'win' ? 'On fire!' : 'Keep trying!',
                    ),
                  StatCard(
                    icon: '👑',
                    label: '3-Crown Rate',
                    value: '${stats.threeCrownRate.toStringAsFixed(1)}%',
                    subtext: '${stats.threeCrownWins} total',
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
                Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: roasts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final roast = entry.value;
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 16),
                            child: RoastCard(
                              text: roast.text,
                              emoteAsset: roast.emote,
                              index: index,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Scroll indicator
                    if (roasts.length > 1)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF0F1419).withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              // Deck Section
              if (stats.currentDeck.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎴 Current Deck',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC92C9D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Avg: ${stats.avgElixirCost}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
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
                    // Scroll indicator
                    if (stats.currentDeck.length > 3)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0F1419).withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              // Battle History Section
              if (stats.battleHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  '⚔️ Battle History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...stats.battleHistory.take(5).map((battle) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: BattleCardHelper.buildMobileBattleCard(context, battle),
                  );
                }),
              ],
              // Summary Section
              const SizedBox(height: 24),
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
                      'Overall Record',
                      'You\'ve played ${stats.totalBattles} battles with ${stats.wins} wins and ${stats.losses} losses, giving you a win rate of ${stats.winRate.toStringAsFixed(1)}%. ' +
                          (stats.winRate >= 55
                              ? 'That\'s pretty solid! Keep crushing it! 💪'
                              : stats.winRate >= 50
                                  ? 'You\'re holding your own! Not bad at all. 👍'
                                  : 'There\'s room for improvement, but everyone starts somewhere! Keep practicing! 🎯'),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                      'Recent Performance',
                      stats.recentBattles > 0
                          ? 'In your last ${stats.recentBattles} games, you\'ve won ${stats.recentWins} and lost ${stats.recentLosses}, giving you a recent win rate of ${stats.recentWinRate.toStringAsFixed(1)}%. ' +
                              (stats.recentWinRate > stats.winRate
                                  ? 'You\'re on an upward trend! 📈'
                                  : stats.recentWinRate < stats.winRate
                                      ? 'Your recent performance is below your average. Time to bounce back! 💪'
                                      : 'You\'re maintaining your average performance. 👌')
                          : 'No recent battle data available. Play some games to see your recent performance!',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                      'Trophy Progress',
                      'Current: ${stats.trophies} 🏆 | Best: ${stats.bestTrophies} 🏆 ' +
                          (stats.trophies == stats.bestTrophies
                              ? '\nYou\'re at your peak! Amazing! 🎉'
                              : '\nYou\'re ${stats.bestTrophies - stats.trophies} trophies away from your personal best. Keep pushing!'),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                      'Three Crown Dominance',
                      'You\'ve achieved ${stats.threeCrownWins} three crown victories out of ${stats.wins} total wins (${stats.threeCrownRate.toStringAsFixed(1)}%). ' +
                          (stats.threeCrownRate >= 30
                              ? 'You\'re absolutely crushing your opponents! 👑'
                              : stats.threeCrownRate >= 20
                                  ? 'Solid three crown rate! 💪'
                                  : 'Try to be more aggressive to get more three crowns! ⚔️'),
                    ),
                    if (stats.currentStreak > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryItem(
                        'Current Streak',
                        'You\'re on a ${stats.currentStreak} ${stats.streakType} streak! ' +
                            (stats.streakType == 'win'
                                ? 'Keep the momentum going! 🔥'
                                : 'Don\'t give up! Every loss is a learning opportunity. 💪'),
                      ),
                    ],
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

  Widget _buildHeaderStat(String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
                const SizedBox(height: 16),
                // Extra Profile Stats (Web)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildWebProfileStat('✨ Star Points', '${stats.starPoints}'),
                      const SizedBox(width: 24),
                      _buildWebProfileStat('📈 Total EXP', '${stats.totalExpPoints}'),
                    ],
                  ),
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
                    if (stats.favoriteCard != null)
                      SizedBox(
                        width: constraints.maxWidth > 800
                            ? (constraints.maxWidth - 40) / 2
                            : constraints.maxWidth,
                        child: StatCard(
                          icon: '❤️',
                          label: 'Favorite Card',
                          value: stats.favoriteCard!.name,
                          subtext: 'Level ${stats.favoriteCard!.displayLevel}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🎴 Current Deck',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF2F2F2),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC92C9D),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC92C9D).withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Average Elixir: ${stats.avgElixirCost}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                // Battle History Section
                if (stats.battleHistory.isNotEmpty) ...[
                  const SizedBox(height: 48),
                  BattleHistoryWidget(battles: stats.battleHistory),
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

  Widget _buildWebProfileStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
