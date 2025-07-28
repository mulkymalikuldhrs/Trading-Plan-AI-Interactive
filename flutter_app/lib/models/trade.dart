class Trade {
  final String id;
  final DateTime timestamp;
  final String asset;
  final String direction;
  final double entryPrice;
  final double exitPrice;
  final double stopLoss;
  final double takeProfit;
  final String status;
  final double pnl;
  final String moodBefore;
  final String moodAfter;
  final String notes;

  Trade({
    required this.id,
    required this.timestamp,
    required this.asset,
    required this.direction,
    required this.entryPrice,
    required this.exitPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.status,
    required this.pnl,
    required this.moodBefore,
    required this.moodAfter,
    required this.notes,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['TradeID'],
      timestamp: DateTime.parse(json['Timestamp']),
      asset: json['Pair'],
      direction: json['Direction'],
      entryPrice: (json['EntryPrice'] as num).toDouble(),
      exitPrice: (json['ExitPrice'] as num).toDouble(),
      stopLoss: (json['SL'] as num).toDouble(),
      takeProfit: (json['TP'] as num).toDouble(),
      status: json['Result'],
      pnl: (json['PnL'] as num).toDouble(),
      moodBefore: json['Mood'],
      moodAfter: json['Emotion_After'],
      notes: json['GPT_Comment'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pair': asset,
        'direction': direction,
        'entry': entryPrice,
        'sl': stopLoss,
        'tp': takeProfit,
        'mood': moodBefore,
        'status': status,
        'pnl': pnl,
        'emotion_after': moodAfter,
        'gpt_comment': notes,
      };
}
