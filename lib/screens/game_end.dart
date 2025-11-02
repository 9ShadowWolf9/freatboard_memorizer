import 'package:flutter/material.dart';
import '../models/account.dart';

class EndGamePage extends StatefulWidget {
  final int finalScore;
  final int maxScore;

  const EndGamePage({
    super.key,
    required this.finalScore,
    required this.maxScore,
  });

  @override
  State<EndGamePage> createState() => _EndGamePageState();
}

class _EndGamePageState extends State<EndGamePage> {
  late Future<void> _updateStatsFuture;

  @override
  void initState() {
    super.initState();
    _updateStatsFuture = _updateAccountStats();
  }

  Future<void> _updateAccountStats() async {
    final account = await Account.load();
    account.updateStats(widget.finalScore);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🎉 Congratulations!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "You scored ${widget.finalScore}/${widget.maxScore}!",
                style: TextStyle(
                  fontSize: 22,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: const Text("Replay"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: const Text("Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
