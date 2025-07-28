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

  Map<String, dynamic> toJson() => {
        'asset': asset,
        'direction': direction,
        'entryPrice': entryPrice,
        'exitPrice': exitPrice,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'status': status,
        'pnl': pnl,
        'moodBefore': moodBefore,
        'moodAfter': moodAfter,
        'notes': notes,
      };
}
