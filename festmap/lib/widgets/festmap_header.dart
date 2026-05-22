import 'package:flutter/material.dart';

import '../theme/festmap_theme.dart';

class FestMapHeader extends StatelessWidget {
  const FestMapHeader({
    super.key,
    required this.pinCount,
    this.countLabel = 'pins nearby',
  });

  final int pinCount;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xF20A0A0A),
        border: Border(bottom: BorderSide(color: FestMapColors.border)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.music_note,
                color: FestMapColors.primary.withValues(alpha: 0.4),
                size: 32,
              ),
              const Icon(
                Icons.music_note,
                color: FestMapColors.primary,
                size: 28,
              ),
            ],
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineMedium,
              children: const [
                TextSpan(
                  text: 'FEST',
                  style: TextStyle(color: FestMapColors.primary),
                ),
                TextSpan(
                  text: 'MAP',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: FestMapColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$pinCount $countLabel',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
