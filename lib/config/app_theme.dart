import 'package:flutter/material.dart';

class AppColors {
  static const bg        = Color(0xFF0B0F1E);
  static const card      = Color(0xFF151929);
  static const card2     = Color(0xFF1C2135);
  static const primary   = Color(0xFF6C63FF);
  static const primary2  = Color(0xFF8B85FF);
  static const green     = Color(0xFF00C48C);
  static const red       = Color(0xFFFF5B5B);
  static const yellow    = Color(0xFFFFB800);
  static const textPri   = Color(0xFFFFFFFF);
  static const textSec   = Color(0xFF8B9BC7);
  static const border    = Color(0xFF252A3D);
  static const bnbYellow = Color(0xFFF3BA2F);
  static const ethBlue   = Color(0xFF627EEA);
  static const polyPurple= Color(0xFF8247E5);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.card,
      onSurface: AppColors.textPri,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPri),
      titleTextStyle: TextStyle(
        color: AppColors.textPri,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSec),
      hintStyle: const TextStyle(color: AppColors.textSec),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    fontFamily: 'SF Pro Display',
  );
}
