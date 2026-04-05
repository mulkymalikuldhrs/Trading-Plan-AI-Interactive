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
  final String setup;
  final String aiStatus;
  final double rrr;

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
    this.setup = 'N/A',
    this.aiStatus = 'PENDING',
    this.rrr = 0.0,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['TradeID']?.toString() ?? '',
      timestamp: json['Timestamp'] != null ? DateTime.parse(json['Timestamp']) : DateTime.now(),
      asset: json['Pair'] ?? 'UNKNOWN',
      direction: json['Direction'] ?? 'BUY',
      entryPrice: (json['EntryPrice'] as num?)?.toDouble() ?? 0.0,
      exitPrice: (json['ExitPrice'] as num?)?.toDouble() ?? 0.0,
      stopLoss: (json['SL'] as num?)?.toDouble() ?? 0.0,
      takeProfit: (json['TP'] as num?)?.toDouble() ?? 0.0,
      status: json['Result'] ?? 'PENDING',
      pnl: (json['PnL'] as num?)?.toDouble() ?? 0.0,
      moodBefore: json['Mood'] ?? 'Neutral',
      moodAfter: json['Emotion_After'] ?? 'N/A',
      notes: json['GPT_Comment'] ?? '',
      setup: json['Setup'] ?? 'N/A',
      aiStatus: json['AI_Status'] ?? 'PENDING',
      rrr: (json['RRR'] as num?)?.toDouble() ?? 0.0,
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
        'setup': setup,
        'ai_status': aiStatus,
        'rrr': rrr,
      };
}
