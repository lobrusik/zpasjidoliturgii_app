import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_state.dart';
import 'psalms_menu_screen.dart';

class PathScreen extends StatelessWidget {
  final int initialTabIndex;

  const PathScreen({
    super.key,
    this.initialTabIndex = 0,
  });
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Tabs Management
    return DefaultTabController(
      key: ValueKey(initialTabIndex),
      initialIndex: initialTabIndex,
      length: 3, 
      child: Scaffold(
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
                  Tab(icon: Icon(Icons.music_note), text: 'Psałterz'),
                  Tab(icon: Icon(Icons.groups), text: 'E-zbiórka'),
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
          //final massCourses = courses.where((c) => c.category == 'mass').toList();
          //final placeCourses = courses.where((c) => c.category == 'place').toList();
          //final historyCourses = courses.where((c) => c.category == 'history').toList();
          final liturgyCourses = courses.where((c) => c.category == 'liturgy').toList();

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};
              final bool isAdmin = userData['isAdmin'] ?? false;

              int completedTrunkLessons = 0;
              for (var course in trunkCourses) {
                if (progressMap.containsKey(course.id)) {
                  final courseProgress = progressMap[course.id];
                  if (courseProgress is List) {
                    completedTrunkLessons += courseProgress.length;
                  }
                }
              }

              final int requiredLessons = 8;
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
                      'Najpierw opanuj teologię liturgii. Potem otworzą się gałęzie.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    // TRUNK
                    _buildBranchSection(
                      context: context,
                      title: 'Teologia Liturgii',
                      description: 'Obowiązkowe dla wszystkich.',
                      icon: Icons.eco,
                      branchColor: const Color(0xFF4CAF50),
                      courses: trunkCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: true,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 24),

                    /* branch 1
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
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 24),*/

                    /* branch 2
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
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 24),*/

                    /* branch 3
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
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 48),*/

                    //branch - liturgy
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź - Szkoła Liturgii',
                      description: areAdvancedBranchesUnlocked
                          ? 'Chcemy tutaj zgłębiać poszczególne elementy z dziejów liturgii oraz z jej teologii, tak aby jeszcze głębiej w nią wniknąć.'
                          : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                      icon: Icons.local_fire_department,
                      branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFFFB300) : Colors.grey.shade800,
                      courses: liturgyCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedBranchesUnlocked,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 24),
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
              final bool isAdmin = userData['isAdmin'] ?? false;

              int completedMusicTrunkLessons = 0;
              for (var course in musicTrunkCourses) {
                if (progressMap.containsKey(course.id)) {
                  final courseProgress = progressMap[course.id];
                  if (courseProgress is List) {
                    completedMusicTrunkLessons += courseProgress.length;
                  }
                }
              }

              // 5 lesson - you can move on
              final int requiredMusicLessons = 5; 
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
                            'Ścieżka Psałterzysty',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Opanuj podstawy psałterzysty, by odblokować zaawansowane gałęzie.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PsalmsMenuScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white24,
                              radius: 30,
                              child: Icon(Icons.headphones, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Melodie Psalmów',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Nagrania na cały rok liturgiczny.\nDostępne w każdej chwili!',
                                    style: TextStyle(fontSize: 13, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // MUSICAL TRUNK
                    _buildBranchSection(
                      context: context,
                      title: 'Pień — Podstawy Psałterzysty',
                      description: 'Rytm, nuty i wprowadzenie do śpiewu. Obowiązkowe.',
                      icon: Icons.music_note,
                      branchColor: const Color(0xFF2196F3),
                      courses: musicTrunkCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: true,
                      isAdmin: isAdmin,
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
                      isAdmin: isAdmin,
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
          final collectionBibleCourses = courses.where((c) => c.category == 'collection_bible').toList();
          final collectionSoulCourses = courses.where((c) => c.category == 'collection_soul').toList();
          final collectionHistoryCourses = courses.where((c) => c.category == 'collection_history').toList();
          //final collectionTriduumCourses = courses.where((c) => c.category == 'collection_triduum').toList();
          

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};
              final bool isAdmin = userData['isAdmin'] ?? false;

              int completedCollectionTrunkLessons = 0;
              for (var course in collectionCourses) {
                if (progressMap.containsKey(course.id)) {
                  final courseProgress = progressMap[course.id];
                  if (courseProgress is List) {
                    completedCollectionTrunkLessons += courseProgress.length;
                  }
                }
              }

              // 4 lesson - you can move on
              final int requiredCollectionLessons = 4; 
              bool areAdvancedCollectionUnlocked = completedCollectionTrunkLessons >= requiredCollectionLessons;

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

                    //TRUNK
                    _buildBranchSection(
                      context: context,
                      title: 'Podstawy liturgii',
                      description: 'Obowiązkowe dla wszystkich',
                      icon: Icons.groups,
                      branchColor: const Color(0xFFFF9800),
                      courses: collectionCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: true,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 48),

                    //  COLLECTION BRANCH - BIBLE
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź — Wprowadzenie do Pisma Świętego',
                      description: areAdvancedCollectionUnlocked
                          ? 'Co wspólnego ma Pismo Święte z Eucharystią.'
                          : 'Zablokowane. Ukończono $completedCollectionTrunkLessons/$requiredCollectionLessons podstaw.',
                      icon: Icons.menu_book,
                      branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                      courses: collectionBibleCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedCollectionUnlocked,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 48),

                    //  COLLECTION BRANCH - SOUL
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź — Katecheza duchowościowa o liturgii',
                      description: areAdvancedCollectionUnlocked
                          ? 'Duchowość a służba.'
                          : 'Zablokowane. Ukończono $completedCollectionTrunkLessons/$requiredCollectionLessons podstaw.',
                      icon: Icons.account_balance,
                      branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                      courses: collectionSoulCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedCollectionUnlocked,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 48),

                    //  COLLECTION BRANCH - The History of Altar Servers
                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź — Historia ministrantury',
                      description: areAdvancedCollectionUnlocked
                          ? 'Skąd się wzięli ministranci?'
                          : 'Zablokowane. Ukończono $completedCollectionTrunkLessons/$requiredCollectionLessons podstaw.',
                      icon: Icons.handshake,
                      branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                      courses: collectionHistoryCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedCollectionUnlocked,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 48),

                    //  COLLECTION BRANCH - Triduum - unlock 10.02.2027
                    // _buildBranchSection(
                    //   context: context,
                    //   title: 'Gałąź — Triduum Paschalne (bonus)',
                    //   description: areAdvancedCollectionUnlocked
                    //       ? 'Kompleksowe przygotowanie do najkrótszego okresu liturgicznego.'
                    //       : 'Zablokowane. Ukończono $completedCollectionTrunkLessons/$requiredCollectionLessons podstaw.',
                    //   icon: Icons.cloud,
                    //   branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                    //   courses: collectionTriduumCourses,
                    //   progressMap: progressMap,
                    //   isBranchUnlocked: areAdvancedCollectionUnlocked,
                    //   isAdmin: isAdmin,
                    // ),
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
    required bool isAdmin,
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
            bool isUnlocked = isAdmin || (isBranchUnlocked && (index == 0 || progressMap.containsKey(courses[index - 1].id)));
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