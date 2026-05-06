import 'package:flutter/material.dart';

class MoodTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("How are you feeling?", style: Theme.of(context).textTheme.titleLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.sentiment_very_satisfied), onPressed: () {}),
            IconButton(icon: Icon(Icons.sentiment_satisfied), onPressed: () {}),
            IconButton(icon: Icon(Icons.sentiment_neutral), onPressed: () {}),
            IconButton(icon: Icon(Icons.sentiment_dissatisfied), onPressed: () {}),
            IconButton(icon: Icon(Icons.sentiment_very_dissatisfied), onPressed: () {}),
          ],
        ),
      ],
    );
  }
}
