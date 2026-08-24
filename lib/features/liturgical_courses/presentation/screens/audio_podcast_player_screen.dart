import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  bool _isPlaying = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.audioUrl) ?? '';

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: false, // Hiding YouTube Buttons
        mute: false,
        showFullscreenButton: false,
      ),
    );

    // Listening to see what's going on with the player
    _controller.listen((event) {
      if (event.playerState == PlayerState.playing && !_isPlaying) {
        if (mounted) setState(() => _isPlaying = true);
      } else if (event.playerState == PlayerState.paused && _isPlaying) {
        if (mounted) setState(() => _isPlaying = false);
      }
      
      if (event.playerState == PlayerState.unStarted || event.playerState == PlayerState.unknown) {
        // Wait while the page loads
      } else if (!_isReady) {
        if (mounted) setState(() => _isReady = true);
      }
    });
  }

  // Extracting the ID from any YouTube link
  String? _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Offstage(
            offstage: true,
            child: YoutubePlayer(controller: _controller),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFF2D3039),
                      child: Icon(Icons.headphones, size: 60, color: Colors.amber),
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
                      _isReady ? 'Odtwarzanie audio z YouTube' : 'Ładowanie nagrania...',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 48),

                    if (!_isReady)
                      const CircularProgressIndicator(color: Colors.amber)
                    else
                      IconButton(
                        iconSize: 72,
                        color: Colors.amber,
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        onPressed: () {
                          if (_isPlaying) {
                            _controller.pauseVideo();
                          } else {
                            _controller.playVideo();
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),    
        ],
      ),
    );
  }
}