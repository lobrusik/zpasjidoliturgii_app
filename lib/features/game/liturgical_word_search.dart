import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiturgicalWordSearch extends StatefulWidget {
  const LiturgicalWordSearch({super.key});

  @override
  State<LiturgicalWordSearch> createState() => _LiturgicalWordSearchState();
}

class _LiturgicalWordSearchState extends State<LiturgicalWordSearch> {
  final Random _random = Random();
  
  int _level = 1;
  int _gridSize = 8;
  List<String> _allWords = [];
  List<String> _currentWords = [];
  List<String> _foundWords = [];
  
  List<List<String>> _grid = [];
  List<Point<int>> _currentSelection = [];
  List<Point<int>> _foundCells = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWordsFromFirestore();
  }

  Future<void> _loadWordsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('liturgical_terms').get();
      _allWords = snapshot.docs
          .map((doc) => (doc.data()['word'] as String).toUpperCase().replaceAll(' ', ''))
          .where((w) => w.length >= 3)
          .toList();
      _startNewLevel();
    } catch (e) {
      debugPrint('Błąd pobierania słów: $e');
      //_allWords = ['ORNAT', 'MSZA', 'KIELICH', 'KORPORAŁ', 'PATENA', 'OŁTARZ', 'AMBONA', 'KADZIDŁO', 'ALBA', 'STUŁA'];
      _allWords = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

      _startNewLevel();
    }
  }

  void _startNewLevel() {
    setState(() => _isLoading = true);
    
    _gridSize = 7 + _level; 
    if (_gridSize > 14) _gridSize = 14; 
    
    int wordsCount = 3 + _level;
    if (wordsCount > 12) wordsCount = 12;

    _allWords.shuffle(_random);
    _currentWords = _allWords
        .where((w) => w.length <= _gridSize)
        .take(wordsCount)
        .toList();
        
    _foundWords.clear();
    _foundCells.clear();
    _currentSelection.clear();
    
    _generateBoard();
    setState(() => _isLoading = false);
  }

  List<Point<int>> _getAvailableDirections() {
    List<Point<int>> dirs = [const Point(1, 0), const Point(0, 1)];
    if (_level >= 2) dirs.add(const Point(1, 1));
    if (_level >= 3) dirs.addAll([const Point(-1, 0), const Point(0, -1)]);
    if (_level >= 4) dirs.addAll([const Point(-1, -1), const Point(1, -1), const Point(-1, 1)]);
    return dirs;
  }

  void _generateBoard() {
    _grid = List.generate(_gridSize, (_) => List.generate(_gridSize, (_) => ''));
    final directions = _getAvailableDirections();
    List<String> successfullyPlacedWords = [];
    
    for (String word in _currentWords) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 200) {
        attempts++;
        final dir = directions[_random.nextInt(directions.length)];
        
        int startX = _random.nextInt(_gridSize);
        int startY = _random.nextInt(_gridSize);
        
        int endX = startX + (word.length - 1) * dir.x;
        int endY = startY + (word.length - 1) * dir.y;
        
        if (endX < 0 || endX >= _gridSize || endY < 0 || endY >= _gridSize) continue;
        
        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          int x = startX + (i * dir.x);
          int y = startY + (i * dir.y);
          if (_grid[y][x] != '' && _grid[y][x] != word[i]) {
            canPlace = false;
            break;
          }
        }
        
        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            int x = startX + (i * dir.x);
            int y = startY + (i * dir.y);
            _grid[y][x] = word[i];
          }
          placed = true;
          successfullyPlacedWords.add(word);
        }
      }
    }
    
    _currentWords = successfullyPlacedWords;
    
    const chars = 'AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŹŻ';
    for (int y = 0; y < _gridSize; y++) {
      for (int x = 0; x < _gridSize; x++) {
        if (_grid[y][x] == '') {
          _grid[y][x] = chars[_random.nextInt(chars.length)];
        }
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    double cellWidth = constraints.maxWidth / _gridSize;
    double cellHeight = constraints.maxHeight / _gridSize;
    
    int col = (details.localPosition.dx / cellWidth).floor();
    int row = (details.localPosition.dy / cellHeight).floor();
    
    if (col >= 0 && col < _gridSize && row >= 0 && row < _gridSize) {
      Point<int> p = Point(col, row);
      if (!_currentSelection.contains(p)) {
        setState(() {
          _currentSelection.add(p);
        });
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentSelection.isEmpty) return;
    
    String selectedWord = _currentSelection.map((p) => _grid[p.y][p.x]).join('');
    String reversedSelectedWord = selectedWord.split('').reversed.join('');
    
    if (_currentWords.contains(selectedWord) && !_foundWords.contains(selectedWord)) {
      _foundWords.add(selectedWord);
      _foundCells.addAll(_currentSelection);
    } else if (_currentWords.contains(reversedSelectedWord) && !_foundWords.contains(reversedSelectedWord)) {
      _foundWords.add(reversedSelectedWord);
      _foundCells.addAll(_currentSelection);
    }
    
    setState(() {
      _currentSelection.clear();
    });
    
    if (_foundWords.length == _currentWords.length && _currentWords.isNotEmpty) {
      _showLevelCompleteDialog();
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog( 
        backgroundColor: const Color(0xFF22242B),
        title: const Text('Poziom ukończony!', style: TextStyle(color: Colors.white)),
        content: Text('Znalazłeś wszystkie słowa.\nGotowy na trudniejsze wyzwanie?', style: TextStyle(color: Colors.grey)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() => _level++);
              _startNewLevel();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Kolejny poziom', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Wykreślanka - Poziom $_level'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentWords.map((word) {
                bool isFound = _foundWords.contains(word);
                return Chip(
                  label: Text(word, style: TextStyle(
                    decoration: isFound ? TextDecoration.lineThrough : null,
                    color: isFound ? Colors.grey : Colors.white,
                  )),
                  backgroundColor: isFound ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.2),
                  side: BorderSide(color: isFound ? Colors.grey : theme.colorScheme.primary),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: (d) => _currentSelection.clear(),
                        onPanUpdate: (d) => _onPanUpdate(d, constraints),
                        onPanEnd: _onPanEnd,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridSize,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: _gridSize * _gridSize,
                          itemBuilder: (context, index) {
                            int x = index % _gridSize;
                            int y = index ~/ _gridSize;
                            Point<int> p = Point(x, y);
                            
                            bool isFound = _foundCells.contains(p);
                            bool isSelected = _currentSelection.contains(p);
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: isFound 
                                    ? Colors.green.withOpacity(0.5) 
                                    : (isSelected ? theme.colorScheme.primary : const Color(0xFF2D3039)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _grid[y][x],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}