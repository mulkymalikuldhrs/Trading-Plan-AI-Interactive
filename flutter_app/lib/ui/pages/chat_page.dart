import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../widgets/chat_bubble.dart';
import '../../services/gpt_summarizer.dart';
import '../../services/forecast_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'message': 'Welcome to the Intelligence Hub. Ask for a market summary or forecast, e.g., "/forecast GOLD"', 'isUser': false},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userInput = _controller.text;
    setState(() {
      _messages.add({'message': userInput, 'isUser': true});
       _messages.add({'message': '🤖 Thinking...', 'isUser': false});
    });
    _controller.clear();

    try {
      // Command parsing
      if (userInput.toLowerCase().startsWith('/summary')) {
        final parts = userInput.split(' ');
        final symbol = parts.length > 1 ? parts[1].toUpperCase() : 'EURUSD';

        final summary = await GptSummarizer.getAiMasterSummary(symbol);

        final formattedReply = '''
*🧠 AI Master Summary for $symbol*
*Bias:* ${summary['final_bias']} (Confidence: ${summary['confidence_score']}/10)
*Signal:* ${summary['signal']?['active'] == true ? 'ACTIVE' : 'INACTIVE'}
*Entry:* ${summary['signal']?['entry'] ?? 'N/A'}
''';

        setState(() {
          _messages.removeLast();
          _messages.add({'message': formattedReply, 'isUser': false});
        });

      } else if (userInput.toLowerCase().startsWith('/forecast')) {
        final parts = userInput.split(' ');
        final symbol = parts.length > 1 ? parts[1].toUpperCase() : 'EURUSD';

        final forecast = await ForecastService.getForecast(symbol);

        final formattedReply = '''
*🔮 AI Forecast for $symbol (7-Day Outlook)*
*Bias:* ${forecast['bias']}
*Probability:* ${forecast['probability']}%
*Entry Zone:* ${forecast['entry_zone']}
*Confirmation:* ${forecast['confirmation']}
*SL:* ${forecast['stop_loss']} | *TP:* ${forecast['take_profit']}
''';

        setState(() {
          _messages.removeLast();
          _messages.add({'message': formattedReply, 'isUser': false});
        });

      } else {
         // Default reflection response for other inputs
         setState(() {
          _messages.removeLast();
          _messages.add({'message': 'I can currently provide summaries and forecasts with the /summary and /forecast commands.', 'isUser': false});
        });
      }
    } catch (e) {
       setState(() {
          _messages.removeLast();
          _messages.add({'message': 'Sorry, there was an error processing your request.', 'isUser': false});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🤖 AI Coach & Analyst")),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ChatBubble(
                message: _messages[index]['message'],
                isUser: _messages[index]['isUser'],
              ),
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: "e.g., /forecast GOLD"),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
