import 'package:flutter/material.dart';

class MoodSelector extends StatefulWidget {
  final Function(String) onMoodSelected;

  MoodSelector({required this.onMoodSelected});

  @override
  _MoodSelectorState createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  String _selectedMood = 'Focused';

  final Map<String, String> _moods = {
    'Focused': '😊',
    'Neutral': '😐',
    'Frustrated': '😠',
    'Anxious': '😟',
    'FOMO': '😱',
    'Greedy': '🤑',
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMood,
      onChanged: (String? newValue) {
        setState(() {
          _selectedMood = newValue!;
          widget.onMoodSelected(_selectedMood);
        });
      },
      items: _moods.entries.map<DropdownMenuItem<String>>((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text('${entry.value} ${entry.key}'),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Current Mood',
        labelStyle: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
