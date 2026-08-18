import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CompletoriumScreen extends StatelessWidget {
  const CompletoriumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'pl_PL').format(DateTime.now());

    final List<Map<String, String>> completoriumDays = [
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
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
              const SizedBox(height: 8),
              Text(
                'Modlitwa na zakończenie dnia.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 24),
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
                      context.push(
                        '/completorium/details',
                        extra: {
                          'title': day['title']!,
                          'url': day['url']!,
                        },
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}