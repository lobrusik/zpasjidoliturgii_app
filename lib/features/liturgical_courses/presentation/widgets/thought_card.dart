import 'package:flutter/material.dart';

class ThoughtOfTheDayCard extends StatefulWidget {
  final String quote;
  final String author;
  final String deepReflection;

  const ThoughtOfTheDayCard({
    super.key,
    required this.quote,
    required this.author,
    required this.deepReflection,
  });

  @override
  State<ThoughtOfTheDayCard> createState() => _ThoughtOfTheDayCardState();
}

class _ThoughtOfTheDayCardState extends State<ThoughtOfTheDayCard> {
  bool _showDeepReflection = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3039),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Icon(Icons.format_quote_rounded, color: theme.colorScheme.primary, size: 26),
          //     const SizedBox(width: 8),
          //     Text(
          //       'Refleksja',
          //       style: TextStyle(
          //         color: theme.colorScheme.primary,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 14),

          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${widget.quote}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— ${widget.author}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontekst:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.deepReflection,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            crossFadeState: _showDeepReflection 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showDeepReflection = !_showDeepReflection;
                });
              },
              icon: Icon(
                _showDeepReflection ? Icons.arrow_back_rounded : Icons.auto_stories_rounded,
                size: 16,
              ),
              label: Text(
                _showDeepReflection ? 'Wróć do cytatu' : 'Przełącz na kontekst',
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}