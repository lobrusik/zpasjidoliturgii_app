import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
//import '../../../liturgical_courses/presentation/widgets/temp_uploader.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    final bool isAdmin = ['lobrusik@gmail.com', 'administracja@zpasjidoliturgii.pl', 'dawidmakowski28@gmail.com'].contains(user?.email);

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
            if (isAdmin) ...[
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

            //const TempAddPsalmsButton(), //adding psalms
 
            Text(
              'Twoje statystyki',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Retrieving a user's progress in real time
            if (user != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {

                  //liturgical tree
                  int liturgicalLessons = 0;
                  // int massLessons = 0;
                  // int placeLessons = 0;
                  // int historyLessons = 0;

                  //musical tree
                  int musicLessons = 0;

                  //e-zbiorka tree
                  int collectionLessons = 0;

                  //daily lessons
                  int completoriumStreak = 0;

                  // Counting completed lessons if the user's data exists
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    completoriumStreak = data['completoriumStreak'] ?? 0;
                    final progressMap = data['progress'] as Map<String, dynamic>? ?? {};

                    progressMap.forEach((courseId, completedLessons) {
                      final lessonsCount = (completedLessons as List?)?.length ?? 0;

                      //liturgical tree
                      if (courseId.startsWith('trunk_')) {
                        liturgicalLessons += lessonsCount;
                      }
                      // else if (courseId.startsWith('mass_')) {
                      //   massLessons += lessonsCount;
                      // } else if (courseId.startsWith('place_')) {
                      //   placeLessons += lessonsCount;
                      // }else if (courseId.startsWith('history_')) {
                      //   historyLessons += lessonsCount;
                      // } 

                      //music tree
                      else if (courseId.startsWith('music_')) {
                        musicLessons += lessonsCount;
                      }
                      //e-zbiorki tree
                      else if (courseId.startsWith('collection_')) {
                        collectionLessons += lessonsCount;
                      }
                      // //daily lessons
                      // else if (courseId.startsWith('day_') || courseId == 'day') {
                      //   dailyLessons += lessonsCount;
                      // }
                    });
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      //liturgical
                      _buildStatCard('Teologia\nliturgii', liturgicalLessons, Icons.park, Colors.brown.shade400, theme),
                      // _buildStatCard('Msza św.\nkrok po kroku', massLessons, Icons.spa, Colors.green.shade400, theme),
                      // _buildStatCard('Miejsce\nświęte', placeLessons, Icons.church, Colors.redAccent.shade200, theme),
                      // _buildStatCard('Historia\nministrantury', historyLessons, Icons.history_edu, Colors.brown.shade400, theme),
                      //musical
                      _buildStatCard('Ścieżka\nPsałterzysty', musicLessons, Icons.music_note, Colors.blue.shade400, theme),
                      //e-zbiorki
                      _buildStatCard('E-zbiórki\n(Odprawy)', collectionLessons, Icons.groups, Colors.orange.shade400, theme),
                      //daily
                      //_buildStatCard('Codzienne\nlekcje', dailyLessons, Icons.calendar_today, Colors.blue.shade400, theme),
                      //completorium
                      _buildStatCard('Kompleta', completoriumStreak, Icons.nightlight_round, Colors.amber.shade400, theme),
                      
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