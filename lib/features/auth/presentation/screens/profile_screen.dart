import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
import '../../../../app/settings_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showDeleteAccountDialog(BuildContext context, User user) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Usuń konto'),
          content: const Text(
            'Czy na pewno chcesz trwale usunąć swoje konto oraz wszystkie postępy? Tej operacji nie można cofnąć.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Usuń trwale', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  await user.delete();
                  
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    
                    String errorMessage = 'Wystąpił błąd: ${e.message}';
                    if (e.code == 'requires-recent-login') {
                      errorMessage = 'Ze względów bezpieczeństwa musisz wylogować się i zalogować ponownie, aby usunąć konto.';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    final bool isAdmin = ['lobrusik@gmail.com', 'administracja@zpasjidoliturgii.pl', 'dawidmakowski28@gmail.com', 'lobrusik.rekrutacja@op.pl'].contains(user?.email);

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

                  //musical tree
                  int musicLessons = 0;

                  //e-zbiorka tree
                  int collectionLessons = 0;

                  //history tree
                  int historyLessons = 0;
                  
                  //reflection
                  int reflectionLessons = 0;

                  //daily lessons
                  int completoriumStreak = 0;
                  
                  //hangman game
                  int hangmanLevelsCompleted = 0; 

                  // Counting completed lessons if the user's data exists
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    completoriumStreak = data['completoriumStreak'] ?? 0;
                    
                    // Appeal of the Game Result
                    hangmanLevelsCompleted = data['hangmanLevelsCompleted'] ?? 0; 

                    final progressMap = data['progress'] as Map<String, dynamic>? ?? {};

                    progressMap.forEach((courseId, completedLessons) {
                      final lessonsCount = (completedLessons as List?)?.length ?? 0;

                      //liturgical tree
                      if (courseId.startsWith('trunk_')) {
                        liturgicalLessons += lessonsCount;
                      }
                      //music tree
                      else if (courseId.startsWith('music_')) {
                        musicLessons += lessonsCount;
                      }
                      //e-zbiorki tree
                      else if (courseId.startsWith('collection_')) {
                        collectionLessons += lessonsCount;
                      }
                      //history tree
                      else if (courseId.startsWith('history_')) {
                        historyLessons += lessonsCount;
                      }
                      //reflection tree
                      else if (courseId.startsWith('reflection_')) {
                        reflectionLessons += lessonsCount;
                      }
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
                      //musical
                      _buildStatCard('Ścieżka\nPsałterzysty', musicLessons, Icons.music_note, Colors.blue.shade400, theme),
                      //e-zbiorki
                      _buildStatCard('E-zbiórki\n(Odprawy)', collectionLessons, Icons.groups, Colors.orange.shade400, theme),
                      //history 
                      _buildStatCard('Ruch\nliturgiczny', historyLessons, Icons.timeline, Colors.teal.shade400, theme),
                      //reflection
                      _buildStatCard('Rozważania\no liturgii', reflectionLessons, Icons.psychology, Colors.pink.shade400, theme),
                      //completorium
                      _buildStatCard('Kompleta', completoriumStreak, Icons.nightlight_round, Colors.amber.shade400, theme),
                      //hangman game 
                      _buildStatCard('Odgadnięte\nterminy', hangmanLevelsCompleted, Icons.spellcheck, Colors.purple.shade300, theme),
                    ],
                  );
                },
              ),

            const SizedBox(height: 32),

            const Divider(color: Colors.white24),
            ValueListenableBuilder<bool>(
              valueListenable: SettingsManager.isHighContrast,
              builder: (context, isHighContrast, _) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Wysoki kontrast',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Zmienia kolor tekstów na żółty (dla osób słabowidzących)',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: isHighContrast,
                  activeColor: Colors.amber,
                  secondary: Icon(
                    Icons.visibility,
                    color: isHighContrast ? Colors.amber : Colors.grey,
                  ),
                  onChanged: (bool value) {
                    SettingsManager.isHighContrast.value = value;
                  },
                );
              },
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Join date retrieved from the Google/Firebase account
            Text(
              'Data dołączenia: $dateString',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (user != null)
              TextButton.icon(
                onPressed: () => _showDeleteAccountDialog(context, user),
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                label: const Text(
                  'Usuń konto',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              
            const SizedBox(height: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: iconColor),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.w500, 
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
            
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24, 
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