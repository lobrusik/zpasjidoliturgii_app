import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/study_plan_bloc.dart';
import '../bloc/progress_bloc.dart';
import '../widgets/youtube_video_player.dart';
import '../widgets/interactive_quiz.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  Text(
                    plan.liturgicalContent,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Creating a clickable link
                  GestureDetector(
                    onTap: () async {
                      if (plan.textMaterials.isEmpty) return;
                      
                      final Uri url = Uri.parse(plan.textMaterials);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nie udało się otworzyć linku.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
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
          )
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