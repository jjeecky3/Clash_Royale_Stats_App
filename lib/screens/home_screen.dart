import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/feature_card.dart';
import '../widgets/recent_searches_widget.dart';
import 'stats_screen.dart';
import 'track_progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _playerTagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _playerTagController.dispose();
    super.dispose();
  }

  void _searchPlayer() {
    if (_formKey.currentState!.validate()) {
      final playerTag = _playerTagController.text.trim();
      // Navigate to stats screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatsScreen(playerTag: playerTag),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout();
        } else {
          return _buildWebLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚔️',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFD700), // Gold
                  Color(0xFFFFA500), // Orange-gold
                  Color(0xFFFFD700), // Gold
                ],
              ).createShader(bounds),
              child: const Text(
                'Clash Royale Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '⚔️',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF252D3D),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF0F1419),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // Search Section
          Text(
            'Find Player',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _playerTagController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter player tag (e.g. #2PP)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A2BE2)),
                filled: true,
                fillColor: const Color(0xFF252D3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onFieldSubmitted: (_) => _searchPlayer(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a player tag';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _searchPlayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent Searches
          const RecentSearchesWidget(),
          const SizedBox(height: 24),
          // Features Section
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildMobileFeatureItem(
            '📈',
            'View Stats',
            'Win rates, card usage, and battle history',
          ),
          const SizedBox(height: 12),
          _buildMobileFeatureItem(
            '🔥',
            'Get Roasted',
            'Humorous feedback based on performance',
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/deck-builder');
            },
            child: _buildMobileFeatureItem(
              '🃏',
              'Deck Builder',
              'Build and analyze your perfect deck',
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackProgressScreen(),
                ),
              );
            },
            child: _buildMobileFeatureItem(
              '🏆',
              'Track Progress',
              'Monitor trophies and best decks',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFeatureItem(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFeatureCard({
    required String emoji,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 300,
      child: GestureDetector(
        onTap: onTap,
        child: FeatureCard(
          emoji: emoji,
          title: title,
          description: description,
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Stack(
        children: [
          // Animated background
          const Positioned.fill(child: AnimatedBackground()),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Header
                  const SizedBox(height: 48),
                  // Title with gradient and emojis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '⚔️',
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFD700), // Gold
                            Color(0xFFFFA500), // Orange-gold
                            Color(0xFFFFD700), // Gold
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Clash Royale Stats',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '⚔️',
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  const Text(
                    'Get roasted based on your performance! 🔥',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFBFBFBF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Search card with rainbow border
                  Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8A2BE2),
                          Color(0xFF4A90E2),
                          Color(0xFF00CED1),
                          Color(0xFFFFD700),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A2BE2).withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252D3D),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _playerTagController,
                                style: const TextStyle(
                                  color: Color(0xFFF2F2F2),
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your player tag...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF8C8C8C),
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.4),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8A2BE2),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a player tag';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _searchPlayer(),
                              ),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: _searchPlayer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 24,
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ).copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8A2BE2),
                                      Color(0xFF4A90E2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  child: const Text(
                                    'Search',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Recent Searches
                  Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: const RecentSearchesWidget(),
                  ),
                  const SizedBox(height: 48),
                  // Feature cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: [
                          const SizedBox(
                            width: 300,
                            child: FeatureCard(
                              emoji: '📈',
                              title: 'View your win rates\n& card usage',
                              description:
                                  'Comprehensive analysis of your battle performance',
                            ),
                          ),
                          const SizedBox(
                            width: 300,
                            child: FeatureCard(
                              emoji: '🔥',
                              title: 'Get personalized\nroasts & analysis',
                              description: 'Humorous feedback based on your stats',
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/deck-builder');
                              },
                              child: const FeatureCard(
                                emoji: '🃏',
                                title: 'Build & analyze\nyour deck',
                                description: 'Create the perfect deck with AI insights',
                              ),
                            ),
                          ),
                          _buildWebFeatureCard(
                            emoji: '🏆',
                            title: 'Track trophy\nprogress & best decks',
                            description: 'Monitor your climbing journey',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TrackProgressScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
