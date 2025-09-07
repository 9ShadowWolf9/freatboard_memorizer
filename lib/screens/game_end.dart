import 'package:flutter/material.dart';
import 'game_page.dart';

class EndGamePage extends StatelessWidget {
  const EndGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉 Congratulations!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "You scored 10/10!",
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 40),

              // Replay button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const GamePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: const Text("Replay"),
              ),
              const SizedBox(height: 20),

              // Home button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
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
