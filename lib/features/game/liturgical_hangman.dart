import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class LiturgicalHangman extends StatefulWidget {
  const LiturgicalHangman({super.key});

  @override
  State<LiturgicalHangman> createState() => _LiturgicalHangmanState();
}

class _LiturgicalHangmanState extends State<LiturgicalHangman> {
  String currentWord = "";
  String currentDescription = ""; 
  Set<String> guessedLetters = {};
  int wrongGuesses = 0;
  
  int maxUnlockedLevel = 0;
  int playingLevel = 0;

  bool isLoading = true;
  bool noMoreWords = false;

  final String alphabet = "AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŹŻ";

  @override
  void initState() {
    super.initState();
    _loadUserDataAndWord();
  }

  Future<void> _loadUserDataAndWord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      
      final data = doc.data();
      if (data != null && data.containsKey('hangmanLevelsCompleted')) {
        setState(() {
          maxUnlockedLevel = data['hangmanLevelsCompleted'];
        });
      } else {
        await docRef.set({
          'hangmanLevelsCompleted': 0
        }, SetOptions(merge: true));
        
        setState(() {
          maxUnlockedLevel = 0;
        });
      }
    }

    playingLevel = maxUnlockedLevel;
    await _fetchNewWord();
  }

  Future<void> _fetchNewWord() async {
    setState(() => isLoading = true);
    
    int levelToPlay = playingLevel + 1;

    final snapshot = await FirebaseFirestore.instance
        .collection('liturgical_terms')
        .where('lvl', isEqualTo: levelToPlay)
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        noMoreWords = true;
        isLoading = false;
      });
      return;
    }

    final random = Random();
    final doc = snapshot.docs[random.nextInt(snapshot.docs.length)];
    setState(() {
      currentWord = doc['word'].toString().toUpperCase();
      currentDescription = doc.data().containsKey('description') 
          ? doc['description'].toString() 
          : 'Brak definicji w bazie.';
      guessedLetters.clear();
      wrongGuesses = 0;
      noMoreWords = false;
      isLoading = false;
    });
  }

  void _guessLetter(String letter) {
    if (guessedLetters.contains(letter) || wrongGuesses >= 6 || isLoading || noMoreWords) return;

    setState(() {
      guessedLetters.add(letter);
      if (!currentWord.contains(letter)) {
        wrongGuesses++;
      }
    });

    _checkWinCondition();
  }

  void _checkWinCondition() async {
    bool isWon = currentWord.split('').every((l) => l == ' ' || guessedLetters.contains(l));
    
    if (isWon) {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && playingLevel == maxUnlockedLevel) {
        maxUnlockedLevel++;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'hangmanLevelsCompleted': maxUnlockedLevel},
          SetOptions(merge: true),
        );
      }
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog( 
            backgroundColor: const Color(0xFF2D3039),
            title: const Text('Gratulacje!', style: TextStyle(color: Colors.amber)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentWord, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentDescription, 
                    style: const TextStyle(color: Colors.white70)
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  setState(() {
                    playingLevel++;
                  });
                  _fetchNewWord(); 
                },
                child: const Text('Następny poziom', style: TextStyle(color: Colors.amber)),
              )
            ],
          ),
        );
      }
    } else if (wrongGuesses >= 6) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => AlertDialog( 
            backgroundColor: const Color(0xFF2D3039),
            title: const Text('Koniec gry', style: TextStyle(color: Colors.red)),
            content: const Text(
              'Dzwon został narysowany. Nie udało Ci się odgadnąć tego terminu.', 
              style: TextStyle(color: Colors.white)
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); 
                  setState(() {
                    guessedLetters.clear();
                    wrongGuesses = 0;
                  });
                },
                child: const Text('Spróbuj ponownie', style: TextStyle(color: Colors.amber)),
              )
            ],
          ),
        );
      }
    }
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
          'Twoim zadaniem jest odgadnięcie ukrytego pojęcia lub frazy liturgicznej poprzez podawanie liter.\n\n'
          'Za każdą niepoprawną literę rysowany jest kolejny element dzwonu. Masz 6 szans, zanim dzwon zostanie narysowany w całości i przegrasz!\n\n'
          'W prawym górnym rogu znajdziesz przycisk wyboru poziomu – w każdej chwili możesz wrócić do poprzednich haseł.',
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
                          _fetchNewWord();
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
          actions: [
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Wybór poziomu',
              onPressed: _showLevelSelector,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.amber, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Nowe słowa już wkrótce!',
                  style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gratulacje! Odgadłeś wszystkie terminy liturgiczne dostępne obecnie w bazie. Użyj przycisku wyboru poziomu (w prawym górnym rogu), aby powtórzyć starsze hasła.',
                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: const Color(0xFF141F1C),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Wróć do menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      );
    }

    String displayWord = currentWord.split('').map((l) {
      if (l == ' ') return '   '; 
      return guessedLetters.contains(l) ? l : '_';
    }).join(' ');

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomPaint(
                      size: const Size(150, 200),
                      painter: BellPainter(wrongGuesses),
                    ),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayWord,
                  style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 4, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: alphabet.split('').map((letter) {
                  bool isUsed = guessedLetters.contains(letter);
                  bool isCorrect = currentWord.contains(letter);
                  
                  Color bgColor = const Color(0xFF2D3039);
                  Color textColor = Colors.amber;
                  
                  if (isUsed) {
                    bgColor = isCorrect ? Colors.green.shade700 : Colors.red.shade700;
                    textColor = Colors.white;
                  }

                  return SizedBox(
                    width: MediaQuery.of(context).size.width > 600 ? 45 : 36,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: bgColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => _guessLetter(letter),
                      child: Text(letter, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BellPainter extends CustomPainter {
  final int mistakes;
  BellPainter(this.mistakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (mistakes >= 1) canvas.drawArc(Rect.fromLTWH(size.width / 2 - 15, 10, 30, 30), 3.14, 3.14, false, paint);
    
    if (mistakes >= 2) {
      final path = Path();
      path.moveTo(size.width / 2 - 20, 25);
      path.quadraticBezierTo(size.width / 2 - 40, 80, size.width / 2 - 60, 120);
      path.lineTo(size.width / 2 + 60, 120);
      path.quadraticBezierTo(size.width / 2 + 40, 80, size.width / 2 + 20, 25);
      path.close();
      canvas.drawPath(path, paint);
    }
    
    if (mistakes >= 3) canvas.drawCircle(Offset(size.width / 2, 130), 10, paint..style = PaintingStyle.fill);
    
    if (mistakes >= 4) {
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(size.width / 2 + 30, 10), Offset(size.width / 2 + 80, -20), paint);
    }
    
    if (mistakes >= 5) canvas.drawArc(Rect.fromLTWH(size.width / 2 - 100, 50, 40, 60), 1.5, 3.14, false, paint);
    
    if (mistakes >= 6) canvas.drawArc(Rect.fromLTWH(size.width / 2 + 60, 50, 40, 60), -1.5, 3.14, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}