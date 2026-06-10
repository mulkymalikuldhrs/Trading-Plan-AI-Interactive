import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final String currentMood;
  final Function(String) onMoodChanged;

  const MoodSelector({super.key, required this.currentMood, required this.onMoodChanged});

  final List<Map<String, dynamic>> moods = const [
    {'label': 'Zen', 'emoji': '🧘‍♂️', 'color': Colors.green},
    {'label': 'Neutral', 'emoji': '😐', 'color': Colors.blue},
    {'label': 'Anxious', 'emoji': '😰', 'color': Colors.orange},
    {'label': 'Greedy', 'emoji': '🤑', 'color': Colors.amber},
    {'label': 'Angry', 'emoji': '😡', 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("How are you feeling?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: currentMood,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.blueGrey[900]?.withValues(alpha: 0.3),
          ),
          items: moods.map((m) {
            return DropdownMenuItem<String>(
              value: m['label'],
              child: Row(
                children: [
                  Text(m['emoji']),
                  const SizedBox(width: 10),
                  Text(m['label'], style: TextStyle(color: m['color'])),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => onMoodChanged(val!),
        ),
      ],
    );
  }
}
