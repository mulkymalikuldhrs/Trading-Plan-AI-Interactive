import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const MoodSelector({Key? key, this.initialValue, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: 'Current Mood'),
      items: ['Calm', 'Excited', 'Anxious', 'Frustrated', 'Greedy', 'Fearful']
          .map((mood) => DropdownMenuItem(value: mood, child: Text(mood)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
