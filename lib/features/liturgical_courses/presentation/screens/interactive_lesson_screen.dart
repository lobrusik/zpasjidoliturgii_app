import 'package:flutter/material.dart';
import '../widgets/youtube_video_player.dart';
import '../../data/models/interactive_lesson_model.dart';
import '../widgets/true_false_quiz.dart';
import '../widgets/drag_and_drop_quiz.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    for (int i = 0; i < widget.lesson.slides.length; i++) {
      final type = widget.lesson.slides[i].type;
      if (type == 'true_false' || type == 'drag_drop' || type == 'open_questions') {
        requiredSlides.add(i);
      }
      if (type == 'open_questions') {
        openAnswers[i] = {};
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.lesson.slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else{
      if (completedSlides.length < requiredSlides.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Musisz rozwiązać wszystkie zadania, aby ukończyć lekcję!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lekcja ukończona! Gratulacje! 🎉'),
            backgroundColor: Colors.green,
          )
        );
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
          // PHONE SYSTEM
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
            ),
        ] else ...[
        // SYSTEM FOR COMPUTERS, TABLETS
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
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSlideIntro(LessonSlide slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),

          if (slide.videoUrl != null) ...[
            const SizedBox(height: 32),
            YoutubeVideoPlayer(videoUrl: slide.videoUrl!),
          ],
          if (slide.quote != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF2D3039), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(0.3))),
              child: Text(slide.quote!, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5)),
            ),
          ],
        ],
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
          
          TrueFalseQuiz(
            key: ValueKey('tf_$slideIndex'),
            questions: questions,
            onCompleted: () {
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
          
          DragAndDropQuiz(
            key: ValueKey('drag_drop_$slideIndex'),
            activityData: activityData,
            onCompleted: () {
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

  // open questions 
  Widget _buildSlideOpenQuestions(LessonSlide slide, int slideIndex) {
    final questions = slide.dataList ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlideHeaderWithImage(slide),
          const SizedBox(height: 32),
          
          ...List.generate(questions.length, (qIndex) {
            final q = questions[qIndex]['q'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
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
          ]
        ],
      ),
    );
  }
}