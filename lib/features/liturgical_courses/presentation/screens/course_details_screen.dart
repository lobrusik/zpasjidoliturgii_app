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


    return Scaffold(
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
                      // Main text (paragraphs)
                      p: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.6,
                      ),
                      // Bold
                      strong: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: theme.colorScheme.onSurface,
                      ),
                      // Headings
                      h1: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      // Dots in List
                      listBullet: TextStyle(color: theme.colorScheme.primary, fontSize: 18),
                    ),
                  ),
                  //const SizedBox(height: 24),

                  //Creating a clickable link
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
                              SnackBar(
                                content: Text('Błąd: Nie można otworzyć strony. Upewnij się, że przeglądarka nie blokuje wyskakujących okienek.', style: const TextStyle(color: Colors.white)), 
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