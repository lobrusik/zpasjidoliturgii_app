import 'package:flutter/material.dart';

class TrueFalseQuiz extends StatefulWidget {
  final List<dynamic> questions;
  final VoidCallback? onCompleted;

  const TrueFalseQuiz({
    super.key,
    required this.questions,
    this.onCompleted,
  });

  @override
  State<TrueFalseQuiz> createState() => _TrueFalseQuizState();
}

class _TrueFalseQuizState extends State<TrueFalseQuiz> {
  late Map<int, bool?> answers;

  @override
  void initState() {
    super.initState();
    answers = { for (var i = 0; i < widget.questions.length; i++) i: null };
  }

  void _checkCompletion() {
    bool allCorrect = true;
    for (var i = 0; i < widget.questions.length; i++) {
      final correctA = widget.questions[i]['a'] as bool;
      if (answers[i] != correctA) {
        allCorrect = false;
        break;
      }
    }
    
    if (allCorrect && widget.onCompleted != null) {
      widget.onCompleted!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.questions.length, (index) {
        final q = widget.questions[index]['q'] as String;
        final correctA = widget.questions[index]['a'] as bool;
        final userA = answers[index];

        final isAnswered = userA != null;
        final isCorrect = userA == correctA;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: !isAnswered 
                ? const Color(0xFF2D3039) 
                : (isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !isAnswered ? Colors.transparent : (isCorrect ? Colors.green : Colors.red),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isAnswered ? null : () {
                        setState(() {
                          answers[index] = true;
                          _checkCompletion();
                        });
                      },
                      child: const Text('Prawda'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: isAnswered ? null : () {
                        setState(() {
                          answers[index] = false;
                          _checkCompletion();
                        });
                      },
                      child: const Text('Fałsz'),
                    ),
                  ),
                ],
              ),
              
              if (isAnswered && !isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pudło! Przemyśl to jeszcze raz.',
                          style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Resetujemy odpowiedź dla tego pytania
                          setState(() => answers[index] = null);
                        },
                        child: const Text('Spróbuj ponownie', style: TextStyle(color: Colors.amber)),
                      ),
                    ],
                  ),
                ),
                
              if (isAnswered && isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Świetnie!',
                        style: TextStyle(color: Colors.green.shade200, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}