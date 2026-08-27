import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/study_plan_bloc.dart';
import '../bloc/progress_bloc.dart';
import '../widgets/youtube_video_player.dart';
import '../widgets/interactive_quiz.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/buy_coffee_button.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/drag_and_drop_quiz.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/interactive_lesson_model.dart';
import 'interactive_lesson_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ONLY FOR TRUNK_LITURGY
    if (courseId.startsWith('trunk_liturgy_')) {
      return Scaffold(
        appBar: AppBar(
          title: Text(courseTitle),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Instrukcja',
              onPressed: () {
                showInstructionDialog(
                  context,
                  'Jak zaliczyć tę lekcję?',
                  'KROK PO KROKU:\n\n'
                  '1. Kliknij duży przycisk "Rozpocznij lekcję" na środku ekranu.\n\n'
                  '2. Ekran zmieni się w prezentację. Aby przejść do kolejnej strony, po prostu klikaj przyciski "Dalej" lub "Wstecz".\n\n'
                  '3. Uważnie objejrzyj lekcję i przeczytaj umieszczony pod filmikiem tekst. Możesz również zajrzeć do źródeł pomocniczych, podanych na 1 slajdzie lub wstępie do zadań. Robienie notatek - wskazane!.\n\n'
                  '4. W trakcie prezentacji trafisz na zadania i minigry. Przeczytaj polecenie na ekranie i rozwiąż je poprawnie.\n\n'
                  '5. Przejdź do samego końca prezentacji. Gdy wykonasz wszystkie zadania, lekcja zaliczy się automatycznie, a Ty będziesz bliżej do uzyskania osiągnicia.',
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('interactive_lessons').doc(courseId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Brak danych lekcji interaktywnej.\nUpewnij się, że JSON jest w bazie!', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.grey)
                )
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final lesson = InteractiveLesson.fromJson(data, snapshot.data!.id);

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 80, color: Colors.amber),
                    const SizedBox(height: 24),
                    Text('Szkoła Liturgii', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.amber, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(lesson.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    const Text(
                      'Ta lekcja ma formę interaktywnej prezentacji. Przesuwaj ekrany, oglądaj materiały i rozwiązuj zadania wewnątrz modułu.', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color: Colors.grey, height: 1.5)
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InteractiveLessonScreen(lesson: lesson)),
                        ).then((isCompleted) {
                          if (isCompleted == true) {
                            context.read<ProgressBloc>().add(
                              ToggleLessonProgress(
                                courseId: courseId,
                                planId: lesson.id,
                                isCompleted: true,
                              ),
                            );
                          }
                        });
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Rozpocznij lekcję', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // ALL OTHER BRANCHES
    return Scaffold(
      appBar: AppBar(
        title: Text(courseTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Instrukcja do lekcji',
            onPressed: () {
              showInstructionDialog(
                context,
                'Co musisz tutaj zrobić?',
                'Każda taka lekcja składa się z 3 prostych części:\n\n'
                '1. ZOBACZ (Opcjonalnie)\n'
                'Jeśli na samej górze widzisz okienko wideo, kliknij w nie, aby obejrzeć film wprowadzający.\n\n'
                '2. ZROZUM\n'
                'Przewiń ekran w dół i przeczytaj tekst lekcji oraz artukuł rozszerzający temat lekcji. Zrób to uważnie – to właśnie z tego tekstu będzie test na końcu!\n\n'
                '3. SPRAWDŹ SIĘ (Wymagane)\n'
                'Zjedź na sam dół ekranu. Znajdziesz tam quiz (zaznaczanie poprawnych odpowiedzi) lub układankę (przeciąganie kafelków). Rozwiąż to zadanie.\n\n'
                'JAK UZYSKAĆ ZALICZYCZENIE?\n'
                'Gdy bezbłędnie wykonasz zadanie, na ekranie pojawi się wielki zielony napis "Brawo!", a system sam odblokuje Ci kolejną lekcję w drzewku.',);
            },
          ),
        ],
      ),
      body: BlocBuilder<StudyPlanBloc, StudyPlanState>(
        builder: (context, state) {
          if (state is StudyPlanLoading) return const Center(child: CircularProgressIndicator());

          if (state is StudyPlanLoaded) {
            final plans = state.plans;
            if (plans.isEmpty) {
              return const Center(child: Text('Brak danych lekcji.'));
            }

            final plan = plans.first; 

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, '1', 'Zobacz'),
                  const SizedBox(height: 16),
                  if (plan.videoLinks.isNotEmpty) 
                    YoutubeVideoPlayer(videoUrl: plan.videoLinks.first)
                  else
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3039),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Brak wideo dla tego etapu', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  
                  const SizedBox(height: 48),

                  _buildSectionHeader(context, '2', 'Zrozum'),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: plan.liturgicalContent,
                    styleSheet: MarkdownStyleSheet(
                      p: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.6,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: theme.colorScheme.onSurface,
                      ),
                      h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      listBullet: TextStyle(color: theme.colorScheme.primary, fontSize: 18),
                    ),
                  ),

                  if (plan.textMaterials.trim().isNotEmpty) ... [
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final String rawUrl = plan.textMaterials.trim();
                        final Uri url = Uri.parse(rawUrl);

                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication); 
                        } catch (e){
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Błąd: Nie można otworzyć strony. Upewnij się, że przeglądarka nie blokuje wyskakujących okienek.', style: TextStyle(color: Colors.white)), 
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          'Przeczytaj artykuł rozszerzający ten temat', 
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: Colors.blueAccent, 
                            decoration: TextDecoration.underline, 
                            decorationColor: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),

                  _buildSectionHeader(context, '3', 'Sprawdź się'),
                  const SizedBox(height: 16),
                  
                  BlocBuilder<ProgressBloc, ProgressState>(
                    builder: (context, progressState) {
                      bool isCompleted = false;
                      if (progressState is ProgressLoaded) {
                        isCompleted = progressState.completedPlanIds.contains(plan.id);
                      }

                      if (isCompleted) {
                        return _buildSuccessBanner(context);
                      }
                      
                      // DRAG & DROP IF DATA EXISTS IN THE DATABASE
                      if (plan.interactiveActivity != null) {
                        return DragAndDropQuiz(
                          activityData: plan.interactiveActivity!,
                          onCompleted: () {
                            context.read<ProgressBloc>().add(
                              ToggleLessonProgress(
                                courseId: courseId,
                                planId: plan.id,
                                isCompleted: true,
                              ),
                            );
                          },
                        );
                      }

                      if (plan.quiz.isEmpty) {
                         return _buildManualCompletionButton(context, plan.id);
                      }

                      return InteractiveQuiz(
                        questions: plan.quiz, 
                        onQuizCompleted: () {
                          context.read<ProgressBloc>().add(
                            ToggleLessonProgress(
                              courseId: courseId,
                              planId: plan.id,
                              isCompleted: true,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          }

          if (state is StudyPlanError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String number, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14))),
        ),
        const SizedBox(width: 12),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
      ],
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 64),
          const SizedBox(height: 16),
          const Text('Brawo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Ukończyłeś ten etap.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), minimumSize: const Size(double.infinity, 50)),
            child: const Text('Wróć do mapy kursów'),
          ),
          const SizedBox(height: 20),
          const Center(
            child: BuyCoffeeButton(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildManualCompletionButton(BuildContext context, String planId) {
     return ElevatedButton.icon(
       onPressed: () {
         context.read<ProgressBloc>().add(
            ToggleLessonProgress(courseId: courseId, planId: planId, isCompleted: true)
         );
       },
       style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
       icon: const Icon(Icons.check),
       label: const Text('Oznacz jako przeczytane'),
     );
  }
}

void showInstructionDialog(BuildContext context, String title, String instructionText) {
  showDialog(
    context: context,
    barrierDismissible: true, 
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color(0xFF1F242D), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    instructionText,
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zrozumiałe!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    },
  );
}