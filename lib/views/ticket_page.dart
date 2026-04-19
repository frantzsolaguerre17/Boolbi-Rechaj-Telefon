import 'dart:math';
import 'package:flutter/material.dart';
import '../services/printer_service.dart';
import '../services/storage_service.dart';

class CreateTicketScreen extends StatefulWidget {
  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {

  final nomController = TextEditingController();
  final prixController = TextEditingController();

  // ======================
  // VALUES DEFAULT
  // ======================
  String appareil = "Telefon";
  String marque = "Samsung";
  String etat = "Bon";

  bool isPhoneSelected = true;

  // ======================
  // LISTES
  // ======================
  final appareils = [
    "Telefon",
    "Limye",
    "Radyo",
    "Laptop",
    "Bakop",
    "Tablet",
    "Printer POS"
  ];

  final marques = [
    "Samsung",
    "iPhone",
    "Tecno",
    "Infinix"
  ];

  final etats = ["Bon", "Moyen", "Mauvais"];

  // ======================
  // CODE RANDOM 3 CHIFFRES
  // ======================
  String generateCode() {
    return (Random().nextInt(900) + 100).toString();
  }

  // ======================
  // CHANGE APPAREIL LOGIC
  // ======================
  void onAppareilChanged(String? value) {
    setState(() {
      appareil = value!;
      isPhoneSelected = (appareil == "Telefon");

      if (!isPhoneSelected) {
        marque = "";
      } else {
        marque = "Samsung";
      }
    });
  }

  // ======================
  // PRINT + SAVE
  // ======================
  Future<void> printTicket() async {

    final data = {
      "non": nomController.text,
      "mak": isPhoneSelected ? marque : "N/A",
      "app": appareil,
      "eta": etat,
      "pri": prixController.text,
      "dat": DateTime.now().toString(),
      "kod": generateCode(),
    };

    await StorageService.saveTicket(data);

    // Impression DOUBLE
    await PrinterService.print(data);
    //await Future.delayed(Duration(seconds: 1));
    //await PrinterService.print(data);
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nouvo Rechaj"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            // ======================
            // APPAREIL
            // ======================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: DropdownButtonFormField(
                  value: appareil,
                  decoration: InputDecoration(
                    labelText: "Aparèy",
                    border: OutlineInputBorder(),
                  ),
                  items: appareils
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  onChanged: onAppareilChanged,
                ),
              ),
            ),

            SizedBox(height: 15),

            // ======================
            // MARQUE (CONDITIONNEL)
            // ======================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: DropdownButtonFormField(
                  value: isPhoneSelected ? marque : null,
                  decoration: InputDecoration(
                    labelText: "Mak",
                    border: OutlineInputBorder(),
                  ),
                  items: marques
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  onChanged: isPhoneSelected
                      ? (v) {
                    setState(() {
                      marque = v.toString();
                    });
                  }
                      : null, // DISABLED
                ),
              ),
            ),

            SizedBox(height: 15),

            // ======================
            // NOM CLIENT
            // ======================
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: "Non kliyan",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            // ======================
            // ETAT
            // ======================
            DropdownButtonFormField(
              value: etat,
              decoration: InputDecoration(
                labelText: "Eta aparèy",
                border: OutlineInputBorder(),
              ),
              items: etats
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  etat = v.toString();
                });
              },
            ),

            SizedBox(height: 15),

            // ======================
            // PRIX
            // ======================
            TextField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Pri (HTG)",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 25),

            // ======================
            // BUTTON PRINT
            // ======================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: printTicket,
              child: Text(
                "ENPRIME",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}