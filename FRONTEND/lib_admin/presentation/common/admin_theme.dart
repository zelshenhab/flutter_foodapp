import 'package:flutter/material.dart';

ThemeData buildAdminTheme() {
  const bg = Color(0xFF121212);
  const surface = Color(0xFF1E1E1E);
  const text = Color(0xFFEDEDED);
  const accent = Color(0xFFFF7A00);

  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: bg,
    cardColor: const Color(0xFF1A1A1A),
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent,
      background: bg,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent),
      ),
      hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
    ),
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}
