import 'package:flutter/material.dart';
import '../services/gpt_summarizer.dart';
import '../services/forecast_service.dart';
import '../ui/widgets/chat_bubble.dart';

class AiChatBox extends StatefulWidget {
  const AiChatBox({super.key});

  @override
  @override
  State<AiChatBox> createState() => _AiChatBoxState();
}

class _AiChatBoxState extends State<AiChatBox> {
  final List<Map<String, dynamic>> _messages = [
    {'message': 'Welcome to the Intelligence Hub. Ask for a market summary or forecast, e.g., "/forecast GOLD"', 'isUser': false},
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSend() async {
    if (_controller.text.isEmpty) return;
    final userInput = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({'message': userInput, 'isUser': true});
      _messages.add({'message': '🤖 Thinking...', 'isUser': false});
    });
    _scrollToBottom();

    try {
      String formattedReply = '';
      if (userInput.toLowerCase().startsWith('/summary')) {
        final parts = userInput.split(' ');
        final symbol = parts.length > 1 ? parts[1].toUpperCase() : 'EURUSD';
        final summary = await GptSummarizer.getAiMasterSummary(symbol);

        formattedReply = '''
🧠 AI Master Summary for $symbol
Bias: ${summary['final_bias']} (Confidence: ${summary['confidence_score']}/10)
Signal: ${summary['signal'] != null && summary['signal']['active'] == true ? 'ACTIVE' : 'INACTIVE'}
Entry: ${summary['signal'] != null ? summary['signal']['entry'] ?? 'N/A' : 'N/A'}
''';
      } else if (userInput.toLowerCase().startsWith('/forecast')) {
        final parts = userInput.split(' ');
        final symbol = parts.length > 1 ? parts[1].toUpperCase() : 'EURUSD';
        final forecast = await ForecastService.getForecast(pair: symbol, timeframe: 'H4', days: 7);

        formattedReply = '''
🔮 AI Forecast for $symbol (7-Day Outlook)
Bias: ${forecast['bias']}
Probability: ${forecast['probability']}%
Entry Zone: ${forecast['entry_zone']}
SL: ${forecast['stop_loss']} | TP: ${forecast['take_profit']}
''';
      } else {
        formattedReply = 'I can currently provide summaries and forecasts with the /summary and /forecast commands.';
      }

      setState(() {
        _messages.removeLast();
        _messages.add({'message': formattedReply, 'isUser': false});
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({'message': 'AI Error: Could not reach analyst.', 'isUser': false});
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, i) => ChatBubble(
              message: _messages[i]['message'],
              isUser: _messages[i]['isUser'],
            ),
          ),
        ),
        _buildTextComposer(),
      ],
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(hintText: "e.g., /forecast GOLD"),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
