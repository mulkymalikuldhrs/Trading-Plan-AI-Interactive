import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Artboard? _riveArtboard;
  SMIInput<String>? _moodInput;

  @override
  void initState() {
    super.initState();
    // In a real app, you would load this from your assets folder
    // For now, we'll just pretend it's loaded.
    // rootBundle.load('assets/rive/emotional_orb.riv').then(
    //   (data) async {
    //     final file = RiveFile.import(data);
    //     final artboard = file.mainArtboard;
    //     var controller = StateMachineController.fromArtboard(artboard, 'MoodMachine');
    //     if (controller != null) {
    //       artboard.addController(controller);
    //       _moodInput = controller.findInput<String>('mood');
    //     }
    //     setState(() => _riveArtboard = artboard);
    //   },
    // );
  }

  void _setMood(String mood) {
    _moodInput?.value = mood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🔮 Live Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Placeholder for a cool, animated background shader
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey[900]!, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your Emotional State",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  height: 300,
                  child: _riveArtboard == null
                      ? Center(child: CircularProgressIndicator())
                      : Rive(artboard: _riveArtboard!),
                ),
                SizedBox(height: 30),
                // Buttons to simulate changing mood
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () => _setMood("Focused"), child: Text("Focused")),
                    ElevatedButton(onPressed: () => _setMood("Anxious"), child: Text("Anxious")),
                    ElevatedButton(onPressed: () => _setMood("Win"), child: Text("Win")),
                    ElevatedButton(onPressed: () => _setMood("Loss"), child: Text("Loss")),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
