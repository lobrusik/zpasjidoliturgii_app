import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_state.dart';

class CoursesListScreen extends StatelessWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
          if (state is CoursesError) return Center(child: Text(state.message));

          if (state is CoursesLoaded) {
            final mainCourses = state.courses.where((c) => c.category == 'trunk').toList();
            mainCourses.sort((a, b) => a.order.compareTo(b.order));

            final reflectionCourses = state.courses.where((c) => c.category == 'reflection').toList();
            reflectionCourses.sort((a, b) => a.order.compareTo(b.order));

            return StreamBuilder<DocumentSnapshot>(
              stream: userId != null 
                ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
                : const Stream.empty(),
              builder: (context, snapshot) {
                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};

                int completedLevels = mainCourses.where((course) => progressMap.containsKey(course.id)).length;
                
                bool areAllTrunkCoursesCompleted = mainCourses.isNotEmpty && 
                    mainCourses.every((course) => progressMap.containsKey(course.id));

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Twoja droga do poznania liturgii',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Przejdź wszystkie poziomy. Każdy zawiera materiały i zadania sprawdzające wiedzę.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$completedLevels / ${mainCourses.length} ukończonych',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/mapa2.jpeg',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...List.generate(mainCourses.length, (index) {
                      final course = mainCourses[index];
                      bool isUnlocked = index == 0 || progressMap.containsKey(mainCourses[index - 1].id);
                      bool isCompleted = progressMap.containsKey(course.id);
                      bool isCurrent = isUnlocked && !isCompleted;

                      return _buildLevelNode(
                        context: context,
                        courseId: course.id,
                        title: course.title,
                        subtitle: course.description,
                        levelNumber: index + 1,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isUnlocked: isUnlocked,
                        lockedMessage: 'Ukończ poprzedni poziom, aby odblokować ten.',
                      );
                    }),

                    if (reflectionCourses.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Rozważania o liturgii',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        areAllTrunkCoursesCompleted
                            ? 'Wszystkie rozważania odblokowane! Możesz je przechodzić w dowolnej kolejności.'
                            : 'Ukończ wszystkie poziomy Teologii liturgii powyżej, aby odblokować tę sekcję.',
                        style: TextStyle(
                          color: areAllTrunkCoursesCompleted ? Colors.white70 : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...List.generate(reflectionCourses.length, (index) {
                        final course = reflectionCourses[index];
                        bool isUnlocked = areAllTrunkCoursesCompleted;
                        bool isCompleted = progressMap.containsKey(course.id);
                        bool isCurrent = isUnlocked && !isCompleted;

                        return _buildLevelNode(
                          context: context,
                          courseId: course.id,
                          title: course.title,
                          subtitle: course.description,
                          levelNumber: index + 1,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          isUnlocked: isUnlocked,
                          lockedMessage: 'Najpierw ukończ wszystkie poziomy z głównego pnia (Teologia liturgii)!',
                        );
                      }),
                    ],
                  ],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLevelNode({
    required BuildContext context,
    required String courseId,
    required String title,
    required String subtitle,
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUnlocked,
    required String lockedMessage,
  }) {
    final theme = Theme.of(context);
    
    Color nodeColor;
    Widget leadingIcon;

    if (isCompleted) {
      nodeColor = const Color(0xFF2E7D32); // Zielony (ukończone)
      leadingIcon = const Icon(Icons.check, color: Colors.white);
    } else if (isCurrent) {
      nodeColor = theme.colorScheme.primary; // Kolor główny (do zrobienia)
      leadingIcon = Text('$levelNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18));
    } else {
      nodeColor = const Color(0xFF2D3039); // Ciemnoszary (zablokowane)
      leadingIcon = const Icon(Icons.lock, color: Colors.grey, size: 20);
    }

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5, 
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            context.go('/courses/details/$courseId', extra: title);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lockedMessage),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isCurrent 
              ? Border.all(color: theme.colorScheme.primary, width: 1) 
              : Border.all(color: const Color(0xFF2D3039), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: leadingIcon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isUnlocked ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked ? subtitle : 'Zablokowane',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: isUnlocked ? theme.colorScheme.primary : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}