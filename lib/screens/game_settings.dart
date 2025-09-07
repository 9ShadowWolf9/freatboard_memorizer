import 'package:flutter/material.dart';
import 'game_page.dart';
import '../models/note.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key});

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  int _selectedRounds = 10;
  Set<String> _selectedStrings = Set.from(Note.strings);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Settings"),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "Select number of rounds",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _selectedRounds.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                label: "$_selectedRounds",
                onChanged: (value) {
                  setState(() => _selectedRounds = value.toInt());
                },
              ),
              Text(
                "$_selectedRounds rounds",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 32),
              const Text(
                "Select strings to practice",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: Note.strings.map((string) {
                  final selected = _selectedStrings.contains(string);
                  return FilterChip(
                    label: Text(string),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedStrings.add(string);
                        } else {
                          _selectedStrings.remove(string);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedStrings.isEmpty
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamePage(
                        targetScore: _selectedRounds,
                        selectedStrings: _selectedStrings.toList(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Start Game",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
