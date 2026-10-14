import 'package:flutter/material.dart';

class MoodTracker extends StatelessWidget {
  const MoodTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Mood Tracker", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodEmoji('😊', 'Focused'),
                _buildMoodEmoji('😐', 'Neutral'),
                _buildMoodEmoji('😠', 'Frustrated'),
                _buildMoodEmoji('😟', 'Anxious'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEmoji(String emoji, String mood) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 40)),
        Text(mood),
      ],
    );
  }
}
