import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'message': 'Hello! How can I help you today?', 'isUser': false},
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'message': _controller.text, 'isUser': true});
        // Here you would call the ApiService to get a response from the AI
        // For now, we'll just add a dummy response.
        _messages.add({'message': 'Thinking...', 'isUser': false});
      });
      _controller.clear();
      // Simulate AI response
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _messages.removeLast();
          _messages.add({'message': 'This is a placeholder AI response.', 'isUser': false});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🤖 AI Coach"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  message: _messages[index]['message'],
                  isUser: _messages[index]['isUser'],
                );
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controller,
              onSubmitted: (text) => _sendMessage(),
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
