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
    // Use LayoutBuilder to responsive sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detect if this is a mobile layout (smaller width)
        final bool isMobile = constraints.maxWidth < 200;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 12 : 20,
          ),
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
                width: isMobile ? 50 : 80,
                height: isMobile ? 50 : 80,
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
                    style: TextStyle(fontSize: isMobile ? 28 : 48),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 20),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: const Color(0xFFBFBFBF),
                        fontSize: isMobile ? 11 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      value,
                      style: TextStyle(
                        color: valueColor ?? const Color(0xFFFFD700),
                        fontSize: isMobile ? 20 : 35,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (progressValue != null) ...[ 
                      SizedBox(height: isMobile ? 4 : 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isGood ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                          ),
                          minHeight: isMobile ? 6 : 10,
                        ),
                      ),
                    ],
                    if (subtext != null) ...[
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        subtext!,
                        style: TextStyle(
                          color: const Color(0xFF8C8C8C),
                          fontSize: isMobile ? 10 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
