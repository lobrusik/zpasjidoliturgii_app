import 'package:flutter/material.dart';
import '../widgets/youtube_video_player.dart';

class PsalmVideoScreen extends StatelessWidget {
  final String title;
  final String youtubeUrl;

  const PsalmVideoScreen({
    super.key,
    required this.title,
    required this.youtubeUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 18)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            YoutubeVideoPlayer(videoUrl: youtubeUrl),
          ],
        ),
      ),
    );
  }
}