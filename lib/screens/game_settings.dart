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
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                "Select number of rounds",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _selectedRounds.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                label: "$_selectedRounds",
                activeColor: accent,
                onChanged: (value) {
                  setState(() => _selectedRounds = value.toInt());
                },
              ),
              Text(
                "$_selectedRounds rounds",
                style: TextStyle(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Select strings to practice",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: Note.strings.map((string) {
                  final selected = _selectedStrings.contains(string);
                  return FilterChip(
                    label: Text(string),
                    selected: selected,
                    selectedColor: accent.withOpacity(0.2),
                    checkmarkColor: accent,
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
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
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
