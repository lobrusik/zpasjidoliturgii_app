import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LiturgicalWordSearch extends StatefulWidget {
  const LiturgicalWordSearch({super.key});

  @override
  State<LiturgicalWordSearch> createState() => _LiturgicalWordSearchState();
}

class _LiturgicalWordSearchState extends State<LiturgicalWordSearch> {
  final Random _random = Random();
  
  // Zmienne postępu i Firebase
  int maxUnlockedLevel = 0;
  int playingLevel = 0;
  bool isLoading = true;
  bool noMoreWords = false;

  // Stan gry
  int _gridSize = 8;
  List<String> _allWords = [];
  List<String> _currentWords = [];
  List<String> _foundWords = [];
  
  List<List<String>> _grid = [];
  List<Point<int>> _currentSelection = [];
  List<Point<int>> _foundCells = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndWords();
  }

  Future<void> _loadUserDataAndWords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      
      final data = doc.data();
      if (data != null && data.containsKey('wordSearchLevelsCompleted')) {
        maxUnlockedLevel = data['wordSearchLevelsCompleted'];
      } else {
        await docRef.set({'wordSearchLevelsCompleted': 0}, SetOptions(merge: true));
        maxUnlockedLevel = 0;
      }
    }

    playingLevel = maxUnlockedLevel;

    try {
      final snapshot = await FirebaseFirestore.instance.collection('liturgical_terms').get();
      _allWords = snapshot.docs
          .map((doc) => (doc.data()['word']?.toString() ?? '').toUpperCase().replaceAll(' ', ''))
          .where((w) => w.length >= 3)
          .toList();
    } catch (e) {
      debugPrint('Błąd pobierania słów: $e');
      _allWords = ['A', 'B', 'V', 'C', 'S', 'D', 'F', 'R'];
    }

    if (_allWords.isEmpty) {
      setState(() {
        noMoreWords = true;
        isLoading = false;
      });
      return;
    }

    _startLevel();
  }

  void _startLevel() {
    setState(() => isLoading = true);
    
    _gridSize = 7 + playingLevel; 
    if (_gridSize > 14) _gridSize = 14; 
    
    int wordsCount = 3 + playingLevel;
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
    setState(() => isLoading = false);
  }

  List<Point<int>> _getAvailableDirections() {
    List<Point<int>> dirs = [const Point(1, 0), const Point(0, 1)]; 
    if (playingLevel >= 1) dirs.add(const Point(1, 1)); 
    if (playingLevel >= 2) dirs.addAll([const Point(-1, 0), const Point(0, -1)]); 
    if (playingLevel >= 3) dirs.addAll([const Point(-1, -1), const Point(1, -1), const Point(-1, 1)]); 
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
        setState(() => _currentSelection.add(p));
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
    
    setState(() => _currentSelection.clear());
    
    if (_foundWords.length == _currentWords.length && _currentWords.isNotEmpty) {
      _handleWinCondition();
    }
  }

  Future<void> _handleWinCondition() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && playingLevel == maxUnlockedLevel) {
      maxUnlockedLevel++;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'wordSearchLevelsCompleted': maxUnlockedLevel},
        SetOptions(merge: true),
      );
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2D3039),
        title: const Text('Gratulacje!', style: TextStyle(color: Colors.amber)),
        content: const Text('Odnaleziono wszystkie hasła liturgiczne.\nGotowy na trudniejszą planszę?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() => playingLevel++);
              _startLevel();
            },
            child: const Text('Następny poziom', style: TextStyle(color: Colors.amber)),
          )
        ],
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3039),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Jak grać?', style: TextStyle(color: Colors.amber)),
          ],
        ),
        content: const Text(
          'Szukaj ukrytych terminów liturgicznych na planszy.\n\n'
          'Zaznaczaj słowa przeciągając palcem po literach. Wraz z kolejnymi poziomami siatka rośnie, słów jest więcej, a układają się one we wszystkich kierunkach – także wspak i po skosie!\n\n'
          'Możesz wracać do poprzednich poziomów używając ikony listy w prawym górnym rogu.',
          style: TextStyle(color: Colors.white, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrozumiałem', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLevelSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D3039),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Wybierz poziom', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: maxUnlockedLevel + 1,
                  itemBuilder: (context, index) {
                    bool isCurrent = index == playingLevel;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: isCurrent ? Colors.amber : const Color(0xFF141F1C),
                        foregroundColor: isCurrent ? const Color(0xFF141F1C) : Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                        ),
                        elevation: isCurrent ? 4 : 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (playingLevel != index) {
                          setState(() => playingLevel = index);
                          _startLevel();
                        }
                      },
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141F1C),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (noMoreWords) {
      return Scaffold(
        backgroundColor: const Color(0xFF141F1C),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.amber),
        ),
        body: const Center(
          child: Text('Brak słów w bazie!', style: TextStyle(color: Colors.amber, fontSize: 24)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141F1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Poziom: ${playingLevel + 1}', style: const TextStyle(color: Colors.amber)),
        iconTheme: const IconThemeData(color: Colors.amber),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Instrukcja',
            onPressed: _showInstructions,
          ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            tooltip: 'Wybór poziomu',
            onPressed: _showLevelSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _currentWords.map((word) {
                bool isFound = _foundWords.contains(word);
                return Chip(
                  label: Text(word, style: TextStyle(
                    decoration: isFound ? TextDecoration.lineThrough : null,
                    color: isFound ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.bold
                  )),
                  backgroundColor: isFound ? Colors.transparent : Colors.amber.withOpacity(0.15),
                  side: BorderSide(color: isFound ? Colors.grey.shade800 : Colors.amber),
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
                            
                            Color cellColor = const Color(0xFF2D3039);
                            Color textColor = Colors.white70;
                            
                            if (isFound) {
                              cellColor = Colors.green.shade700;
                              textColor = Colors.white;
                            } else if (isSelected) {
                              cellColor = Colors.amber;
                              textColor = const Color(0xFF141F1C);
                            }
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  _grid[y][x],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
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