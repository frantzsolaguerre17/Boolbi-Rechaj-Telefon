import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    tickets = await StorageService.getTickets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Istorik")),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final t = tickets[index];

          return Card(
            child: ListTile(
              title: Text(t["non"] ?? ""),
              subtitle: Text("${t["mak"]} - ${t["pri"]} HTG"),
              trailing: Text(t["kod"] ?? ""),
            ),
          );
        },
      ),
    );
  }
}