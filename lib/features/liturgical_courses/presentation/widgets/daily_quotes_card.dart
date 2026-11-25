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
  int _selectedIndex = 0; // 0 = Bible, 1 = Other

  @override
  void initState() {
    super.initState();
    _fetchDailyQuotes();
  }

  Future<void> _fetchDailyQuotes() async {
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

  String? _getAdventWeek() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    if (month == 11 && day >= 29) return 'I tydzień Adwentu';
    if (month == 12) {
      if (day >= 1 && day <= 5) return 'I tydzień Adwentu';
      if (day >= 6 && day <= 12) return 'II tydzień Adwentu';
      if (day >= 13 && day <= 19) return 'III tydzień Adwentu';
      if (day >= 20 && day <= 24) return 'IV tydzień Adwentu';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final liturgicalColor = Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator(color: liturgicalColor)),
      );
    }

    if (_bibleQuote == null || _otherQuote == null) {
      return const SizedBox.shrink();
    }

    final daysToChristmas = _calculateDaysToChristmas();
    final adventWeek = _getAdventWeek();

    final isBible = _selectedIndex == 0;
    final currentData = isBible ? _bibleQuote! : _otherQuote!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF23262F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF343844), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF171920),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentButton(
                    label: 'Pismo Święte',
                    icon: Icons.menu_book_rounded,
                    isSelected: _selectedIndex == 0,
                    activeColor: liturgicalColor,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildSegmentButton(
                    label: 'Liturgia',
                    icon: Icons.format_quote_rounded,
                    isSelected: _selectedIndex == 1,
                    activeColor: liturgicalColor,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Content with smooth switch
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Column(
              key: ValueKey(_selectedIndex),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '„${currentData['quote']}”',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if ((currentData['source'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— ${currentData['source']}',
                      style: TextStyle(
                        color: liturgicalColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 3. Day to Christmas
          if (daysToChristmas >= 0) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: liturgicalColor, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    daysToChristmas == 0
                        ? 'Dziś jest Boże Narodzenie!'
                        : (adventWeek != null
                            ? '$adventWeek • Do świąt: $daysToChristmas dni'
                            : 'Do Bożego Narodzenia: $daysToChristmas dni'),
                    style: TextStyle(
                      color: Color.lerp(liturgicalColor, Colors.white, 0.35),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D313D) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: activeColor.withOpacity(0.4), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}