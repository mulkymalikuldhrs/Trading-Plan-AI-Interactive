import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/trade.dart';
import 'dart:convert';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late Future<List<Trade>> _trades;

  @override
  void initState() {
    super.initState();
    _trades = _fetchTrades();
  }

  Future<List<Trade>> _fetchTrades() async {
    final data = await ApiService.post('exportToJson', {'sheetName': 'Journal'});
    final List<dynamic> tradeData = (data is String) ? jsonDecode(data) : data;
    return tradeData.map((json) => Trade.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📚 Trade Journal"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: FutureBuilder<List<Trade>>(
        future: _trades,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No trades found."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final trade = snapshot.data![index];
                return ListTile(
                  title: Text('${trade.asset} ${trade.direction}'),
                  subtitle: Text('PnL: ${trade.pnl}'),
                  trailing: Text(trade.status, style: TextStyle(color: trade.status == 'WIN' ? Colors.green : Colors.red)),
                );
              },
            );
          }
        },
      ),
    );
  }
}
