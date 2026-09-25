import 'dart:math';
import 'package:flutter/material.dart';
import '../services/printer_service.dart';
import '../services/storage_service.dart';

class CreateTicketScreen extends StatefulWidget {
const CreateTicketScreen({super.key});

@override
State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
final nomController = TextEditingController();
final prixController = TextEditingController();
final deskripsyonController = TextEditingController();

String appareil = "Telefon";
String marque = "Samsung";
String etat = "Bon";

bool isPhoneSelected = true;
bool isPrinting = false;

final appareils = [
"Telefon",
"Limye",
"Radyo",
"Laptop",
"Bakop",
"Tablet",
"Printer POS",
];

final marques = [
"Samsung",
"iPhone",
"Tecno",
"Infinix",
"Motorola",
"Xiaomi",
"Huawei",
"Oppo",
"Vivo",
"OnePlus",
"Google",
"MyCom (Ak Bouton)",
"Blu (Ak Bouton)",
];

final etats = [
"Nef",
"Bon",
"Pa mal",
"Move",
];

String generateCode() {
return (Random().nextInt(900) + 100).toString();
}

void onAppareilChanged(String? value) {
if (value == null) return;

setState(() {
appareil = value;
isPhoneSelected = appareil == "Telefon";

if (!isPhoneSelected) {
marque = "";
} else {
marque = "Samsung";
}
});
}

Future<void> printTicket() async {
if (nomController.text.trim().isEmpty) {
_showMessage("Tanpri antre non kliyan an.");
return;
}

if (prixController.text.trim().isEmpty) {
_showMessage("Tanpri antre pri a.");
return;
}

setState(() {
isPrinting = true;
});

final DateTime creationDate = DateTime.now();
final String code = generateCode();

final data = {
"non": nomController.text.trim(),
"mak": isPhoneSelected ? marque : "N/A",
"app": appareil,
"eta": etat,
"deskripsyon": deskripsyonController.text.trim(),
"pri": prixController.text.trim(),
"dat": creationDate.toIso8601String(),
"kod": code,
"statut": "NAN CHAJ",
};

try {
await StorageService.saveTicket(data);

await PrinterService.print(data);

if (!mounted) return;

_showMessage(
"Tikè $code kreye avèk siksè.",
);

nomController.clear();
prixController.clear();
deskripsyonController.clear();

setState(() {
appareil = "Telefon";
marque = "Samsung";
etat = "Bon";
isPhoneSelected = true;
});
} catch (e) {
if (!mounted) return;

_showMessage(
"Erè pandan kreyasyon tikè a.",
);
} finally {
if (mounted) {
setState(() {
isPrinting = false;
});
}
}
}

void _showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
),
);
}

@override
void dispose() {
nomController.dispose();
prixController.dispose();
deskripsyonController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),
appBar: AppBar(
elevation: 0,
backgroundColor: const Color(0xFF146B3A),
foregroundColor: Colors.white,
title: const Text(
"Nouvo Rechaj",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Color(0xFF146B3A),
Color(0xFF198754),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(22),
),
child: const Row(
children: [
Icon(
Icons.receipt_long,
color: Colors.white,
size: 38,
),
SizedBox(width: 15),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Kreye yon nouvo fich",
style: TextStyle(
color: Colors.white,
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 5),
Text(
"Ranpli enfòmasyon kliyan an",
style: TextStyle(
color: Colors.white70,
fontSize: 13,
),
),
],
),
),
],
),
),
const SizedBox(height: 25),
_sectionTitle(
"Aparèy",
Icons.devices,
),
const SizedBox(height: 10),
_card(
child: DropdownButtonFormField<String>(
value: appareil,
decoration: _inputDecoration(
"Aparèy",
Icons.devices,
),
items: appareils.map((item) {
return DropdownMenuItem<String>(
value: item,
child: Text(item),
);
}).toList(),
onChanged: onAppareilChanged,
),
),
const SizedBox(height: 18),
_sectionTitle(
"Mak",
Icons.phone_android,
),
const SizedBox(height: 10),
_card(
child: DropdownButtonFormField<String>(
value: isPhoneSelected ? marque : null,
decoration: _inputDecoration(
"Mak",
Icons.phone_android,
),
items: marques.map((e) {
return DropdownMenuItem<String>(
value: e,
child: Text(e),
);
}).toList(),
onChanged: isPhoneSelected
? (value) {
if (value == null) return;

setState(() {
marque = value;
});
}
    : null,
),
),
const SizedBox(height: 18),
_sectionTitle(
"Kliyan",
Icons.person_outline,
),
const SizedBox(height: 10),
_card(
child: TextField(
controller: nomController,
textCapitalization: TextCapitalization.words,
decoration: _inputDecoration(
"Non kliyan",
Icons.person_outline,
),
),
),
const SizedBox(height: 18),
_sectionTitle(
"Eta aparèy",
Icons.info_outline,
),
const SizedBox(height: 10),
_card(
child: DropdownButtonFormField<String>(
value: etat,
decoration: _inputDecoration(
"Eta aparèy",
Icons.info_outline,
),
items: etats.map((e) {
return DropdownMenuItem<String>(
value: e,
child: Text(e),
);
}).toList(),
onChanged: (value) {
if (value == null) return;

setState(() {
etat = value;
});
},
),
),
const SizedBox(height: 18),
_sectionTitle(
"Deskripsyon",
Icons.description_outlined,
),
const SizedBox(height: 10),
_card(
child: TextField(
controller: deskripsyonController,
maxLines: 5,
minLines: 3,
keyboardType: TextInputType.multiline,
textCapitalization: TextCapitalization.sentences,
decoration: _inputDecoration(
"Deskripsyon",
Icons.description_outlined,
).copyWith(
hintText: "Ekri pwoblèm oswa detay sou aparèy la...",
alignLabelWithHint: true,
),
),
),
const SizedBox(height: 18),
_sectionTitle(
"Pri",
Icons.payments_outlined,
),
const SizedBox(height: 10),
_card(
child: TextField(
controller: prixController,
keyboardType: TextInputType.number,
decoration: _inputDecoration(
"Pri (HTG)",
Icons.payments_outlined,
).copyWith(
suffixText: "HTG",
),
),
),
const SizedBox(height: 28),
SizedBox(
width: double.infinity,
height: 58,
child: ElevatedButton.icon(
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF198754),
foregroundColor: Colors.white,
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
onPressed: isPrinting ? null : printTicket,
icon: isPrinting
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : const Icon(
Icons.print,
size: 23,
),
label: Text(
isPrinting
? "AP ENPRIME..."
    : "ENPRIME FICH",
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),
const SizedBox(height: 25),

  Center(
    child: Text(
      "BOULBI KONPLEKS • Rechaj telefon",
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 12,
      ),
    ),
  ),
],
),
),
);
}

Widget _sectionTitle(
String title,
IconData icon,
) {
return Row(
children: [
Icon(
icon,
size: 19,
color: const Color(0xFF146B3A),
),
const SizedBox(width: 8),
Text(
title,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
color: Color(0xFF202124),
),
),
],
);
}

Widget _card({
required Widget child,
}) {
return Container(
padding: const EdgeInsets.all(5),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.03),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: child,
);
}

InputDecoration _inputDecoration(
String label,
IconData icon,
) {
return InputDecoration(
labelText: label,
prefixIcon: Icon(
icon,
color: const Color(0xFF146B3A),
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide.none,
),
filled: true,
fillColor: Colors.white,
contentPadding: const EdgeInsets.symmetric(
horizontal: 15,
vertical: 15,
),
);
}
}

String formatDateTime(dynamic value) {
if (value == null) {
return "Date inconnue";
}

final date = DateTime.tryParse(value.toString());

if (date == null) {
return "Date inconnue";
}

final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');
final year = date.year;

final hour = date.hour.toString().padLeft(2, '0');
final minute = date.minute.toString().padLeft(2, '0');

return "$day/$month/$year à $hour:$minute";
}