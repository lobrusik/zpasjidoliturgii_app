import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_state.dart';
import '../../../game/liturgical_hangman.dart';
import '../../../game/liturgical_word_search.dart';

class GameMenuOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget widget;
  final String? Function(Map<String, dynamic> userData)? progressBuilder;

  GameMenuOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.widget,
    this.progressBuilder,
  });
}

class GamesPanelScreen extends StatelessWidget {
  const GamesPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final games = [
      GameMenuOption(
        title: 'Zgadnij słowo',
        description: 'Litera po literze odkryj termin liturgiczny.',
        icon: Icons.spellcheck,
        color: Colors.blueAccent,
        widget: const LiturgicalHangman(),
        progressBuilder: (userData) {
          final levels = userData['hangmanLevelsCompleted'] ?? 0;
          if (levels > 0) {
            return 'Ukończono: $levels';
          }
          return 'Brak postępu'; 
        },
      ),
      GameMenuOption(
        title: 'Wykreślanka',
        description: 'Znajdź ukryte liturgiczne słowa.',
        icon: Icons.find_in_page_outlined,
        color: Colors.greenAccent,
        widget: const LiturgicalWordSearch(),
        progressBuilder: (userData) {
          final levels = userData['wordSearchLevelsCompleted'] ?? 0;
          if (levels > 0) {
            return 'Ukończono: $levels';
          }
          return 'Brak postępu'; 
        },
      ),
    ];

    CoursesBloc? coursesBloc;
    try {
      coursesBloc = context.read<CoursesBloc>();
    } catch (e) {
      debugPrint('CoursesBloc nie jest dostępny - ukrywam baner postępu');
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gry', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (userId != null && coursesBloc != null)
              BlocBuilder<CoursesBloc, CoursesState>(
                bloc: coursesBloc,
                builder: (context, state) {
                  if (state is CoursesLoaded) {
                    final mainCourses = state.courses.where((c) => c.category == 'trunk').toList();
                    mainCourses.sort((a, b) => a.order.compareTo(b.order));

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();

                        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                        final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};

                        final notCompleted = mainCourses.where((course) => !progressMap.containsKey(course.id));
                        final nextCourse = notCompleted.isNotEmpty ? notCompleted.first : null;

                        if (nextCourse != null) {
                          return _buildNextLevelBanner(theme, nextCourse.title);
                        } else if (mainCourses.isNotEmpty) {
                          return _buildNextLevelBanner(theme, "Wszystkie etapy ukończone! 🎉");
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  
                  return Material(
                    color: const Color(0xFF2D3039),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => game.widget),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: game.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                game.icon,
                                size: 36,
                                color: game.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              game.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                game.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextLevelBanner(ThemeData theme, String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3039),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.route, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Graj i ucz się na swój następny poziom:', 
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)
                ),
                const SizedBox(height: 4),
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}