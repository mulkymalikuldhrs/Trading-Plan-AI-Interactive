import 'package:flutter/material.dart';
import '../../components/entry_form.dart';

class EntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🕵️‍♂️ Validate New Trade Setup"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: EntryForm(),
    );
  }
}
