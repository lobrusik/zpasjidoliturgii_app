import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twój Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj się',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User information
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Brak adresu e-mail',
              style: theme.textTheme.titleLarge,
            ),
            
            const SizedBox(height: 24),

            if (user?.email == 'lobrusik@gmail.com') ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Panel Administratora'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

           
            const SizedBox(height: 48),
            
            // STATISTICS 
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Twoje postępy w kursach',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // Rendering a list of courses with progress bars
            _buildProgressList(context, user?.uid),
          ],
        ),
      ),
    );
  }

  // A function that retrieves a list of all courses
  Widget _buildProgressList(BuildContext context, String? userId) {
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, courseSnapshot) {
        if (!courseSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final courses = courseSnapshot.data!.docs;
        if (courses.isEmpty) {
          return const Text('Brak dostępnych kursów do śledzenia.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _CourseProgressCard(
              courseId: course.id,
              courseTitle: course['title'] ?? 'Nieznany kurs',
              userId: userId,
            );
          },
        );
      },
    );
  }
}

// INTERNAL WIDGET: Single course card with a dynamic progress bar
class _CourseProgressCard extends StatelessWidget {
  final String courseId;
  final String courseTitle;
  final String userId;

  const _CourseProgressCard({
    required this.courseId,
    required this.courseTitle,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Request for all materials from a specific course
    final totalPlansStream = FirebaseFirestore.instance
        .collection('study_plans')
        .where('courseId', isEqualTo: courseId)
        .snapshots();

    // Request for a user profile (with saved progress)
    final userProgressStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: totalPlansStream,
              builder: (context, plansSnapshot) {
                if (!plansSnapshot.hasData) return const LinearProgressIndicator();
                
                final totalPlans = plansSnapshot.data!.docs.length;
                
                if (totalPlans == 0) {
                  return const Text('Brak materiałów w tym kursie', style: TextStyle(color: Colors.grey));
                }

                // How many lessons has the user completed
                return StreamBuilder<DocumentSnapshot>(
                  stream: userProgressStream,
                  builder: (context, userSnapshot) {
                    int completedPlans = 0;
                    
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      final data = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                      final progressMap = data['progress'] as Map<String, dynamic>? ?? {};
                      final courseProgress = progressMap[courseId] as List<dynamic>? ?? [];
                      completedPlans = courseProgress.length;
                    }

                    // Protection against logical errors
                    if (completedPlans > totalPlans) completedPlans = totalPlans;
                    
                    final double progressPercent = totalPlans > 0 ? (completedPlans / totalPlans) : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ukończono $completedPlans z $totalPlans etapów',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '${(progressPercent * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}