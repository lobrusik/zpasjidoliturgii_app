import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DailyLessonScreen extends StatefulWidget {
  final String planId;
  final String title;
  final bool isCompleted;

  const DailyLessonScreen({
    super.key,
    required this.planId,
    required this.title,
    this.isCompleted = false,
  });

  @override
  State<DailyLessonScreen> createState() => _DailyLessonScreenState();
}

class _DailyLessonScreenState extends State<DailyLessonScreen> {
  bool _isSaving = false;
  late Future<DocumentSnapshot> _lessonFuture;

  final Map<int, int> _selectedAnswers = {};
  bool _isQuizSubmitted = false;

  @override
  void initState() {
    super.initState();
    _lessonFuture = FirebaseFirestore.instance.collection('daily_plans').doc(widget.planId).get();
  }

  Future<void> _finishDay() async {
    setState(() => _isSaving = true);

    if (widget.isCompleted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Powtórka zakończona!')),
        );
        context.pop();
      }
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await userRef.get();
      final currentPlanDay = snapshot.data()?['currentPlanDay'] ?? 1;

      await userRef.set({
        'currentPlanDay': currentPlanDay + 1,
        'lastPlanCompletionDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dzień zaliczony! Wróć jutro po więcej.')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCompleted ? '${widget.title} (Powtórka)' : widget.title),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Nie znaleziono lekcji w bazie.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final videoUrl = data['videoUrl'] as String? ?? '';
          final theologicalText = data['theologicalText'] as String? ?? '';
          final practicalTask = data['practicalTask'] as String? ?? '';
          final List<dynamic> quizData = data['quiz'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(theme, '1', 'Zobacz'),
                const SizedBox(height: 12),
                
                if (videoUrl.isNotEmpty && YoutubePlayer.convertUrlToId(videoUrl) != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _YoutubePlayerWidget(videoUrl: videoUrl),
                  )
                else
                  Container(
                    height: 200, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Brak poprawnego linku wideo', style: TextStyle(color: Colors.white54))),
                  ),
                const SizedBox(height: 32),

                _buildSectionHeader(theme, '2', 'Zrozum'),
                const SizedBox(height: 12),
                Text(
                  theologicalText,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6, color: Colors.grey.shade300),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader(theme, '3', 'Sprawdź się'),
                const SizedBox(height: 12),
                
                if (quizData.isEmpty)
                  const Text('Brak pytań do tego dnia.', style: TextStyle(color: Colors.grey))
                else
                  ...List.generate(quizData.length, (index) {
                    return _buildQuizQuestion(index, quizData[index] as Map<String, dynamic>, theme);
                  }),

                if (quizData.isNotEmpty && !_isQuizSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () {
                        if (_selectedAnswers.length < quizData.length) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Odpowiedz na wszystkie pytania przed sprawdzeniem!')),
                          );
                          return;
                        }
                        setState(() => _isQuizSubmitted = true);
                      },
                      child: const Text('Sprawdź odpowiedzi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  const SizedBox(height: 32),

                _buildSectionHeader(theme, '4', 'Zastosuj'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.track_changes, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          practicalTask,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isCompleted ? const Color(0xFF2E7D32) : theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (_isSaving || (!widget.isCompleted && quizData.isNotEmpty && !_isQuizSubmitted)) ? null : _finishDay,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isCompleted ? 'Zakończ powtórkę' : 'Zakończ dzień', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String number, String title) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuizQuestion(int questionIndex, Map<String, dynamic> questionData, ThemeData theme) {
    final questionText = questionData['question'] ?? 'Brak pytania';
    final options = List<String>.from(questionData['options'] ?? []);
    final correctAnswerIndex = questionData['correctAnswerIndex'] as int? ?? 0;
    final explanation = questionData['explanation'] ?? '';
    final selectedOption = _selectedAnswers[questionIndex];
    final isCorrect = selectedOption == correctAnswerIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF22242B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3039)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(questionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 12),
          
          ...List.generate(options.length, (optionIndex) {
            Color? optionColor;
            if (_isQuizSubmitted) {
              if (optionIndex == correctAnswerIndex) {
                optionColor = Colors.green.withOpacity(0.3);
              } else if (optionIndex == selectedOption && !isCorrect) {
                optionColor = Colors.red.withOpacity(0.3);
              }
            }

            return GestureDetector(
              onTap: _isQuizSubmitted ? null : () {
                setState(() => _selectedAnswers[questionIndex] = optionIndex);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: optionColor ?? (selectedOption == optionIndex ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent),
                  border: Border.all(
                    color: optionColor != null ? Colors.transparent : (selectedOption == optionIndex ? theme.colorScheme.primary : Colors.grey.shade800),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedOption == optionIndex ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: selectedOption == optionIndex ? theme.colorScheme.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(options[optionIndex], style: TextStyle(color: Colors.grey.shade300))),
                  ],
                ),
              ),
            );
          }),

          if (_isQuizSubmitted)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                isCorrect ? '✅ Poprawnie! $explanation' : '❌ Niestety błąd. $explanation',
                style: TextStyle(color: isCorrect ? Colors.green.shade300 : Colors.red.shade300, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

class _YoutubePlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _YoutubePlayerWidget({required this.videoUrl});

  @override
  State<_YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<_YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.orange,
    );
  }
}