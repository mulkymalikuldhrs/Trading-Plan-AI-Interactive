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

  final List<Color> _colors = [
    Colors.grey.shade800, // 0: No activity
    Colors.green.shade900, // 1: Low positive
    Colors.green.shade700, // 2: Medium positive
    Colors.green.shade500, // 3: Good positive
    Colors.green.shade300, // 4: High positive
    Colors.red.shade700,   // 5: Negative day (override/loss)
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<dynamic> journal = await ApiService.exportSheet('Journal');
      Map<int, int> data = {};
      for (int i = 0; i < journal.length && i < 90; i++) {
        final trade = journal[i];
        final String result = trade['Result']?.toString().toUpperCase() ?? '';
        if (result == 'WIN') {
          data[i] = (data[i] ?? 0) + 2;
        } else if (result == 'LOSS') {
          data[i] = 5; // Red for loss
        }
      }
      // Cap values at 4 for green intensity
      data.updateAll((key, value) => value > 4 && value != 5 ? 4 : value);
      setState(() {
        _dataset = data;
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
      color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Consistency Calendar", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : _dataset.isEmpty
                    ? _buildEmptyState()
                    : Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: List.generate(90, (index) {
                          int intensity = _dataset[index] ?? 0;
                          return Tooltip(
                            message: _getTooltipText(index, intensity),
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: _colors[intensity],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 32, color: Colors.white24),
            SizedBox(height: 8),
            Text(
              'No trade data yet. Start logging trades to build your consistency streak.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(Colors.grey.shade800, 'None'),
        const SizedBox(width: 4),
        _buildLegendItem(Colors.green.shade500, 'Win'),
        const SizedBox(width: 4),
        _buildLegendItem(Colors.red.shade700, 'Loss'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  String _getTooltipText(int index, int intensity) {
    if (intensity == 0) return 'Day ${index + 1}: No activity';
    if (intensity == 5) return 'Day ${index + 1}: Loss';
    return 'Day ${index + 1}: Win';
  }
}
