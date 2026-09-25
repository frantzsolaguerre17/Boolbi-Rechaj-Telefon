import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
const HistoryScreen({super.key});

@override
State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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

    final nanChajTickets = data.where((ticket) {
      return ticket["statut"]?.toString() == "NAN CHAJ";
    }).toList();

    setState(() {
      tickets = nanChajTickets;
      isLoading = false;
    });
  }



  String formatDateTime(dynamic value) {
    if (value == null) {
      return "DATE INCONNUE";
    }

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else if (value is int) {
      date = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return "DATE INCONNUE";
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


  Future<void> _remettreTicket(Map<String, dynamic> ticket) async {
    final confirme = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Konfimasyon",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Eskew vreman vle chanje stati a an REMET ?",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "Anile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "REMET",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirme != true) return;

    final code = ticket["kod"]?.toString();

    if (code == null) return;

    await StorageService.updateTicketStatus(
      code,
      "REMET",
    );

    await load();
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
          "Telefon kap chaje",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Aktyalize",
            icon: const Icon(Icons.refresh),
            onPressed: load,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF146B3A),
        ),
      );
    }

    if (tickets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.25,
          ),

          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Pa gen fich",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              "Fich yo ap paret la",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),

      children: [

// =========================
// RÉSUMÉ
// =========================

        Container(
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

            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.20),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: Row(
            children: [

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Telefon kap chaje",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${tickets.length} telefon ap chaje",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Fich telefon kap chaje",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202124),
          ),
        ),

        const SizedBox(height: 15),

// =========================
// LISTE
// =========================

        ...tickets
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final ticket = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),

            child: _ticketCard(
              ticket,
              index,
            ),
          );
        }),
      ],
    );
  }

// =========================
// TICKET CARD
// =========================


  _ticketCard(Map<String, dynamic> ticket,
      int index,) {
    final name = ticket["non"]?.toString() ?? "Client";
    final price = ticket["pri"]?.toString() ?? "0";
    final code = ticket["kod"]?.toString() ?? "---";
    final marque = ticket["mak"]?.toString() ?? "N/A";
    final etat = ticket["eta"]?.toString() ?? "N/A";
    final statut = ticket["statut"]?.toString() ?? "NAN CHAJ";
    final dateValue = ticket["dat"];
    final deskripsyon = ticket["deskripsyon"]?.toString() ?? "Pa gen deskripsyon";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF198754).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.receipt,
                    color: Color(0xFF198754),
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              marque,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              etat,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                Row(
                children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    formatDateTime(dateValue),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.description_outlined,
              size: 15,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                deskripsyon,
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        ],
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statut == "REMET"
                        ? Colors.blue.withOpacity(0.10)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statut,
                    style: TextStyle(
                      color: statut == "REMET"
                          ? Colors.blue.shade700
                          : Colors.orange.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
            Expanded(
            child: statut == "NAN CHAJ"
            ? SizedBox(
            height: 38,
              child: ElevatedButton(
                onPressed: () => _remettreTicket(ticket),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF198754),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "REMET",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            : Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "REMET",
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),


    Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$price HTG",
                    style: const TextStyle(
                      color: Color(0xFF198754),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}