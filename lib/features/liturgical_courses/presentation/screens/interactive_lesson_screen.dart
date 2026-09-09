import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/youtube_video_player.dart';
import '../../data/models/interactive_lesson_model.dart';
import '../widgets/true_false_quiz.dart';
import '../widgets/drag_and_drop_quiz.dart';
import '../../data/models/study_plan_model.dart';
import '../widgets/interactive_quiz.dart';
// import '../../../monetization/presentation/widgets/ad_manager.dart';

class InteractiveLessonScreen extends StatefulWidget {
  final InteractiveLesson lesson;

  const InteractiveLessonScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<InteractiveLessonScreen> createState() => _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState extends State<InteractiveLessonScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Set<int> requiredSlides = {};
  Set<int> completedSlides = {};
  Map<int, Map<int, String>> openAnswers = {};

  @override
  void initState() {
    super.initState();
    //InterstitialAdManager.loadAd();

    for (int i = 0; i < widget.lesson.slides.length; i++) {
      final type = widget.lesson.slides[i].type;
      if (type == 'true_false' || type == 'drag_drop' || type == 'open_questions' || type == 'quiz') {
        requiredSlides.add(i);
      }
      if (type == 'open_questions') {
        openAnswers[i] = {};
      }
    }

    _loadLocalProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('lesson_progress_${widget.lesson.courseId}');
      
      if (savedData != null) {
        final Map<String, dynamic> data = jsonDecode(savedData);
        setState(() {
          if (data['completedSlides'] != null) {
            completedSlides = Set<int>.from(data['completedSlides']);
          }
          if (data['openAnswers'] != null) {
            final loadedAnswers = data['openAnswers'] as Map<String, dynamic>;
            loadedAnswers.forEach((key, value) {
              int slideIndex = int.parse(key);
              openAnswers[slideIndex] = Map<int, String>.from((value as Map<String, dynamic>).map(
                (k, v) => MapEntry(int.parse(k), v.toString()),
              ));
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Błąd wczytywania postępu: $e');
    }
  }

  Future<void> _saveLocalProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> answersToSave = {};
      
      openAnswers.forEach((slideIndex, answers) {
        answersToSave[slideIndex.toString()] = answers.map((k, v) => MapEntry(k.toString(), v));
      });

      final data = {
        'completedSlides': completedSlides.toList(),
        'openAnswers': answersToSave,
      };
      await prefs.setString('lesson_progress_${widget.lesson.courseId}', jsonEncode(data));
    } catch (e) {
      debugPrint('Błąd zapisywania postępu: $e');
    }
  }

  void _nextPage() async {
    if (_currentPage < widget.lesson.slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      if (completedSlides.length < requiredSlides.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Musisz rozwiązać wszystkie zadania, aby ukończyć lekcję!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String lessonId = widget.lesson.courseId;

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'progress': {
              lessonId: completedSlides.toList() 
            }
          }, SetOptions(merge: true));
        }

        // InterstitialAdManager.showAd(() {
        //   if (mounted) {
        //     Navigator.pop(context);
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(
        //         content: Text('Lekcja ukończona! Gratulacje!'),
        //         backgroundColor: Colors.green,
        //       )
        //     );
        //   }
        // });
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPages = widget.lesson.slides.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.lesson.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: totalPages > 0 ? (_currentPage + 1) / totalPages : 0,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  final slide = widget.lesson.slides[index];
                  switch (slide.type) {
                    case 'intro': return _buildSlideIntro(slide);
                    case 'text': return _buildSlideText(slide);
                    case 'info_cards': return _buildSlideInfoCards(slide);
                    case 'image': return _buildSlideImage(slide);
                    case 'true_false': return _buildSlideTrueFalse(slide, index);
                    case 'drag_drop': return _buildSlideDragDrop(slide, index);
                    case 'open_questions': return _buildSlideOpenQuestions(slide, index);
                    case 'summary': return _buildSlideSummary(slide);
                    case 'quiz': return _buildSlideQuiz(slide, index);
                    default: return const Center(child: Text('Nieznany typ slajdu'));
                  }
                },
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFF141F1C),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _currentPage == 0 ? null : _prevPage,
                    child: const Text('Wstecz', style: TextStyle(color: Colors.grey)),
                  ),
                  Text('${_currentPage + 1} / $totalPages', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
                    onPressed: _nextPage,
                    child: Text(_currentPage == totalPages - 1 ? 'Zakończ' : 'Dalej'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBadge(int slideIndex) {
    if (!completedSlides.contains(slideIndex)) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 12),
          Text('Zadanie zostało już ukończone', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // SLIDE GENERATORS
  Widget _buildSlideHeaderWithImage(LessonSlide slide) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    Widget? imageWidget;
    if (slide.imageUrl != null) {
      imageWidget = slide.imageUrl!.startsWith('http') 
          ? Image.network(slide.imageUrl!, fit: BoxFit.contain)
          : Image.asset(slide.imageUrl!, fit: BoxFit.contain);
    }

    final markdownStyle = MarkdownStyleSheet(
      p: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.0, color: Colors.grey.shade700)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(slide.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),

        if (isMobile) ...[
          if (imageWidget != null) ...[
            Center(
              child: SizedBox(
                height: 220,
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (slide.content != null)
            MarkdownBody(
              data: slide.content!,
              styleSheet: markdownStyle,
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final url = Uri.parse(href);
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nie udało się otworzyć linku.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (slide.imageUrl != null) ...[
                Expanded(
                  flex: 2,
                  child: slide.imageUrl!.startsWith('http') 
                    ? Image.network(slide.imageUrl!, fit: BoxFit.contain)
                    : Image.asset(slide.imageUrl!, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
              ],
              if (slide.content != null)
                Expanded(
                  flex: 3,
                  child: MarkdownBody(
              data: slide.content!,
              styleSheet: markdownStyle,
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final url = Uri.parse(href);
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nie udało się otworzyć linku.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSlideIntro(LessonSlide slide) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSlideHeaderWithImage(slide),
              
              if (slide.videoUrl != null) ...[
                const SizedBox(height: 20),
                if (isLandscape)
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 28),
                      label: const Text('Odtwórz materiał wideo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => Scaffold(
                              backgroundColor: Colors.black,
                              appBar: AppBar(
                                backgroundColor: Colors.black,
                                elevation: 0,
                                leading: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              body: SafeArea(
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: YoutubeVideoPlayer(videoUrl: slide.videoUrl!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                        maxHeight: 280, 
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: YoutubeVideoPlayer(videoUrl: slide.videoUrl!),
                        ),
                      ),
                    ),
                  ),
              ],
              
              if (slide.quote != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3039), 
                    borderRadius: BorderRadius.circular(12), 
                    border: Border.all(color: Colors.amber.withOpacity(0.3))
                  ),
                  child: Text(
                    slide.quote!, 
                    style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5)
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideText(LessonSlide slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: _buildSlideHeaderWithImage(slide),
    );
  }

  Widget _buildSlideInfoCards(LessonSlide slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),
          const SizedBox(height: 32),
          if (slide.dataList != null)
            ...slide.dataList!.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2D3039), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(item['text'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSlideImage(LessonSlide slide) {
    final String imagePath = slide.content ?? slide.imageUrl ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(slide.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Expanded(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: imagePath.isEmpty
                ? const Text('Brak obrazu', style: TextStyle(color: Colors.grey))
                : (imagePath.startsWith('http')
                  ? Image.network(imagePath)
                  : Image.asset(imagePath)),
            ),
          ),
        ),
      ],
    );
  }

  // True false quiz
  Widget _buildSlideTrueFalse(LessonSlide slide, int slideIndex) {
    final questions = slide.dataList ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),
          const SizedBox(height: 32),
          
          _buildCompletedBadge(slideIndex),
          
          TrueFalseQuiz(
            key: ValueKey('tf_$slideIndex'),
            questions: questions,
            onCompleted: () {
              setState(() => completedSlides.add(slideIndex));
              _saveLocalProgress();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wszystkie odpowiedzi są poprawne! Oby tak dalej! 👏'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Drag and drop quiz
  Widget _buildSlideDragDrop(LessonSlide slide, int slideIndex) {
    final activityData = {
      'instruction': slide.content ?? 'Dopasuj elementy:',
      'categories': slide.categories ?? [],
      'itemsToMatch': slide.itemsToMatch ?? [],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),
          const SizedBox(height: 32),

          _buildCompletedBadge(slideIndex),
          
          DragAndDropQuiz(
            key: ValueKey('drag_drop_$slideIndex'),
            activityData: activityData,
            onCompleted: () {
              setState(() => completedSlides.add(slideIndex));
              _saveLocalProgress();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Świetnie! Zadanie wykonane poprawnie! 👏'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Open questions 
  Widget _buildSlideOpenQuestions(LessonSlide slide, int slideIndex) {
    final questions = slide.dataList ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),
          const SizedBox(height: 32),

          _buildCompletedBadge(slideIndex),
          
          ...List.generate(questions.length, (qIndex) {
            final q = questions[qIndex]['q'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  // Używamy TextFormField by poprawnie czytać wartość początkową z SharedPreferences
                  TextFormField(
                    initialValue: openAnswers[slideIndex]?[qIndex] ?? '',
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Zapisz swoje przemyślenia...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: const Color(0xFF2D3039),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      openAnswers[slideIndex]![qIndex] = value;
                      
                      bool allAnswered = true;
                      for (int i = 0; i < questions.length; i++) {
                        if ((openAnswers[slideIndex]![i] ?? '').trim().isEmpty) {
                          allAnswered = false;
                          break;
                        }
                      }
                      
                      if (allAnswered) {
                        setState(() => completedSlides.add(slideIndex));
                      } else {
                        setState(() => completedSlides.remove(slideIndex));
                      }
                      
                      _saveLocalProgress(); 
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ABCD quiz
  Widget _buildSlideQuiz(LessonSlide slide, int slideIndex) {
    final List<QuizQuestion> questions = (slide.dataList ?? []).map((qMap) {
      return QuizQuestion(
        question: qMap['question'] ?? '',
        options: List<String>.from(qMap['options'] ?? []),
        correctAnswerIndex: qMap['correctAnswerIndex'] ?? 0,
        explanation: qMap['explanation'] ?? '',
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),
          const SizedBox(height: 32),

          _buildCompletedBadge(slideIndex),
          
          InteractiveQuiz(
            key: ValueKey('quiz_$slideIndex'),
            questions: questions,
            onQuizCompleted: () {
              setState(() => completedSlides.add(slideIndex));
              _saveLocalProgress();
              
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Świetnie! Quiz ukończony pomyślnie! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlideSummary(LessonSlide slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.amber),
          const SizedBox(height: 24),
          _buildSlideHeaderWithImage(slide),
          if (slide.quote != null) ...[
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF2D3039), borderRadius: BorderRadius.circular(12)),
              child: Text('„${slide.quote!}”', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
            )
          ],
        ],
      ),
    );
  }
}