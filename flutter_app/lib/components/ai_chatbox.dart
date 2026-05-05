import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AiChatBox extends StatefulWidget {
  @override
  _AiChatBoxState createState() => _AiChatBoxState();
}

class _AiChatBoxState extends State<AiChatBox> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _handleSend() async {
    if (_controller.text.isEmpty) return;
    final text = _controller.text;
    _controller.clear();
    setState(() => _messages.add("You: $text"));

    try {
      final response = await ApiService.post('getGptFeedback', {
        'promptType': 'Chat',
        'promptData': {'userInput': text},
        'referenceId': 'CHAT-${DateTime.now().millisecondsSinceEpoch}'
      });
      setState(() => _messages.add("AI: ${response['response'] ?? 'I heard you.'}"));
    } catch (e) {
      setState(() => _messages.add("AI Error: Could not reach analyst."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, i) => ListTile(title: Text(_messages[i])),
          ),
        ),
        TextField(controller: _controller, onSubmitted: (_) => _handleSend()),
      ],
    );
  }
}
