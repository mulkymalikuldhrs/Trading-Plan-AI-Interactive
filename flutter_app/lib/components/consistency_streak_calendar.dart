import 'package:flutter/material.dart';

// This is a simplified version. A real implementation would use a package
// like `flutter_heatmap_calendar` or build a custom grid.
class ConsistencyStreakCalendar extends StatelessWidget {
  // dataset will be populated from GAS/Google Sheets data in production.
  final Map<int, int> dataset;

  ConsistencyStreakCalendar({super.key, this.dataset = const {}});

  final List<Color> colors = [
    Colors.grey.shade800, // No activity
    Colors.green.shade900,
    Colors.green.shade700,
    Colors.green.shade500,
    Colors.green.shade300, // High activity
    Colors.red.shade700, // Negative day (e.g., override)
  ];

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
                int intensity = dataset[index] ?? 0;
                return Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: colors[intensity],
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
