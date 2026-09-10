import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_state.dart';
import 'psalms_menu_screen.dart';
import 'timeline_screen.dart'; 

class PathScreen extends StatefulWidget {
  final int initialTabIndex;

  const PathScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      key: ValueKey(widget.initialTabIndex),
      initialIndex: widget.initialTabIndex,
      length: 5, 
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: theme.scaffoldBackgroundColor,
              child: const TabBar(
                isScrollable: true,
                indicatorColor: Color(0xFF00965E),
                labelColor: Color(0xFF00965E),
                unselectedLabelColor: Colors.grey,
                labelPadding: EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(icon: Icon(Icons.menu_book), text: 'Liturgia'),
                  Tab(icon: Icon(Icons.music_note), text: 'Psałterz'),
                  Tab(icon: Icon(Icons.groups), text: 'E-zbiórka'),
                  Tab(icon: Icon(Icons.history), text: 'Ruch liturgiczny'),
                  Tab(icon: Icon(Icons.psychology), text: 'Rozważania'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLiturgyTree(context, theme, userId), 
                  _buildMusicTree(context, theme, userId), 
                  _buildCollectionTree(context, theme, userId), 
                  _buildHistoryTree(context, theme, userId), 
                  _buildReflectionsTree(context, theme, userId), 
                ] 
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String sectionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3039),
        title: const Text('Sekcja zablokowana', style: TextStyle(color: Colors.amber)),
        content: Text(
          'Aby odblokować moduł "$sectionName", musisz najpierw ukończyć WSZYSTKIE lekcje z Teologii Liturgii (główne drzewko)!',
          style: const TextStyle(color: Colors.white70, height: 1.4),
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

  bool _checkIfTrunkCompleted(List<dynamic> trunkCourses, Map<String, dynamic> progressMap) {
    if (trunkCourses.isEmpty) return false;
    int totalTrunkLessons = trunkCourses.length;
    int completedTrunkLessons = 0;
    for (var course in trunkCourses) {
      if (progressMap.containsKey(course.id)) {
        final courseProgress = progressMap[course.id];
        if (courseProgress is List && courseProgress.isNotEmpty) {
          completedTrunkLessons++;
        }
      }
    }
    return completedTrunkLessons >= totalTrunkLessons;
  }

  // === 1. LITURGICAL TREE === //
  Widget _buildLiturgyTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          courses.sort((a, b) => a.order.compareTo(b.order));

          final trunkCourses = courses.where((c) => c.category == 'trunk').toList();
          final liturgyCourses = courses.where((c) => c.category == 'liturgy').toList();
          final guideMassCourses = courses.where((c) => c.category == 'trunk_guide').toList();

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

                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź - Szkoła Liturgii',
                      description: areAdvancedBranchesUnlocked
                          ? 'Chcemy tutaj zgłębiać poszczególne elementy z dziejów liturgii.'
                          : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                      icon: Icons.local_fire_department,
                      branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFFFB300) : Colors.grey.shade800,
                      courses: liturgyCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedBranchesUnlocked,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 24),

                    _buildBranchSection(
                      context: context,
                      title: 'Gałąź - Przewodnik po Mszy Świętej',
                      description: areAdvancedBranchesUnlocked
                          ? 'Każdy element Mszy Świętej ma ogromne znaczenie - i właśnie je chcemy tu poznawać.'
                          : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                      icon: Icons.local_fire_department,
                      branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFFFB300) : Colors.grey.shade800,
                      courses: guideMassCourses,
                      progressMap: progressMap,
                      isBranchUnlocked: areAdvancedBranchesUnlocked,
                      isAdmin: isAdmin,
                    ),
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

   // === 2. MUSICAL TREE === //
  Widget _buildMusicTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          courses.sort((a, b) => a.order.compareTo(b.order));

          final trunkCourses = courses.where((c) => c.category == 'trunk').toList();
          final musicTrunkCourses = courses.where((c) => c.category == 'music_trunk').toList();

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};
              final bool isAdmin = userData['isAdmin'] ?? false;

              bool isMusicBranchesUnlocked = isAdmin || _checkIfTrunkCompleted(trunkCourses, progressMap);

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
                      'Nagrania psalmów są zawsze dostępne. Lekcje wymagają Teologii Liturgii.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
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

                    if (!isMusicBranchesUnlocked) ...[
                      GestureDetector(
                        onTap: () => _showLockedDialog(context, 'Ścieżka Psałterzysty (Lekcje)'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(
                                backgroundColor: Colors.white12,
                                radius: 30,
                                child: Icon(Icons.lock, color: Colors.redAccent, size: 32),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Lekcje zablokowane', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    SizedBox(height: 6),
                                    Text('Ukończ najpierw wszystkie lekcje z Teologii Liturgii.', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
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
                    ],
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

  // === 3. E-ZBIÓRKA === //
  Widget _buildCollectionTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          final trunkCourses = courses.where((c) => c.category == 'trunk').toList();
          final collectionCourses = courses.where((c) => c.category == 'collection_trunk').toList();
          final collectionBibleCourses = courses.where((c) => c.category == 'collection_bible').toList();
          final collectionSoulCourses = courses.where((c) => c.category == 'collection_soul').toList();
          final collectionHistoryCourses = courses.where((c) => c.category == 'collection_history').toList();
          final collectionBible2Courses = courses.where((c) => c.category == 'collection_bible2').toList();

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};
              final bool isAdmin = userData['isAdmin'] ?? false;

              bool isUnlocked = isAdmin || _checkIfTrunkCompleted(trunkCourses, progressMap);

              int completedCollectionTrunkLessons = 0;
              for (var course in collectionCourses) {
                if (progressMap.containsKey(course.id)) {
                  final courseProgress = progressMap[course.id];
                  if (courseProgress is List) {
                    completedCollectionTrunkLessons += courseProgress.length;
                  }
                }
              }

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
                      isUnlocked ? 'Formacja LSO i podział funkcji.' : '🔒 Zablokowane przez Teologię Liturgii.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUnlocked ? Colors.grey.shade400 : Colors.redAccent.shade100,
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (!isUnlocked) ...[
                      GestureDetector(
                        onTap: () => _showLockedDialog(context, 'E-zbiórka'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(
                                backgroundColor: Colors.white12,
                                radius: 30,
                                child: Icon(Icons.lock, color: Colors.redAccent, size: 32),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Moduł zablokowany', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    SizedBox(height: 6),
                                    Text('Ukończ najpierw wszystkie lekcje z Teologii Liturgii.', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
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
                      _buildBranchSection(
                        context: context,
                        title: 'Gałąź — Wprowadzenie do Pisma Świętego',
                        description: areAdvancedCollectionUnlocked ? 'Wprowadzenie w biblijne korzenie Eucharystii i liturgii, łącząc starotestamentowe zapowiedzi oraz historię zbawienia z żywym doświadczeniem wiary i modlitwy w Kościele.' : 'Zablokowane.',
                        icon: Icons.menu_book,
                        branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                        courses: collectionBibleCourses,
                        progressMap: progressMap,
                        isBranchUnlocked: areAdvancedCollectionUnlocked,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 48),
                      _buildBranchSection(
                        context: context,
                        title: 'Gałąź — Katecheza duchowościowa',
                        description: areAdvancedCollectionUnlocked ? 'Wprowadzenie w fundamenty chrześcijańskiej duchowości przez ukazanie nierozerwalnej jedności między modlitwą, życiem sakramentalnym, darami codzienności oraz łaską chrztu i pokuty.' : 'Zablokowane.',
                        icon: Icons.handshake,
                        branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                        courses: collectionSoulCourses,
                        progressMap: progressMap,
                        isBranchUnlocked: areAdvancedCollectionUnlocked,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 48),
                      _buildBranchSection(
                        context: context,
                        title: 'Gałąź — Historia ministrantury',
                        description: areAdvancedCollectionUnlocked ? 'Ukazanie fascynującej historii i teologii posługi ministranckiej – od starożytnych korzeni i czasów tonsury, przez kryzysy trydenckie i zaangażowanie chłopców, aż po soborową odnowę opartą na fundamencie chrztu świętego.' : 'Zablokowane.',
                        icon: Icons.account_balance,
                        branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                        courses: collectionHistoryCourses,
                        progressMap: progressMap,
                        isBranchUnlocked: areAdvancedCollectionUnlocked,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 48),
                      _buildBranchSection(
                        context: context,
                        title: 'Gałąź — Katecheza biblijna',
                        description: areAdvancedCollectionUnlocked ? 'Opis' : 'Zablokowane.',
                        icon: Icons.menu_book,
                        branchColor: areAdvancedCollectionUnlocked ? const Color(0xFFE91E63) : Colors.grey.shade800,
                        courses: collectionBible2Courses,
                        progressMap: progressMap,
                        isBranchUnlocked: areAdvancedCollectionUnlocked,
                        isAdmin: isAdmin,
                      ),
                    ],
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

  // === 4. HISTORICAL TREE === //
  Widget _buildHistoryTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          final trunkCourses = courses.where((c) => c.category == 'trunk').toList();

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};
              final bool isAdmin = userData['isAdmin'] ?? false;

              bool isHistoryUnlocked = isAdmin || _checkIfTrunkCompleted(trunkCourses, progressMap);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ruch liturgiczny',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zanim dokonano reformy liturgicznej, jej idea rozwijała się przez wiele dekad...',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () async {
                        if (!isHistoryUnlocked) {
                          _showLockedDialog(context, 'Ruch liturgiczny (Oś czasu) - postacie');
                          return;
                        }

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LiturgicalTimelineScreen(), 
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isHistoryUnlocked 
                              ? [const Color(0xFF8D6E63), const Color(0xFF4E342E)]
                              : [Colors.grey.shade800, Colors.grey.shade900],
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
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              radius: 30,
                              child: Icon(
                                isHistoryUnlocked ? Icons.timeline : Icons.lock, 
                                color: Colors.white, 
                                size: 32
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isHistoryUnlocked ? 'Oś czasu' : 'Oś czasu (Zablokowane)',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isHistoryUnlocked 
                                      ? 'Prześledź postacie odnowy liturgicznej\nod XIX wieku po dzisiejsze czasy.'
                                      : 'Ukończ najpierw Teologię Liturgii, aby odblokować ten moduł.',
                                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isHistoryUnlocked ? Icons.arrow_forward_ios : Icons.lock_outline, 
                              color: Colors.white54
                            ),
                          ],
                        ),
                      ),
                    ),
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

  // === 5. REFLECTIONS TREE === //
  Widget _buildReflectionsTree(BuildContext context, ThemeData theme, String? userId) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
        if (state is CoursesError) return Center(child: Text(state.message));

        if (state is CoursesLoaded) {
          final courses = state.courses;
          final trunkCourses = courses.where((c) => c.category == 'trunk').toList();
          final reflectionCourses = courses.where((c) => c.category == 'reflection_trunk' || c.category == 'reflection').toList();

          return StreamBuilder<DocumentSnapshot>(
            stream: userId != null 
              ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
              : const Stream.empty(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};
              final bool isAdmin = userData['isAdmin'] ?? false;

              bool isUnlocked = isAdmin || _checkIfTrunkCompleted(trunkCourses, progressMap);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Rozważania',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isUnlocked ? 'Głębsze refleksje duchowe i lekcje formacyjne.' : '🔒 Zablokowane. Wymagane ukończenie wszystkich lekcji z Teologii Liturgii.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUnlocked ? Colors.grey.shade400 : Colors.redAccent.shade100,
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (!isUnlocked) ...[
                      GestureDetector(
                        onTap: () => _showLockedDialog(context, 'Rozważania'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(
                                backgroundColor: Colors.white12,
                                radius: 30,
                                child: Icon(Icons.lock, color: Colors.redAccent, size: 32),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Moduł zablokowany', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    SizedBox(height: 6),
                                    Text('Ukończ wszystkie lekcje z Teologii Liturgii, aby odblokować ten materiał.', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildBranchSection(
                        context: context,
                        title: 'Rozważania Duchowe',
                        description: 'Interaktywne materiały formacyjne.',
                        icon: Icons.psychology,
                        branchColor: const Color(0xFF00965E),
                        courses: reflectionCourses,
                        progressMap: progressMap,
                        isBranchUnlocked: true,
                        isAdmin: isAdmin,
                      ),
                    ],
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
 
  // === VIEW HELPERS === //
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
        onTap: () async {
          if (isUnlocked) {
            await context.push('/courses/details/$courseId', extra: title);
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