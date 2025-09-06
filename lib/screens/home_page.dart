import 'package:flutter/material.dart';
import 'game_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // match GamePage/TunerPage
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // icon
              const Icon(Icons.music_note, size: 120, color: Colors.blue),
              const SizedBox(height: 24),

              // title
              const Text(
                'Fretboard Memorizer',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // subtitle
              const Text(
                'Train your ears and fingers',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // Start button (blue background, white text)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text('Start Game', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GamePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
