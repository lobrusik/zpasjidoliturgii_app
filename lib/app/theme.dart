import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //Base palette
  static const Color _backgroundDark = Color(0xFF0F1014);
  static const Color _surfaceDark = Color(0xFF1A1C23);
  static const Color _textWhite = Color(0xFFF8FAFC);
  static const Color _textGrey = Color(0xFF94A3B8);

  //Colors of the Liturgical Seasons
  static const Color _liturgicalGold = Color(0xFFE68A00);   //Christmas, Easter
  static const Color _liturgicalViolet = Color(0xFF930EE6); //Advent, Lent
  static const Color _liturgicalRose = Color(0xFFD84B8C);   //Gaudete & Laetare
  static const Color _liturgicalRed = Color(0xFFC62828);    //Triduum
  static const Color _liturgicalGreen = Color(0xFF2E7D32);  //Ordinary Time

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    
    //Automatically retrieve the color for today's date
    final Color activePrimary = LiturgicalCalendar.getColorForDate(DateTime.now());

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: _backgroundDark,
      
      colorScheme: ColorScheme.dark(
        primary: activePrimary,
        surface: _surfaceDark,
        onSurface: _textWhite,
      ),

      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 28, fontWeight: FontWeight.bold, color: _textWhite, height: 1.2,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.bold, color: _textWhite,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: _textWhite,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16, color: _textGrey, height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14, color: _textGrey,
        ),
      ),

      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D3039), width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activePrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundDark,
        foregroundColor: _textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _textWhite),
      ),
    );
  }
}

//Liturgical Season Calculator
class LiturgicalCalendar {
  static Color getColorForDate(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final year = today.year;

    //Calculation of Key Floating Dates
    final easter = _calculateEaster(year);
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final laetareSunday = easter.subtract(const Duration(days: 21));
    final holyThursday = easter.subtract(const Duration(days: 3));
    final holySaturday = easter.subtract(const Duration(days: 1));
    final pentecost = easter.add(const Duration(days: 49));

    final christmas = DateTime(year, 12, 25);
    final firstSundayOfAdvent = christmas.subtract(Duration(days: christmas.weekday + 21));
    final gaudeteSunday = firstSundayOfAdvent.add(const Duration(days: 14));

    final epiphany = DateTime(year, 1, 6);
    final daysAfterEpiphany = 7 - (epiphany.weekday % 7);
    final baptismOfTheLord = epiphany.add(Duration(days: daysAfterEpiphany));


    //Pink:Gaudete & Laetare
    if (_isSameDay(today, gaudeteSunday) || _isSameDay(today, laetareSunday)) {
      return AppTheme._liturgicalRose;
    }

    //Red: Triduum
    if (!today.isBefore(holyThursday) && !today.isAfter(holySaturday)) {
      return AppTheme._liturgicalRed;
    }

    //GOLD: Christmas and the Easter Season
    final isChristmasSeason = !today.isBefore(christmas) || !today.isAfter(baptismOfTheLord);
    final isEasterSeason = !today.isBefore(easter) && !today.isAfter(pentecost);
    if (isChristmasSeason || isEasterSeason) {
      return AppTheme._liturgicalGold;
    }

    //Violet: Adwent and Lent
    final isAdvent = !today.isBefore(firstSundayOfAdvent) && today.isBefore(christmas);
    final isLent = !today.isBefore(ashWednesday) && today.isBefore(holyThursday);
    if (isAdvent || isLent) {
      return AppTheme._liturgicalViolet;
    }

    //Green - Ordinary Time (basic)
    return AppTheme._liturgicalGreen;
  }

  //The Meeus/Jones/Butcher algorithm for determining the date of Easter in the Gregorian calendar
  static DateTime _calculateEaster(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(year, month, day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isAdvent(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final christmas = DateTime(date.year, 12, 25);
    final firstSundayOfAdvent = christmas.subtract(Duration(days: christmas.weekday + 21));
    
    return !today.isBefore(firstSundayOfAdvent) && today.isBefore(christmas);
  }

  static bool isChristmas(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final christmas = DateTime(date.year, 12, 25);
    final epiphany = DateTime(date.year, 1, 6);
    final daysAfterEpiphany = 7 - (epiphany.weekday % 7);
    final baptismOfTheLord = epiphany.add(Duration(days: daysAfterEpiphany));
    
    return !today.isBefore(christmas) || !today.isAfter(baptismOfTheLord);
  }
}