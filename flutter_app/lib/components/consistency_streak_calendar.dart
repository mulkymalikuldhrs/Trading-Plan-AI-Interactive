import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConsistencyStreakCalendar extends StatefulWidget {
  const ConsistencyStreakCalendar({super.key});

  @override
  State<ConsistencyStreakCalendar> createState() => _ConsistencyStreakCalendarState();
}

class _ConsistencyStreakCalendarState extends State<ConsistencyStreakCalendar> {
  Map<int, int> _dataset = {};
  bool _isLoading = true;

  static final List<Color> _colors = [
    Colors.grey.shade800, // No activity
    Colors.green.shade900,
    Colors.green.shade700,
    Colors.green.shade500,
    Colors.green.shade300, // High activity
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.fetchJournalData();
      final Map<int, int> dailyCounts = {};
      final now = DateTime.now();

      for (var trade in data) {
        if (trade['Timestamp'] != null) {
          final date = DateTime.parse(trade['Timestamp']);
          final dayDifference = now.difference(date).inDays;
          if (dayDifference >= 0 && dayDifference < 90) {
            final dayIndex = 89 - dayDifference;
            dailyCounts[dayIndex] = (dailyCounts[dayIndex] ?? 0) + 1;
          }
        }
      }

      setState(() {
        _dataset = dailyCounts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading consistency data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900]?.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Consistency Calendar", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(90, (index) {
                  int count = _dataset[index] ?? 0;
                  int intensity = count > 4 ? 4 : count;
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
