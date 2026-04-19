import 'package:flutter/material.dart';
import 'package:pos_flutter_app/views/ticket_page.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LSB MULTI SEVIS"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _menuButton(
              context,
              "Nouvo Tikè",
              Icons.add,
              CreateTicketScreen(),
            ),

            SizedBox(height: 20),

            _menuButton(
              context,
              "Istorik",
              Icons.history,
              HistoryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title, IconData icon, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 60),
        backgroundColor: Colors.green,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}