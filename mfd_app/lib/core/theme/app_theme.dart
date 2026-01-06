import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- ONYX SYSTEM PALETTE ---
  static const Color voidBlack = Color(0xFF0B0E14);      // Main BG
  static const Color commandGrey = Color(0xFF1F2937);    // Surface/Input
  static const Color borderGrey = Color(0xFF374151);     // Borders
  
  static const Color signalGreen = Color(0xFF00DC82);    // Success / Growth (Neon)
  static const Color electricBlue = Color(0xFF3B82F6);   // Action / Primary
  static const Color alertRed = Color(0xFFEF4444);       // Error / Burn
  static const Color warningAmber = Color(0xFFF59E0B);   // Warning
  
  static const Color textHigh = Colors.white;
  static const Color textMedium = Color(0xFF9CA3AF);     // Slate 400
  static const Color textLow = Color(0xFF6B7280);        // Slate 500

  // --- LEGACY MAPPINGS (Backward Compatibility) ---
  static const Color deepBlue = voidBlack; 
  static const Color slateGray = textMedium;
  static const Color accentAmber = warningAmber;
  static const Color emeraldGreen = signalGreen;
  static const Color cardLight = Colors.white;
  static const Color cardDark = commandGrey;

  static ThemeData get lightTheme {
    // Onyx doesn't really do "Light Mode", but we enable a professional stark white mode.
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      primaryColor: voidBlack,
      colorScheme: const ColorScheme.light(
        primary: voidBlack,
        secondary: electricBlue,
        surface: Colors.white,
        error: alertRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBlack,
      primaryColor: electricBlue,
      canvasColor: voidBlack, // For Sidebar
      cardColor: commandGrey,
      
      colorScheme: const ColorScheme.dark(
        primary: electricBlue,
        secondary: signalGreen, // For accents
        surface: commandGrey,
        background: voidBlack,
        error: alertRed,
        tertiary: warningAmber, // Used for "Pacing" sometimes
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: voidBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.getFont('JetBrains Mono', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: commandGrey.withOpacity(0.5), // Glassy
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: borderGrey, width: 1),
          borderRadius: BorderRadius.circular(8), // Sharper corners for Pro feel
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 1,
      ),

      // Typography Strategy: Inter for UI, Mono for Data
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textHigh, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: textHigh, fontWeight: FontWeight.w600),
        bodyMedium: GoogleFonts.inter(color: textMedium), // Default text
        labelLarge: GoogleFonts.getFont('JetBrains Mono', color: textHigh, fontWeight: FontWeight.w500), // Buttons
        headlineSmall: GoogleFonts.inter(color: textHigh, fontWeight: FontWeight.bold),
      ),
      
      iconTheme: const IconThemeData(color: textMedium, size: 20),
    );
  }
}
