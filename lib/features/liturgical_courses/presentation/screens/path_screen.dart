import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_state.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
          if (state is CoursesError) return Center(child: Text(state.message));

          if (state is CoursesLoaded) {
            final courses = state.courses;
            courses.sort((a, b) => a.order.compareTo(b.order));

            final trunkCourses = courses.where((c) => c.category == 'trunk').toList();
            final serviceCourses = courses.where((c) => c.category == 'service').toList();
            final spiritCourses = courses.where((c) => c.category == 'spirit').toList();

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

                      // PIEŃ
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

                      _buildBranchSection(
                        context: context,
                        title: 'Gałąź — Dla Służby',
                        description: areAdvancedBranchesUnlocked
                            ? 'Rubryki, naczynia, szaty. Dla ministrantów.'
                            : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                        icon: Icons.local_fire_department,
                        branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFFFB300) : Colors.grey.shade800,
                        courses: serviceCourses,
                        progressMap: progressMap,
                        isBranchUnlocked: areAdvancedBranchesUnlocked,
                      ),
                      const SizedBox(height: 24),

                      _buildBranchSection(
                        context: context,
                        title: 'Gałąź — Dla Ducha',
                        description: areAdvancedBranchesUnlocked
                            ? 'Teologia i znaczenie symboli.'
                            : 'Zablokowane. Ukończono $completedTrunkLessons/$requiredLessons podstaw.',
                        icon: Icons.air,
                        branchColor: areAdvancedBranchesUnlocked ? const Color(0xFFAB47BC) : Colors.grey.shade800,
                        courses: spiritCourses,
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
      ),
    );
  }

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