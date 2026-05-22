import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ConsistencyStreakCalendar extends StatefulWidget {
  @override
  _ConsistencyStreakCalendarState createState() => _ConsistencyStreakCalendarState();
}

class _ConsistencyStreakCalendarState extends State<ConsistencyStreakCalendar> {
  Map<int, int> dataset = {};
  bool isLoading = true;

  final List<Color> colors = [
    Colors.grey.shade800, // No activity
    Colors.green.shade900,
    Colors.green.shade700,
    Colors.green.shade500,
    Colors.green.shade300, // High activity
    Colors.red.shade700, // Negative day (e.g., override)
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await ApiService.post('exportToJson', {'sheetName': 'Journal'});
      final List<dynamic> journal = (data is String) ? jsonDecode(data) : data;
      Map<int, int> newDataset = {};

      final now = DateTime.now();
      for (var trade in journal) {
        final date = DateTime.tryParse(trade['timestamp'] ?? '') ?? now;
        final difference = now.difference(date).inDays;
        if (difference >= 0 && difference < 90) {
          int index = 89 - difference;
          newDataset[index] = (newDataset[index] ?? 0) + 1;
          if (newDataset[index]! > 4) newDataset[index] = 4;

          if (trade['ai_status'] == 'OVERRIDE') {
            newDataset[index] = 5;
          }
        }
      }

      setState(() {
        dataset = newDataset;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

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
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
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
