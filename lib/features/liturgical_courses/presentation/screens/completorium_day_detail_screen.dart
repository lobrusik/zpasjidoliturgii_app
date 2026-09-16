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

  @override
  State<CompletoriumDayDetailScreen> createState() => _CompletoriumDayDetailScreenState();
}

class _CompletoriumDayDetailScreenState extends State<CompletoriumDayDetailScreen> {
  @override
  void initState() {
    super.initState();
    _recordCompletoriumProgress();
  }

  Future<void> _recordCompletoriumProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        
        int currentStreak = 0;
        List<dynamic> completedDays = [];

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>? ?? {};
          currentStreak = data['completoriumStreak'] ?? 0;
          completedDays = List.from(data['completedCompletoriumDays'] ?? []);
        }
        
        String todayKey = DateTime.now().toIso8601String().split('T')[0];
        String uniqueRecord = '${widget.dayTitle}_$todayKey';

        if (!completedDays.contains(uniqueRecord)) {
          completedDays.add(uniqueRecord);
          currentStreak += 1;

          transaction.set(
            userDocRef,
            {
              'completoriumStreak': currentStreak,
              'completedCompletoriumDays': completedDays,
            },
            SetOptions(merge: true),
          );
        }
      });
    } catch (e) {
      debugPrint('Błąd podczas zapisywania postępu kompletorium: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.dayTitle, style: const TextStyle(fontSize: 18)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dayTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            YoutubeVideoPlayer(videoUrl: widget.youtubeUrl),
          ],
        ),
      ),
    );
  }
}