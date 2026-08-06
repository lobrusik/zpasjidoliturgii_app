import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/news_carousel.dart';
import '../widgets/buy_coffee_button.dart';
import '../widgets/about_contact_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => context.go('/courses'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 24, 120, 24), 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF2D3039), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TWOJA DROGA DO LITURGII', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                            const SizedBox(height: 12),
                            Text('Tu zaczyna się Twoja pasja do Świętej Liturgii', style: theme.textTheme.headlineLarge),
                            const SizedBox(height: 12),
                            Text('Oglądaj, czytaj, rozwiązuj quizy i odkrywaj piękno Mszy Świętej.', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  'Rozpocznij naukę', 
                                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/ministrant.png',
                          height: 190, 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2D3039), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: userId == null 
                            ? Text('Zaloguj się, aby śledzić postępy', style: theme.textTheme.bodyMedium)
                            : StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                                builder: (context, snapshot) {
                                  int totalCompleted = 0;
                                  if (snapshot.hasData && snapshot.data!.exists) {
                                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                                    final progressMap = data['progress'] as Map<String, dynamic>? ?? {};
                                    for (var courseProgress in progressMap.values) {
                                      if (courseProgress is List) totalCompleted += courseProgress.length;
                                    }
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$totalCompleted', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                                      Text('ukończonych etapów', style: theme.textTheme.bodyMedium),
                                    ],
                                  );
                                },
                              ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text('Aktualności', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              const NewsCarousel(), 
              
              const SizedBox(height: 32),

              Text('Wybierz swoją drogę', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              _buildPathCard(
                context, 
                title: 'Drzewko wiedzy', 
                description: 'Podstawy, Msza Śwęta, miejsce święte, historia ministrantury. Ucz się we własnym tempie.', 
                imagePlaceholder: Icons.account_tree_outlined, 
                onTap: () => context.go('/courses')
              ),
              _buildPathCard(
                context, 
                title: 'Ścieżka psałterzysty', 
                description: 'Poznaj piękno muzyki kościelnej. Chorał, śpiew i schola.', 
                imagePlaceholder: Icons.library_music_outlined,
                onTap: () => context.go('/courses')
              ),
              _buildPathCard(
                context, 
                title: 'E-zbiórki ministranckie', 
                description: 'Poznaj najważniejsze zasady i fakty dotyczące służby przy ołtarzu.', 
                imagePlaceholder: Icons.groups,
                onTap: () => context.go('/courses')
              ),
              _buildPathCard(
                context, 
                title: 'Codziennie z liturgią', 
                description: 'Zobacz, zrozum, sprawdź się, zastosuj. 1 lekcja dziennie.', 
                imagePlaceholder: Icons.calendar_today_outlined, 
                onTap: () => context.go('/plan')
              ),

            const SizedBox(height: 32),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AboutAndContactSection(),
            ),

            const SizedBox(height: 32),

            const Center(child: BuyCoffeeButton(),),

            const SizedBox(height: 32),
              
              Center(
                child: Column(
                  children: [
                    Text(
                      'Święty Janie Chryzostomie,',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic, 
                        color: Colors.grey
                      ),
                    ),
                    Text(
                      'módl się za nami!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: theme.colorScheme.primary
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathCard(BuildContext context, {required String title, required String description, required IconData imagePlaceholder, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 100, width: double.infinity, color: const Color(0xFF2D3039), child: Icon(imagePlaceholder, size: 48, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(description, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}