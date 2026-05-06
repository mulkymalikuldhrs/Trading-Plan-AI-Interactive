import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WinRatePieChart extends StatelessWidget {
  final int wins = 65;
  final int losses = 35;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.blueGrey[900]?.withValues(alpha: 0.5),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 18),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Indicator(color: Colors.greenAccent, text: 'Wins', isSquare: true),
                  const SizedBox(width: 4),
                  const Indicator(color: Colors.redAccent, text: 'Losses', isSquare: true),
                ],
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      const fontSize = 16.0;
      const radius = 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.greenAccent,
            value: wins.toDouble(),
            title: '$wins%',
            radius: radius,
            titleStyle: const TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.redAccent,
            value: losses.toDouble(),
            title: '$losses%',
            radius: radius,
            titleStyle: const TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
        )
      ],
    );
  }
}
