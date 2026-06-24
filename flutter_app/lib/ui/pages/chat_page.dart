import 'package:flutter/material.dart';
import '../../components/ai_chatbox.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🤖 AI Coach & Analyst"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: const AiChatBox(),
    );
  }
}
