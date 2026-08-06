import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AudioPodcastPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String title;

  const AudioPodcastPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.title,
  });

  @override
  State<AudioPodcastPlayerScreen> createState() => _AudioPodcastPlayerScreenState();
}

class _AudioPodcastPlayerScreenState extends State<AudioPodcastPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlaying = true;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.audioUrl) ?? '';

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 0,
              width: 0,
              child: YoutubePlayer(
                controller: _controller,
                onReady: () {
                  setState(() {
                    _isReady = true;
                  });
                },
              ),
            ),

            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF2D3039),
              child: Icon(Icons.headphones, size: 60, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            Text(
              _isReady ? 'Odtwarzanie audio (tryb podcastu)' : 'Ładowanie nagrania...',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 48),

            if (!_isReady)
              const CircularProgressIndicator(color: Colors.amber)
            else
              // Panel sterowania (Play / Pause)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    color: Colors.white,
                    icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                          _isPlaying = false;
                        } else {
                          _controller.play();
                          _isPlaying = true;
                        }
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}