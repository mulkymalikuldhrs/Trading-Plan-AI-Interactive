import 'package:flutter/material.dart';

// This is a simplified version. A real implementation would use a package
// like `flutter_heatmap_calendar` or build a custom grid.
class ConsistencyStreakCalendar extends StatelessWidget {
  // Static dummy data: keys are day index (0-364), values are "intensity" (0-4)
  static const Map<int, int> _dataset = {
    1: 1, 2: 2, 3: 3, 4: 4, 5: 1, 6: 0,
    7: 2, 8: 3, 9: 4, 10: 1, 11: 2, 12: 0,
    14: 1, 15: 2, 16: 3,
  };

  static final List<Color> _colors = [
    Colors.grey.shade800, // No activity
    Colors.green.shade900,
    Colors.green.shade700,
    Colors.green.shade500,
    Colors.green.shade300, // High activity
    Colors.red.shade700, // Negative day (e.g., override)
  ];

  const ConsistencyStreakCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Consistency Calendar", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            SizedBox(height: 16),
            // This is a simplified representation of the grid
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(90, (index) {
                int intensity = _dataset[index] ?? 0;
                return Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: _colors[intensity],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
