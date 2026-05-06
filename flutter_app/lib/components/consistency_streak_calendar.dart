import 'package:flutter/material.dart';

class ConsistencyStreakCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Discipline Streak: 5 Days 🔥", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            SizedBox(height: 12),
            // Placeholder for a real calendar grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) => Icon(
                index < 5 ? Icons.check_circle : Icons.radio_button_unchecked,
                color: index < 5 ? Colors.greenAccent : Colors.grey,
              )),
            )
          ],
        ),
      ),
    );
  }
}
