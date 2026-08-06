import 'package:flutter/material.dart';

class DragAndDropQuiz extends StatefulWidget {
  final Map<String, dynamic> activityData;
  final VoidCallback onCompleted;

  const DragAndDropQuiz({
    super.key,
    required this.activityData,
    required this.onCompleted,
  });

  @override
  State<DragAndDropQuiz> createState() => _DragAndDropQuizState();
}

class _DragAndDropQuizState extends State<DragAndDropQuiz> {
  late List<String> categories;
  late List<Map<String, dynamic>> remainingItems;
  Map<String, List<String>> matchedItems = {};

  @override
  void initState() {
    super.initState();
    categories = List<String>.from(widget.activityData['categories']);
    remainingItems = List<Map<String, dynamic>>.from(widget.activityData['itemsToMatch']);
    remainingItems.shuffle();
    
    for (var category in categories) {
      matchedItems[category] = [];
    }
  }

  void _checkCompletion() {
    if (remainingItems.isEmpty) {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.activityData['instruction'] ?? 'Dopasuj elementy:',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        
        // CATEGORIES (Drop-off Locations)
        ...categories.map((category) => _buildDragTarget(category, theme)),
        
        const SizedBox(height: 32),
        
        // TILES FOR DRAGGING
        if (remainingItems.isNotEmpty) ...[
          Text('Elementy do przypisania:', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: remainingItems.map((item) => _buildDraggable(item, theme)).toList(),
          ),
        ]
      ],
    );
  }

  Widget _buildDragTarget(String category, ThemeData theme) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        return true;
      },
      onAcceptWithDetails: (details) {
        if (details.data['correctCategory'] == category) {
          setState(() {
            matchedItems[category]!.add(details.data['text']);
            remainingItems.remove(details.data);
            _checkCompletion();
          });
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pudło! To nie pasuje do tej kategorii. Spróbuj ponownie.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHovered ? Colors.green.withOpacity(0.2) : const Color(0xFF2D3039),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered ? Colors.green : Colors.grey.shade700,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              if (matchedItems[category]!.isEmpty)
                Text('Przeciągnij tutaj pasujące opisy...', style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
              ...matchedItems[category]!.map((text) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggable(Map<String, dynamic> item, ThemeData theme) {
    final text = item['text'] as String;

    return Draggable<Map<String, dynamic>>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)],
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3039).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade800, style: BorderStyle.solid),
        ),
        child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2026),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}