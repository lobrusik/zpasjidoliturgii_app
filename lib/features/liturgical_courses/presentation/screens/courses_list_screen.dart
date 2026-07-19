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
            final courses = state.courses;
            
            courses.sort((a, b) => a.order.compareTo(b.order));

            return StreamBuilder<DocumentSnapshot>(
              stream: userId != null 
                ? FirebaseFirestore.instance.collection('users').doc(userId).snapshots()
                : const Stream.empty(),
              builder: (context, snapshot) {
                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final progressMap = userData['progress'] as Map<String, dynamic>? ?? {};

                // How many courses has the user started/completed
                int completedLevels = progressMap.keys.length;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Map heading
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
                      'Przejdź wszystkie poziomy. Każdy zawiera film, tekst i quiz.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$completedLevels / ${courses.length} ukończonych',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Path visualization
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

                    // Generating path blocks
                    ...List.generate(courses.length, (index) {
                      final course = courses[index];
                      
                      bool isUnlocked = index == 0 || progressMap.containsKey(courses[index - 1].id);
                      
                      // The current level is marked as completed if the user has made any progress in it
                      bool isCompleted = progressMap.containsKey(course.id);
                      
                      // If a level is unlocked but not started, that means it's the “Current” one
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
                      );
                    }),
                  ],
                );
              }
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  //  Draws a single tile on map
  Widget _buildLevelNode({
    required BuildContext context,
    required String courseId,
    required String title,
    required String subtitle,
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUnlocked,
  }) {
    final theme = Theme.of(context);
    
    // Variables that control the appearance based on state
    Color nodeColor;
    Widget leadingIcon;

    if (isCompleted) {
      nodeColor = const Color(0xFF2E7D32); // Green (check)
      leadingIcon = const Icon(Icons.check, color: Colors.white);
    } else if (isCurrent) {
      nodeColor = theme.colorScheme.primary; // Orange (To-do now)
      leadingIcon = Text('$levelNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18));
    } else {
      nodeColor = const Color(0xFF2D3039); // Dark grey (blocked)
      leadingIcon = const Icon(Icons.lock, color: Colors.grey, size: 20);
    }

    return Opacity(
      // Fading of Locked Elements
      opacity: isUnlocked ? 1.0 : 0.5, 
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            context.go('/courses/details/$courseId', extra: title);
          } else {
            // Reaction to clicking a locked tile
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukończ poprzedni poziom, aby odblokować ten.'),
                duration: Duration(seconds: 2),
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
            // Subtle backlighting of the frame to indicate the current level
            border: isCurrent 
              ? Border.all(color: theme.colorScheme.primary, width: 1) 
              : Border.all(color: const Color(0xFF2D3039), width: 1),
          ),
          child: Row(
            children: [
              // State icon
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
              
              // texts
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
              
              // Navigation arrow
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