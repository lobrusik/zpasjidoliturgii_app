import 'dart:async';
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

  double _currentPosition = 0.0;
  double _totalDuration = 0.0;
  bool _isDragging = false; // Zapobiega skakaniu suwaka, gdy użytkownik go przesuwa
  Timer? _timer;

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
        _startTimer(); // Uruchamiamy odświeżanie czasu
      } else if (event.playerState == PlayerState.paused && _isPlaying) {
        if (mounted) setState(() => _isPlaying = false);
        _stopTimer(); 
      } else if (event.playerState == PlayerState.ended) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentPosition = 0.0; // Reset po zakończeniu
          });
        }
        _stopTimer();
      }
      
      if (event.playerState == PlayerState.unStarted || event.playerState == PlayerState.unknown) {
        // Wait while the page loads
      } else if (!_isReady) {
        if (mounted) setState(() => _isReady = true);
        _fetchInitialDuration(); 
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isDragging && _isReady) {
        final position = await _controller.currentTime;
        final duration = await _controller.duration;
        if (mounted) {
          setState(() {
            _currentPosition = position;
            if (duration > 0) _totalDuration = duration;
          });
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _fetchInitialDuration() async {
    final duration = await _controller.duration;
    if (mounted && duration > 0) {
      setState(() {
        _totalDuration = duration;
      });
    }
  }

  String _formatDuration(double totalSeconds) {
    final duration = Duration(seconds: totalSeconds.toInt());
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    return '$hours$minutes:$seconds';
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
    _stopTimer();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxSliderValue = _totalDuration > 0 ? _totalDuration : 1.0;
    final currentSliderValue = _currentPosition.clamp(0.0, maxSliderValue);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Odtwarzacz'),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 70,
                      backgroundColor: Color(0xFF2D3039),
                      child: Icon(Icons.headphones, size: 70, color: Colors.amber),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      _isReady ? 'Odtwarzanie audio z YouTube' : 'Ładowanie nagrania...',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 48),

                    if (!_isReady)
                      const CircularProgressIndicator(color: Colors.amber)
                    else ...[
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.amber,
                          inactiveTrackColor: Colors.grey.shade800,
                          thumbColor: Colors.amber,
                          trackHeight: 6.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          overlayColor: Colors.amber.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: currentSliderValue,
                          min: 0.0,
                          max: maxSliderValue,
                          onChanged: (value) {
                            setState(() {
                              _isDragging = true;
                              _currentPosition = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _controller.seekTo(seconds: value, allowSeekAhead: true);
                            setState(() {
                              _isDragging = false;
                            });
                          },
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      IconButton(
                        iconSize: 80,
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