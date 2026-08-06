import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/youtube_video_player.dart';

class CompletoriumDayDetailScreen extends StatefulWidget {
  final String dayTitle;
  final String youtubeUrl;

  const CompletoriumDayDetailScreen({
    super.key,
    required this.dayTitle,
    required this.youtubeUrl,
  });
  //

  @override
  State<CompletoriumDayDetailScreen> createState() => _CompletoriumDayDetailScreenState();
}

class _CompletoriumDayDetailScreenState extends State<CompletoriumDayDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Visitor statistics
    _updateCompletoriumStreak();
  }

  Future<void> _updateCompletoriumStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      
      final todayStr = DateTime.now().toIso8601String().split('T')[0]; //YYYY-MM-DD
      
      if (!snapshot.exists) {
        transaction.set(userRef, {
          'completoriumStreak': 1,
          'lastCompletoriumDate': todayStr,
        });
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final lastDateStr = data['lastCompletoriumDate'] as String?;
      int streak = data['completoriumStreak'] ?? 0;

      if (lastDateStr == todayStr) {
        return;
      }

      if (lastDateStr != null) {
        final lastDate = DateTime.parse(lastDateStr);
        final today = DateTime.parse(todayStr);
        final difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          //Opened yesterday -> we're extending the winning streak by 1
          streak += 1;
        } else if (difference > 1) {
          //More days have passed -> reset the pass to 1
          streak = 1;
        }
      } else {
        streak = 1;
      }

      transaction.update(userRef, {
        'completoriumStreak': streak,
        'lastCompletoriumDate': todayStr,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            YoutubeVideoPlayer(videoUrl: widget.youtubeUrl),
            const SizedBox(height: 24),
            Text(
              widget.dayTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Spokojnej i błogosławionej nocy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}