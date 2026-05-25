import 'package:flutter/material.dart';
import '../models/search_history_item.dart';
import '../services/search_history_service.dart';
import '../screens/stats_screen.dart';

class RecentSearchesWidget extends StatefulWidget {
  const RecentSearchesWidget({super.key});

  @override
  State<RecentSearchesWidget> createState() => _RecentSearchesWidgetState();
}

class _RecentSearchesWidgetState extends State<RecentSearchesWidget> {
  final SearchHistoryService _historyService = SearchHistoryService();
  int _refreshKey = 0;

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();
    setState(() {
      _refreshKey++; // Force refresh
    });
  }

  void _navigateToPlayer(String playerTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsScreen(playerTag: playerTag),
      ),
    ).then((_) {
      // Refresh when coming back
      setState(() {
        _refreshKey++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchHistoryItem>>(
      key: ValueKey(_refreshKey),
      future: _historyService.getSearchHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🕒 Recent Searches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFF44336)),
                  label: const Text(
                    'Clear',
                    style: TextStyle(color: Color(0xFFF44336)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = history[index];
                return InkWell(
                  onTap: () => _navigateToPlayer(item.playerTag),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252D3D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF8A2BE2),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.playerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.playerTag,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.3),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
