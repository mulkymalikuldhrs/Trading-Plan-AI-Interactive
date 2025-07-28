import 'package:flutter/material.dart';
import '../ui/widgets/chat_bubble.dart';
import '../services/api_service.dart';

class AiChatbox extends StatefulWidget {
  @override
  _AiChatboxState createState() => _AiChatboxState();
}

class _AiChatboxState extends State<AiChatbox> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'message': 'Hello! I am your AI Trading Coach. How can I help you reflect today?', 'isUser': false},
  ];

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userInput = _controller.text;
      setState(() {
        _messages.add({'message': userInput, 'isUser': true});
        _messages.add({'message': '🧠 Thinking...', 'isUser': false});
      });
      _controller.clear();

      try {
        final response = await ApiService.getGptFeedback(
          'ReflectiveQuestion', // This would be dynamic based on user input
          'chat-ref',
          {'last_action': userInput},
        );
        setState(() {
          _messages.removeLast();
          _messages.add({'message': response['root_cause_question'], 'isUser': false});
        });
      } catch (e) {
        setState(() {
          _messages.removeLast();
          _messages.add({'message': 'Sorry, I had trouble connecting. Please try again.', 'isUser': false});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Example height
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  message: _messages[index]['message'],
                  isUser: _messages[index]['isUser'],
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration.collapsed(hintText: "Ask for advice or reflect..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
