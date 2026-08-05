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

    final joinDate = user?.metadata.creationTime;
    final dateString = joinDate != null
        ? '${joinDate.day.toString().padLeft(2, '0')}.${joinDate.month.toString().padLeft(2, '0')}.${joinDate.year}'
        : 'Brak danych';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twój Profil'),
        centerTitle: true,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // Account Information (Email)
            Text(
              user?.email ?? 'Brak adresu e-mail',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Administrator Panel - visible only to a specific user
            if (['lobrusik@gmail.com', 'administracja@zpasjidoliturgii.pl'].contains(user?.email)) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom( 
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Panel Administratora'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],

            Text(
              'Ukończone lekcje',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Retrieving a user's progress in real time
            if (user != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  int trunkLessons = 0;
                  int spiritLessons = 0;
                  int serviceLessons = 0;
                  int dailyLessons = 0;

                  // Counting completed lessons if the user's data exists
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    final progressMap = data['progress'] as Map<String, dynamic>? ?? {};

                    progressMap.forEach((courseId, completedLessons) {
                      final lessonsCount = (completedLessons as List?)?.length ?? 0;

                      if (courseId.startsWith('trunk_')) {
                        trunkLessons += lessonsCount;
                      } else if (courseId.startsWith('soul_')) {
                        spiritLessons += lessonsCount;
                      } else if (courseId.startsWith('service_')) {
                        serviceLessons += lessonsCount;
                      } else if (courseId.startsWith('day_') || courseId == 'day') {
                        dailyLessons += lessonsCount;
                      }
                    });
                  }

                  // 2x2 grid of stats area
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildStatCard('Pień\n(Podstawy)', trunkLessons, Icons.park, Colors.brown.shade400, theme),
                      _buildStatCard('Gałąź\ndla Ducha', spiritLessons, Icons.spa, Colors.green.shade400, theme),
                      _buildStatCard('Gałąź\ndla Służby', serviceLessons, Icons.volunteer_activism, Colors.redAccent.shade200, theme),
                      _buildStatCard('Codzienne\nlekcje', dailyLessons, Icons.calendar_today, Colors.blue.shade400, theme),
                    ],
                  );
                },
              ),

            const SizedBox(height: 32),
            
            // Join date retrieved from the Google/Firebase account
            Text(
              'Data dołączenia: $dateString',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Function that draws a square statistics tile
  Widget _buildStatCard(String title, int count, IconData icon, Color iconColor, ThemeData theme) {
    return Card(
      elevation: 2,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}