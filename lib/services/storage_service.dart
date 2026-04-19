import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  static const key = "tickets";

  static Future<void> saveTicket(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList(key) ?? [];
    list.add(jsonEncode(data));

    await prefs.setStringList(key, list);
  }

  static Future<List<Map<String, dynamic>>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList(key) ?? [];

    return list.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();
  }
}