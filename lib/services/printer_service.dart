import 'package:flutter/services.dart';

class PrinterService {

  static const channel =
  MethodChannel("com.example.postest.pos_flutter_app/printer");

  static Future<void> print(Map<String, dynamic> data) async {
    await channel.invokeMethod("printText", data);
  }
}