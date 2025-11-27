import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? subtext;
  final Color? valueColor;
  final double? progressValue; // 0.0 to 1.0
  final bool isGood;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtext,
    this.valueColor,
    this.progressValue,
    this.isGood = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF252D3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF283250).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFBFBFBF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? const Color(0xFFFFD700),
                    fontSize: 35,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                if (progressValue != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGood ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
                if (subtext != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtext!,
                    style: const TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
