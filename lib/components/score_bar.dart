import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final int score;
  final int maxScore;

  const ScoreBar({
    Key? key,
    required this.score,
    this.maxScore = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            "Score",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: (score.clamp(0, maxScore)) / maxScore,
                minHeight: 20,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$score/$maxScore",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
