
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class RemetPage extends StatefulWidget {
const RemetPage({super.key});

@override
State<RemetPage> createState() => _RemetPageState();
}

class _RemetPageState extends State<RemetPage> {
List<Map<String, dynamic>> tickets = [];
bool isLoading = true;

@override
void initState() {
super.initState();
load();
}

Future<void> load() async {
setState(() {
isLoading = true;
});

final data = await StorageService.getTickets();

if (!mounted) return;

final remis = data.where((ticket) {
return ticket["statut"]?.toString() == "REMET";
}).toList();

setState(() {
tickets = remis.reversed.toList();
isLoading = false;
});
}

String formatDateTime(dynamic value) {
if (value == null) {
return "Date inconnue";
}

DateTime? date;

if (value is DateTime) {
date = value;
} else if (value is int) {
date = DateTime.fromMillisecondsSinceEpoch(value);
} else {
date = DateTime.tryParse(value.toString());
}

if (date == null) {
return "Date inconnue";
}

const jours = [
"Lendi",
"Madi",
"Mekredi",
"Jedi",
"Vandredi",
"Samdi",
"Dimanch",
];

const mois = [
"Janvye",
"Fevriye",
"Mas",
"Avril",
"Me",
"Jen",
"Jiye",
"Out",
"Septanb",
"Okyob",
"Novanb",
"Desanb",
];

final jour = jours[date.weekday - 1];
final nomMois = mois[date.month - 1];

int heure = date.hour;
final periode = heure >= 12 ? "PM" : "AM";

heure = heure % 12;

if (heure == 0) {
heure = 12;
}

final minute = date.minute.toString().padLeft(2, '0');

return "$jour ${date.day} $nomMois A ${heure}H : $minute$periode";
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
"Telefon ki Remèt",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
actions: [
IconButton(
onPressed: load,
icon: const Icon(Icons.refresh),
),
],
),
body: RefreshIndicator(
onRefresh: load,
child: isLoading
? const Center(
child: CircularProgressIndicator(
color: Color(0xFF198754),
),
)
    : tickets.isEmpty
? ListView(
physics: const AlwaysScrollableScrollPhysics(),
children: [
const SizedBox(height: 140),
Icon(
Icons.assignment_turned_in_outlined,
size: 70,
color: Colors.grey.shade400,
),
const SizedBox(height: 18),
const Center(
child: Text(
"Pa gen fich REMET",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Color(0xFF202124),
),
),
),
const SizedBox(height: 8),
Center(
child: Text(
"Fich yo ap parèt isit la lè yo REMET.",
style: TextStyle(
fontSize: 13,
color: Colors.grey.shade600,
),
),
),
],
)
    : ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: tickets.length,
itemBuilder: (context, index) {
return _ticketCard(tickets[index]);
},
),
),
);
}

Widget _ticketCard(Map<String, dynamic> ticket) {
final name = ticket["non"]?.toString() ?? "Client";
final price = ticket["pri"]?.toString() ?? "0";
final code = ticket["kod"]?.toString() ?? "---";
final marque = ticket["mak"]?.toString() ?? "N/A";
final appareil = ticket["app"]?.toString() ?? "N/A";
final etat = ticket["eta"]?.toString() ?? "N/A";

final dateCreation = formatDateTime(ticket["dat"]);
final dateRemet = formatDateTime(ticket["dat_remet"]);
final deskripsyon =
    ticket["deskripsyon"]?.toString() ?? "Pa gen deskripsyon";

return Container(
margin: const EdgeInsets.only(bottom: 14),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: const Color(0xFF198754).withOpacity(0.10),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.person,
color: Color(0xFF198754),
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
name,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Color(0xFF202124),
),
),
const SizedBox(height: 4),
Text(
"$appareil • $marque",
style: TextStyle(
fontSize: 13,
color: Colors.grey.shade600,
),
),
],
),
),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: const Color(0xFF198754).withOpacity(0.10),
borderRadius: BorderRadius.circular(10),
),
child: const Text(
"REMET",
style: TextStyle(
color: Color(0xFF198754),
fontSize: 12,
fontWeight: FontWeight.bold,
),
),
),
],
),
const SizedBox(height: 16),
Divider(
height: 1,
color: Colors.grey.shade200,
),
const SizedBox(height: 14),
  Row(
  children: [
  Expanded(
  child: _infoItem(
  Icons.info_outline,
  "Eta",
  etat,
  ),
  ),
  Expanded(
  child: _infoItem(
  Icons.payments_outlined,
  "Pri",
  "$price HTG",
  ),
  ),
  ],
  ),
  const SizedBox(height: 14),
  _descriptionItem(deskripsyon),

const SizedBox(height: 16),
_dateItem(
icon: Icons.event_available_outlined,
title: "Dat Rechaj",
value: dateCreation,
),
const SizedBox(height: 12),
_dateItem(
icon: Icons.assignment_turned_in_outlined,
title: "Dat REMET",
value: dateRemet,
),
const SizedBox(height: 14),
Row(
children: [
const Spacer(),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 7,
),
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius: BorderRadius.circular(8),
),
child: Text(
code,
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
),
),
),
],
),
],
),
);
}

Widget _dateItem({
required IconData icon,
required String title,
required String value,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.grey.shade50,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: const Color(0xFF146B3A).withOpacity(0.08),
borderRadius: BorderRadius.circular(10),
),
child: Icon(
icon,
size: 19,
color: const Color(0xFF146B3A),
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: TextStyle(
fontSize: 11,
color: Colors.grey.shade500,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 3),
Text(
value,
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Color(0xFF202124),
),
),
],
),
),
],
),
);
}

Widget _infoItem(
IconData icon,
String label,
String value,
) {
return Row(
children: [
Icon(
icon,
size: 18,
color: const Color(0xFF146B3A),
),
const SizedBox(width: 7),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: TextStyle(
fontSize: 11,
color: Colors.grey.shade500,
),
),
const SizedBox(height: 2),
Text(
value,
style: const TextStyle(
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
],
),
],
);
}


Widget _descriptionItem(String description) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF146B3A).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.description_outlined,
            size: 19,
            color: Color(0xFF146B3A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Deskripsyon",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description.isEmpty
                    ? "Pa gen deskripsyon"
                    : description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
