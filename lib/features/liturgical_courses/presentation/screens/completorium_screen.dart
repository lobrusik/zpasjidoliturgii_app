import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'completorium_day_detail_screen.dart';

class CompletoriumScreen extends StatefulWidget {
  const CompletoriumScreen({super.key});

  @override
  State<CompletoriumScreen> createState() => _CompletoriumScreenState();
}

class _CompletoriumScreenState extends State<CompletoriumScreen> {
  bool _isCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _checkIfCompletedToday();
  }

  Future<void> _checkIfCompletedToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        
        if (data['lastCompletoriumDate'] == todayStr) {
          if (mounted) {
            setState(() {
              _isCompletedToday = true;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Błąd sprawdzania statusu modlitwy: $e');
    }
  }

  Future<void> _markAsCompleted() async {
    if (_isCompletedToday) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Musisz być zalogowany!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isCompletedToday = true;
    });

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        
        int currentStreak = 0;
        List<dynamic> completedDays = [];
        String lastDateStr = '';

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>? ?? {};
          currentStreak = data['completoriumStreak'] ?? 0;
          completedDays = List.from(data['completedCompletoriumDays'] ?? []);
          lastDateStr = data['lastCompletoriumDate'] ?? '';
        }
        
        final now = DateTime.now();
        final todayStr = now.toIso8601String().split('T')[0];
        
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayStr = yesterday.toIso8601String().split('T')[0];

        if (lastDateStr == todayStr) {
          return;
        } else if (lastDateStr == yesterdayStr) {
          currentStreak += 1;
        } else {
          currentStreak = 1;
        }

        String uniqueRecord = 'Kompleta_$todayStr';
        if (!completedDays.contains(uniqueRecord)) {
          completedDays.add(uniqueRecord);
        }

        transaction.set(
          userDocRef,
          {
            'completoriumStreak': currentStreak,
            'lastCompletoriumDate': todayStr,
            'completedCompletoriumDays': completedDays,
          },
          SetOptions(merge: true),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Świetnie! Dzisiejsza Kompleta została odmówiona. +1 do passy 🔥'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Błąd zapisu passy Komplety: $e');
      if (mounted) {
        setState(() {
          _isCompletedToday = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'pl_PL').format(DateTime.now());

    final List completoriumDays = [
      {'title': 'Poniedziałek', 'url': 'https://youtu.be/I-AN8tAdPuA?si=AeKYepSnbrqaY7Gg'},
      {'title': 'Wtorek', 'url': 'https://youtu.be/kmVHUt5aObM?si=XVXL_aho-WxFByH3'},
      {'title': 'Środa', 'url': 'https://youtu.be/1sCkvPTcH8U?si=4HV6WPFfxEg-qrJM'},
      {'title': 'Czwartek', 'url': 'https://youtu.be/r1FcsgKZIRo?si=skkr58HRYwCMJKXH'},
      {'title': 'Piątek', 'url': 'https://youtu.be/HKP474bnHTY?si=7KhwVy8UKrD4n_Ox'},
      {'title': 'Niedziela i uroczystości — po I nieszporach', 'url': 'https://youtu.be/vljqXCX-M5c?si=lBWNAxS4OtGnkb28'},
      {'title': 'Niedziela i uroczystości — po II nieszporach', 'url': 'https://youtu.be/c2ABsqVR92M?si=Ja4BJojSVmL8CADK'},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: DefaultTabController(
        length: 2, 
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌙', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Kompleta',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      toBeginningOfSentenceCase(formattedDate) ?? formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TabBar(
                      indicatorColor: Colors.amber,
                      labelColor: Colors.amber,
                      unselectedLabelColor: Colors.grey.shade500,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Dni Tygodnia'),
                        Tab(text: 'O Modlitwie'),
                      ],
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Wybierz modlitwę na dziś:',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 16),
                          ...completoriumDays.map((day) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3039),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF3B3E4A)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                title: Text(
                                  day['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: const Icon(Icons.play_circle_fill, color: Colors.amber, size: 28),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompletoriumDayDetailScreen(
                                        dayTitle: day['title']!,
                                        youtubeUrl: day['url']!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                          
                          ElevatedButton.icon(
                            onPressed: _isCompletedToday ? null : _markAsCompleted,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCompletedToday ? Colors.grey.shade800 : Colors.amber.shade700,
                              foregroundColor: _isCompletedToday ? Colors.grey.shade400 : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              _isCompletedToday ? Icons.check_circle : Icons.task_alt,
                              size: 24,
                            ),
                            label: Text(
                              _isCompletedToday ? 'Odmówione na dziś!' : 'Oznacz jako Odmówione (+1🔥)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3039),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber),
                                SizedBox(width: 12),
                                Text(
                                  'O Komplecie',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Kompleta to ostatnia modlitwa w ciągu dnia, odmawiana bezpośrednio przed udaniem się na spoczynek, nawet jeśli następuje to po północy.',
                              style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Zgodnie z tradycją chrześcijańską, jest to moment na rachunek sumienia, podziękowanie Bogu za miniony dzień i powierzenie Mu nadchodzącej nocy. Stanowi ona część Liturgii Godzin.',
                              style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Struktura modlitwy:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoPoint('Wstęp (Boże wejrzyj ku wspomożeniu memu)'),
                            _buildInfoPoint('Rachunek sumienia'),
                            _buildInfoPoint('Hymn'),
                            _buildInfoPoint('Psalmodia (jeden lub dwa psalmy)'),
                            _buildInfoPoint('Krótkie czytanie biblijne i responsorium'),
                            _buildInfoPoint('Kantyk Symeona (Teraz o Panie pozwól odejść...)'),
                            _buildInfoPoint('Modlitwa końcowa i błogosławieństwo'),
                            _buildInfoPoint('Antyfona do Najświętszej Maryi Panny'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70, height: 1.4)),
          ),
        ],
      ),
    );
  }
}