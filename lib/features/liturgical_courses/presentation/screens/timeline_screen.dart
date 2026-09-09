import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String period;
  final String location;
  final String description;
  final List<String> figures;

  TimelineEvent({
    required this.period,
    required this.location,
    required this.description,
    required this.figures,
  });
}

class LiturgicalTimelineScreen extends StatefulWidget {
  const LiturgicalTimelineScreen({super.key});

  @override
  State<LiturgicalTimelineScreen> createState() => _LiturgicalTimelineScreenState();
}

class _LiturgicalTimelineScreenState extends State<LiturgicalTimelineScreen> {
  final List<TimelineEvent> historyEvents = [
    TimelineEvent(
      period: '1832',
      location: 'Sablé-sur-Sarthe (Solesmes)',
      description: 'Początki odnowy chorału gregoriańskiego i liturgii monastycznej.',
      figures: ['Prosper Guéranger'],
    ),
    TimelineEvent(
      period: '1863',
      location: 'Beuron',
      description: 'Niemieckie odrodzenie liturgiczne oparte na regule benedyktyńskiej.',
      figures: ['Maurus Wolter', 'Placidus Wolter'],
    ),
    TimelineEvent(
      period: 'Koniec XIX w.',
      location: 'Stresa, Cremona, Vicenza',
      description: 'Pionierzy i prekursorzy włoskiego ruchu.',
      figures: ['Antonio Rosmini-Serbati', 'Geremia Bonomelli', 'Ferdinando Rodolfi'],
    ),
    TimelineEvent(
      period: 'Przełom XIX i XX w.',
      location: 'Brugia, Maredsous',
      description: 'Duchowość liturgiczna i liturgia jako centrum życia.',
      figures: ['Gerard van Caloen', 'Columba Marmion'],
    ),
    TimelineEvent(
      period: '1909',
      location: 'Banneux',
      description: 'Referat w Mechelen – oficjalny początek duszpasterskiego Ruchu Liturgicznego.',
      figures: ['Lambert Beauduin'],
    ),
    TimelineEvent(
      period: 'Lata 1910+',
      location: 'Maria Laach',
      description: 'Ośrodek myśli teologicznej, koncepcja liturgii jako uobecnienia misterium.',
      figures: ['Ildefons Herwegen', 'Odo Casel'],
    ),
    TimelineEvent(
      period: 'Lata 20. XX w.',
      location: 'Klosterneuburg, Monachium',
      description: 'Wyprowadzenie liturgii do ludu. Popularyzacja mszałów dla wiernych i "Mszy dialogowanych".',
      figures: ['Pius Parsch', 'Romano Guardini'],
    ),
    TimelineEvent(
      period: 'Lata 30. XX w.',
      location: 'Ośrodki Włoskie (Mediolan, Genua, Brescia...)',
      description: 'Rozkwit duszpasterstwa liturgicznego, powstawanie instytutów i czasopism.',
      figures: [
        'Agostino Gemelli', 'Giuseppe Polvara', 'Adriano Bernareggi', 'Carlo Rossi', 
        'Giacomo Moglia', 'Matteo Angelo Filipello', 'Giulio Bevilacqua', 
        'Emanuele Caronti', 'Eusebio Vismara', 'Giacomo Alberione'
      ],
    ),
    TimelineEvent(
      period: 'Okres międzywojenny',
      location: 'Polska (Pelplin, Płock, Lublin)',
      description: 'Polskie fundamenty ruchu. Pierwsze publikacje i tłumaczenia mszałów.',
      figures: ['Kazimierz Bieszk', 'Antoni Julian Nowowiejski', 'Józef Michalak', 'Antoni Nojszewski', 'Władysław Korniłowicz'],
    ),
    TimelineEvent(
      period: 'Połowa XX w.',
      location: 'Polska (Kraków, Lwów)',
      description: 'Dalszy rozwój edukacji liturgicznej na ziemiach polskich.',
      figures: ['Jan Korzonkiewicz', 'Michał Kordel', 's. Maria Renata', 'Alojzy Jougan', 'Gerard Szmyd'],
    ),
    TimelineEvent(
      period: '1963',
      location: 'Brescia / Rzym',
      description: 'Zwieńczenie wysiłków Ruchu Liturgicznego: Sobór Watykański II i ogłoszenie Konstytucji "Sacrosanctum Concilium".',
      figures: ['Giovanni Battista Montini (Paweł VI)'],
    ),
  ];

  Future<void> _navigateToLesson(String figureName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data() ?? {};
    final progressMap = data['progress'] as Map<String, dynamic>? ?? {};

    int completedTrunkLessons = 0;
    progressMap.forEach((courseId, completedList) {
      if (courseId.startsWith('trunk_')) {
        int lessonsCount = (completedList as List?)?.length ?? 0;
        if (lessonsCount > 0) {
          completedTrunkLessons += lessonsCount;
        }
      }
    });

    if (completedTrunkLessons < 1) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2D3039),
            title: const Text('Sekcja zablokowana', style: TextStyle(color: Colors.amber)),
            content: const Text(
              'Aby odblokować lekcje z Postaci Ruchu Liturgicznego, musisz najpierw ukończyć lekcje z Teologii Liturgii (główne drzewko)',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Rozumiem', style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
        );
      }
      return; 
    }

    String cleanName = figureName.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    cleanName = cleanName
        .replaceAll('é', 'e').replaceAll('ł', 'l').replaceAll('ó', 'o')
        .replaceAll('ś', 's').replaceAll('ż', 'z').replaceAll('ź', 'z')
        .replaceAll('ć', 'c').replaceAll('ń', 'n').replaceAll('ą', 'a')
        .replaceAll('ę', 'e').replaceAll('.', '').replaceAll('(', '').replaceAll(')', '');

    String lessonId = 'history_$cleanName';
    context.push('/courses/details/$lessonId', extra: figureName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Oś czasu Ruchu Liturgicznego - postacie', style: TextStyle(color: Colors.amber, fontSize: 18)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        itemCount: historyEvents.length,
        itemBuilder: (context, index) {
          final event = historyEvents[index];
          final isLast = index == historyEvents.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 3,
                            color: Colors.amber.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event.period,
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D3039),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 16, top: 12, bottom: 4),
                                child: Text(
                                  'Związane postacie:',
                                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...event.figures.map((figure) => InkWell(
                                onTap: () => _navigateToLesson(figure),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person, color: Colors.amber, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          figure,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                                    ],
                                  ),
                                ),
                              )),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}