import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_state.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});
  //TEMPRORARY
  Future<void> _addCollectionTestData(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('courses').doc('collection_trunk_01').set({
        'category': 'collection_trunk',
        'description': 'Opis pierwszej e-zbiórki ministranckiej.',
        'isLocked': false,
        'order': 1,
        'thumbnailUrl': 'https://youtu.be/gogOnpwI1SE?si=dSssZHxrpeWzX73-', 
        'title': 'Lekcja 1 - Odprawa i podział funkcji',
      });

      await FirebaseFirestore.instance.collection('study_plans').doc('collection_trunk_01').set({
        'courseId': 'collection_trunk_01',
        'dayStage': 1,
        'liturgicalContent': 'Zbiórka to najważniejszy moment przygotowania do służby. To wtedy ustalamy podział funkcji, modlimy się i wyciszamy przed wyjściem do ołtarza.',
        'quiz': [
          {
            'correctAnswerIndex': 1,
            'explanation': 'Zbiórka przed Mszą Świętą to czas na organizację, podział funkcji i modlitwę, a nie spotkanie towarzyskie.',
            'options': [
              'Czasem na pogawędki z kolegami', 
              'Spotkaniem organizacyjnym i modlitewnym przed służbą', 
              'Zbiórką pieniędzy na tacę', 
              'Obowiązkową karą dla spóźnialskich'
            ]
          },
          {
            'correctAnswerIndex': 0,
            'explanation': 'Ministrant powinien pojawić się w zakrystii zazwyczaj 15 minut przed rozpoczęciem liturgii, aby spokojnie się ubrać i przygotować.',
            'options': [
              '15 minut przed Mszą', 
              'Dokładnie o godzinie rozpoczęcia Mszy', 
              'Podczas dzwonka na wejście', 
              'Godzinę po Mszy'
            ]
          },
          {
            'correctAnswerIndex': 2,
            'explanation': 'Podziałem funkcji zazwyczaj zajmuje się ceremoniarz, prezes lub najstarszy animator w porozumieniu z księdzem.',
            'options': [
              'Osoba, która przyjdzie ostatnia', 
              'Najmłodszy ministrant', 
              'Ceremoniarz lub ksiądz opiekun', 
              'Kościelny'
            ]
          },
          {
            'correctAnswerIndex': 3,
            'explanation': 'Każda zbiórka i służba powinny zaczynać się i kończyć krótką modlitwą (np. "Króluj nam Chryste").',
            'options': [
              'Śpiewem hymnu państwowego', 
              'Sprawdzeniem obecności w zeszycie', 
              'Złożeniem ofiary', 
              'Wspólną modlitwą (przed i po służbie)'
            ]
          },
          {
            'correctAnswerIndex': 1,
            'explanation': 'Wyciszenie w zakrystii pomaga w skupieniu i duchowym przygotowaniu do spotkania z Bogiem w liturgii.',
            'options': [
              'Można głośno rozmawiać i żartować', 
              'Należy zachować ciszę i skupienie', 
              'Trzeba cały czas śpiewać', 
              'Należy dyskutować o podziale funkcji'
            ]
          },
          {
            'correctAnswerIndex': 0,
            'explanation': 'E-zbiórka w naszej aplikacji to forma wirtualnego spotkania, sprawdzania wiedzy i formacji poza murami parafii.',
            'options': [
              'Formuła nauki i formacji ministranckiej online', 
              'Aplikacja do zbierania datków', 
              'Gra komputerowa o księżach', 
              'Strona z planem lekcji'
            ]
          },
          {
            'correctAnswerIndex': 2,
            'explanation': 'Po zakończeniu liturgii i modlitwie po Mszy, ministranci starannie składają szaty liturgiczne i odkładają je na miejsce.',
            'options': [
              'Rzucają szaty na krzesło i wybiegają', 
              'Zostawiają wszystko kościelnemu', 
              'Starannie składają komże lub alby na miejsce', 
              'Zabierają szaty do prania za każdym razem'
            ]
          }
        ]
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SUKCES: Utworzono poprawną lekcję E-zbiórki LSO!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('BŁĄD: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Tabs Management
    return DefaultTabController(
      length: 3, 
      child: Scaffold(

        //TEMPRORARY
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addCollectionTestData(context),
          backgroundColor: Colors.red, 
          icon: const Icon(Icons.add_to_drive, color: Colors.white),
          label: const Text('Dodaj 7 pytań (Odprawa LSO)', style: TextStyle(color: Colors.white)),
        ),

        body: Column(
          children: [
            // Tabs bar at the top of the screen
            Container(
              color: theme.scaffoldBackgroundColor,
              child: const TabBar(
                indicatorColor: Color(0xFF00965E),
                labelColor: Color(0xFF00965E),
                unselectedLabelColor: Colors.grey,
                labelPadding: EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  Tab(icon: Icon(Icons.menu_book), text: 'Liturgia'),
                  Tab(icon: Icon(Icons.music_note), text: 'Muzyka'),
                  Tab(icon: Icon(Icons.volunteer_activism), text: 'E-zbiórka'),
                ],
              ),
            ),

            // Tabs Contents
            Expanded(
              child: TabBarView(
                children: [
                  _buildLiturgyTree(context, theme, userId), //liturgical tree
                  _buildMusicTree(context, theme, userId), // musical tree
                  _buildCollectionTree(context, theme, userId), //e-zbiorka
                ] 
              ),
            ),
          ],
        ),
      ),
    );
  }

  //LITURGICAL TREE
  Widget _buildLiturgyTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          courses.sort((a, b) => a.order.compareTo(b.order));

          final trunkCourses = courses.where((c) => c.category == 'trunk').toList();
          final massCourses = courses.where((c) => c.category == 'mass').toList();
          final placeCourses = courses.where((c) => c.category == 'place').toList();
          final historyCourses = courses.where((c) => c.category == 'history').toList();

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};

              int completedTrunkLessons = 0;
              for (var course in trunkCourses) {
                if (progressMap.containsKey(course.id)) {
                  final courseProgress = progressMap[course.id];
                  if (courseProgress is List) {
                    completedTrunkLessons += courseProgress.length;
                  }
                }
              }

              final int requiredLessons = 10;
              bool areAdvancedBranchesUnlocked = completedTrunkLessons >= requiredLessons;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌳', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Drzewko wiedzy',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Najpierw opanuj Pień (Podstawy). Potem otworzą się gałęzie dla Służby i dla Ducha.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    // TRUNK
                    _buildBranchSection(
                      context: context,
                      title: 'Pień — Podstawy',
                      description: 'Co dzieje się na Mszy. Obowiązkowe dla wszystkich.',
                      icon: Icons.eco,
                      branchColor: const Color(0xFF4CAF50),
                      courses: trunkCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: true,
                    ),
                    const SizedBox(height: 24),

                    // branch 1
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź - Msza Święta krok oo kroku',
                      description: areAdvancedBranchesUnlocked
                          ? 'Opis gałęzi Mass.'
                          : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                      icon: Icons.local_fire_department,
                      branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFFFB300) : Colors.grey.shade800,
                      courses: massCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedBranchesUnlocked,
                    ),
                    const SizedBox(height: 24),

                    // branch 2
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź — Przewodnik po miejscu świętym',
                      description: areAdvancedBranchesUnlocked
                          ? 'Opis gałęzi Place.'
                          : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                      icon: Icons.air,
                      branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFAB47BC) : Colors.grey.shade800,
                      courses: placeCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedBranchesUnlocked,
                    ),
                    const SizedBox(height: 24),

                    // branch 1
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź - Historia ministrantury',
                      description: areAdvancedBranchesUnlocked
                          ? 'Opis gałęzi History.'
                          : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                      icon: Icons.local_fire_department,
                      branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFFFB300) : Colors.grey.shade800,
                      courses: historyCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedBranchesUnlocked,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  //MUSICAL TREE
  Widget _buildMusicTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          courses.sort((a, b) => a.order.compareTo(b.order));

          final musicTrunkCourses = courses.where((c) => c.category == 'music_trunk').toList();
          final musicAdvancedCourses = courses.where((c) => c.category == 'music_choir').toList(); // other categories

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};

              int completedMusicTrunkLessons = 0;
              for (var course in musicTrunkCourses) {
                if (progressMap.containsKey(course.id)) {
                  final courseProgress = progressMap[course.id];
                  if (courseProgress is List) {
                    completedMusicTrunkLessons += courseProgress.length;
                  }
                }
              }

              // 10 lesson - you can move on
              final int requiredMusicLessons = 10; 
              bool areAdvancedMusicUnlocked = completedMusicTrunkLessons >= requiredMusicLessons;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎵', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ścieżka Muzyczna',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Opanuj podstawy muzyki kościelnej, by odblokować zaawansowane gałęzie.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    // MUSICAL TRUNK
                    _buildBranchSection(
                      context: context,
                      title: 'Pień — Podstawy Muzyki',
                      description: 'Rytm, nuty i wprowadzenie do śpiewu. Obowiązkowe.',
                      icon: Icons.music_note,
                      branchColor: const Color(0xFF2196F3),
                      courses: musicTrunkCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: true,
                    ),
                    const SizedBox(height: 24),

                    //  MUSIC BRANCH
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź — Tu będzie nazwa gałęzi',
                      description: areAdvancedMusicUnlocked
                          ? 'Tu będzie opis gałęzi.'
                          : 'Zablokowane. Ukończono $completedMusicTrunkLessons/$requiredMusicLessons podstaw.',
                      icon: Icons.record_voice_over,
                      branchColor: areAdvancedMusicUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                      courses: musicAdvancedCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedMusicUnlocked,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  //E-ZBIÓRKA
  Widget _buildCollectionTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          courses.sort((a, b) => a.order.compareTo(b.order));

          final collectionCourses = courses.where((c) => c.category == 'collection_trunk').toList();
          

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📱', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'E-zbiórka',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formacja LSO, podział funkcji i spotkania online.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    _buildBranchSection(
                      context: context,
                      title: 'Odprawy i Formacja',
                      description: 'Materiały i quizy na e-zbiórki ministranckie.',
                      icon: Icons.groups,
                      branchColor: const Color(0xFFFF9800),
                      courses: collectionCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: true,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  //VIEW HELPERS
  Widget _buildBranchSection({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color branchColor,
    required List<dynamic> courses,
    required Map<String, dynamic> progressMap,
    required bool isBranchUnlocked,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: branchColor, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: branchColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: isBranchUnlocked ? Colors.white : Colors.grey.shade500
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description, 
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isBranchUnlocked ? Colors.grey.shade400 : Colors.redAccent.shade100
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (courses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text('Wkrótce pojawią się tu materiały...', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          )
        else
          ...List.generate(courses.length, (index) {
            final course = courses[index];
            bool isUnlocked = isBranchUnlocked && (index == 0 || progressMap.containsKey(courses[index - 1].id));
            bool isCompleted = progressMap.containsKey(course.id);
            bool isCurrent = isUnlocked && !isCompleted;

            return _buildCourseNode(
              context: context,
              courseId: course.id,
              title: course.title,
              subtitle: course.description,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isUnlocked: isUnlocked,
            );
          }),
      ],
    );
  }

  Widget _buildCourseNode({
    required BuildContext context,
    required String courseId,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUnlocked,
  }) {
    final theme = Theme.of(context);
    
    Widget trailingWidget;
    if (isCompleted) {
      trailingWidget = const Icon(Icons.check, color: Color(0xFF4CAF50));
    } else if (isCurrent) {
      trailingWidget = const Icon(Icons.arrow_forward, color: Colors.orange);
    } else {
      trailingWidget = const Icon(Icons.lock, color: Colors.grey, size: 20);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22242B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.orange.withOpacity(0.5) : const Color(0xFF2D3039),
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isUnlocked ? Colors.white : Colors.grey.shade600,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isUnlocked ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
        trailing: trailingWidget,
        onTap: () {
          if (isUnlocked) {
            context.push('/courses/details/$courseId', extra: title);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zablokowane. Opanuj wymagane podstawy!')),
            );
          }
        },
      ),
    );
  }
}