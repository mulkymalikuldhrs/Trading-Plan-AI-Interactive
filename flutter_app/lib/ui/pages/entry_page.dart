import 'package:flutter/material.dart';
import '../../components/entry_form.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validate New Trade Setup"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: const EntryForm(),
    );
  }
}
