import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyQuotesCard extends StatefulWidget {
  const DailyQuotesCard({super.key});

  @override
  State<DailyQuotesCard> createState() => _DailyQuotesCardState();
}

class _DailyQuotesCardState extends State<DailyQuotesCard> {
  Map<String, dynamic>? _bibleQuote;
  Map<String, dynamic>? _otherQuote;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyQuotes();
  }

  _fetchDailyQuotes() async {
    final now = DateTime.now();
    final dateInt = now.year * 10000 + now.month * 100 + now.day;

    final bibleNumber = (dateInt % 30) + 1; 
    final otherNumber = (dateInt % 25) + 31; 

    try {
      final bibleSnapshot = await FirebaseFirestore.instance
          .collection('quote')
          .where('number', isEqualTo: bibleNumber)
          .limit(1)
          .get();

      final otherSnapshot = await FirebaseFirestore.instance
          .collection('quote')
          .where('number', isEqualTo: otherNumber)
          .limit(1)
          .get();

      final bibleData = bibleSnapshot.docs.isNotEmpty 
          ? bibleSnapshot.docs.first.data() 
          : {'quote': 'Brak cytatu biblijnego.', 'source': ''};
          
      final otherData = otherSnapshot.docs.isNotEmpty 
          ? otherSnapshot.docs.first.data() 
          : {'quote': 'Brak cytatu innego.', 'source': ''};

      if (mounted) {
        setState(() {
          _bibleQuote = bibleData;
          _otherQuote = otherData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Błąd pobierania cytatów: $e');
      if (mounted) {
        setState(() {
          _bibleQuote = {'quote': 'Błąd połączenia.', 'source': ''};
          _otherQuote = {'quote': 'Błąd połączenia.', 'source': ''};
          _isLoading = false;
        });
      }
    }
  }

  int _calculateDaysToChristmas() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final christmas = DateTime(now.year, 12, 25);
    
    return christmas.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (_bibleQuote == null || _otherQuote == null) {
      return const SizedBox.shrink();
    }

    final daysToChristmas = _calculateDaysToChristmas();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3039),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (daysToChristmas >= 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_border, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    daysToChristmas == 0 
                        ? 'Dziś jest Boże Narodzenie!' 
                        : 'Do Bożego Narodzenia: $daysToChristmas dni',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_border, color: Colors.amber, size: 20),
                ],
              ),
            ),

          _buildQuoteSection(
            quote: _bibleQuote!['quote'],
            source: _bibleQuote!['source'],
            icon: Icons.menu_book_rounded,
            iconColor: Colors.amber,
            isFirst: daysToChristmas < 0,
          ),
          Divider(color: Colors.grey.shade800, height: 1, thickness: 1),
          
          _buildQuoteSection(
            quote: _otherQuote!['quote'],
            source: _otherQuote!['source'],
            icon: Icons.format_quote_rounded,
            iconColor: Colors.blueAccent,
            isFirst: false,
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection({
    required String quote, 
    required String source, 
    required IconData icon, 
    required Color iconColor,
    required bool isFirst,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: isFirst ? const BorderRadius.vertical(top: Radius.circular(15)) : null,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Słowo na dziś',
                style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$quote"',
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '– $source',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}