import 'package:flutter/material.dart';
import '../../components/ai_chatbox.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🤖 AI Coach & Analyst"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: AiChatBox(),
    );
  }
}
