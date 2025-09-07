import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final int score;
  final int maxScore;

  const ScoreBar({Key? key, required this.score, this.maxScore = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text(
            "Score",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: (score.clamp(0, maxScore)) / maxScore,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$score/$maxScore",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
