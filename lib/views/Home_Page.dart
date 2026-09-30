import 'package:flutter/material.dart';
import 'package:pos_flutter_app/views/remet_page.dart';
import 'package:pos_flutter_app/views/ticket_page.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),

appBar: AppBar(
elevation: 0,
backgroundColor: const Color(0xFF146B3A),
foregroundColor: Colors.white,
title: const Text(
"BOULBI KONPLÈKS",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
),
),
),

body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

// =========================
// HEADER
// =========================

Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Color(0xFF146B3A),
Color(0xFF198754),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: Colors.green.withOpacity(0.20),
blurRadius: 20,
offset: const Offset(0, 8),
),
],
),
child: Row(
children: [

  Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    padding: const EdgeInsets.all(3),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Transform.scale(
        scale: 1.15,
        child: Image.asset(
          'assets/images/boolbi.png',
          fit: BoxFit.contain,
        ),
      ),
    ),
  ),

const SizedBox(width: 16),

const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Byenvini",
style: TextStyle(
color: Colors.white70,
fontSize: 14,
),
),
SizedBox(height: 5),
Text(
"BOULBI KONPLÈKS",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 4),
Text(
"Rechaj aparèy elektronik",
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

const SizedBox(height: 28),

// =========================
// TITRE
// =========================

const Text(
"Aksyon rapid",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Color(0xFF202124),
),
),

const SizedBox(height: 6),

const Text(
"Kisa ou swete fè ?",
style: TextStyle(
fontSize: 14,
color: Colors.grey,
),
),

const SizedBox(height: 18),

// =========================
// NOUVEAU TICKET
// =========================

_menuCard(
context: context,
title: "Nouvo Rechaj",
subtitle: "Kreye nouvo fich rechaj",
icon: Icons.add_circle_outline,
color: const Color(0xFF198754),
page: CreateTicketScreen(),
),

const SizedBox(height: 17),

// =========================
// HISTORIQUE
// =========================

_menuCard(
context: context,
title: "Aparèy kap chaje",
subtitle: "Konsilte ansyen rechaj yo",
icon: Icons.ad_units,
color: const Color(0xFF198754),
page: HistoryScreen(),
),

const SizedBox(height: 17),

  _menuCard(
    context: context,
    title: "Aparèy ki remèt",
    subtitle: "Konsilte ansyen rechaj yo",
    icon: Icons.access_alarm,
    color: const Color(0xFF198754),
    page: RemetPage(),
  ),
// =========================
// FOOTER
// =========================

  const SizedBox(height: 20),

Center(
child: Text(
"BOULBI KONPLÈKS • Rechaj Aparèy Elektronik",
style: TextStyle(
color: Colors.grey.shade500,
fontSize: 12,
),
),
),
],
),
),
),
);
}

Widget _menuCard({
required BuildContext context,
required String title,
required String subtitle,
required IconData icon,
required Color color,
required Widget page,
}) {
return Material(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
child: InkWell(
borderRadius: BorderRadius.circular(20),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => page,
),
);
},
child: Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: Colors.grey.shade200,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 12,
offset: const Offset(0, 5),
),
],
),
child: Row(
children: [

// Icône
Container(
width: 56,
height: 56,
decoration: BoxDecoration(
color: color.withOpacity(0.10),
borderRadius: BorderRadius.circular(16),
),
child: Icon(
icon,
color: color,
size: 30,
),
),

const SizedBox(width: 16),

// Texte
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF202124),
),
),
const SizedBox(height: 5),
Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey,
),
),
],
),
),

// Flèche
Container(width: 36, height: 36, decoration: BoxDecoration( color: Colors.grey.shade100, shape: BoxShape.circle,),
child: const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey,
),
),
],
),
),
),
);
}
}
