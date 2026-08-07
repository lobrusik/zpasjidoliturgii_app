import 'package:flutter/material.dart';
// Upewnij się, że ścieżka do odtwarzacza YouTube jest poprawna względem Twojego projektu
import '../widgets/youtube_video_player.dart'; 

class CompletoriumDayDetailScreen extends StatelessWidget {
  final String dayTitle;
  final String youtubeUrl;

  const CompletoriumDayDetailScreen({
    super.key,
    required this.dayTitle,
    required this.youtubeUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(dayTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            YoutubeVideoPlayer(videoUrl: youtubeUrl),
          ],
        ),
      ),
    );
  }
}