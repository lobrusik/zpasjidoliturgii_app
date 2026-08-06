import 'package:flutter/material.dart';
import '../../data/models/study_plan_model.dart';

class InteractiveQuiz extends StatefulWidget {
  final List<QuizQuestion> questions;
  final VoidCallback onQuizCompleted;

  const InteractiveQuiz({
    super.key,
    required this.questions,
    required this.onQuizCompleted,
  });


  @override
  State<InteractiveQuiz> createState() => _InteractiveQuizState();
}

class _InteractiveQuizState extends State<InteractiveQuiz> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  int _score = 0;

  void _checkAnswer(int index) {
    if (_isAnswerChecked) return;
    bool isCorrect = index == widget.questions[_currentQuestionIndex].correctAnswerIndex;
    if (isCorrect) {
      _score++;
    }
    setState(() {
      _selectedOptionIndex = index;
      _isAnswerChecked = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerChecked = false;
      });
    } else {
        if (_score >= 5) {
          widget.onQuizCompleted();
        } else {
          _showFailureDialog();
        }
      
    }
  }
  void _showFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Jeszcze raz!'),
        content: Text('Zdobyłeś $_score/${widget.questions.length} punktów. Potrzebujesz min. 5, aby zaliczyć etap.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { 
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedOptionIndex = null;
                _isAnswerChecked = false;
              });
            },
            child: const Text('Spróbuj ponownie'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D3039)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pytanie ${_currentQuestionIndex + 1} z ${widget.questions.length}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),

          ...List.generate(question.options.length, (index) {
            final isSelected = _selectedOptionIndex == index;
            final isCorrect = index == question.correctAnswerIndex;
            
            Color buttonColor = Colors.transparent;
            Color borderColor = const Color(0xFF2D3039);
            Widget? trailingIcon;

            if (_isAnswerChecked) {
              if (isCorrect) {
                buttonColor = const Color(0xFF2E7D32).withOpacity(0.2);
                borderColor = const Color(0xFF2E7D32);
                trailingIcon = const Icon(Icons.check, color: Color(0xFF2E7D32));
              } else if (isSelected && !isCorrect) {
                buttonColor = Colors.red.withOpacity(0.2);
                borderColor = Colors.red;
                trailingIcon = const Icon(Icons.close, color: Colors.red);
              }
            } else if (isSelected) {
              borderColor = theme.colorScheme.primary;
            }

            final letters = ['A', 'B', 'C', 'D'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => _checkAnswer(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: isSelected || _isAnswerChecked ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Text(
                        letters[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isAnswerChecked && isCorrect ? const Color(0xFF2E7D32) : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      if (trailingIcon != null) trailingIcon,
                    ],
                  ),
                ),
              ),
            );
          }),

          if (_isAnswerChecked) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Text(
                question.explanation,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isLastQuestion ? 'Zakończ quiz' : 'Następne pytanie'),
            ),
          ]
        ],
      ),
    );
  }
}