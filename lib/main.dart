import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: RiverpodTasksApp()));
}

class RiverpodTasksApp extends ConsumerWidget {
  const RiverpodTasksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Riverpod Tasks',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const lightColors = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4F46E5),
      onPrimary: Colors.white,
      secondary: Color(0xFF7C3AED),
      onSecondary: Colors.white,
      tertiary: Color(0xFFF59E0B),
      onTertiary: Colors.white,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      surface: Color(0xFFF8FAFC),
      onSurface: Color(0xFF0F172A),
      outline: Color(0xFFE2E8F0),
      surfaceContainerHighest: Color(0xFFF1F5F9),
    );

    const darkColors = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF818CF8),
      onPrimary: Color(0xFF1E1B4B),
      secondary: Color(0xFFA78BFA),
      onSecondary: Color(0xFF2E1065),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF451A03),
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      surface: Color(0xFF0F172A),
      onSurface: Color(0xFFE2E8F0),
      outline: Color(0xFF334155),
      surfaceContainerHighest: Color(0xFF1E293B),
    );

    final colors = isDark ? darkColors : lightColors;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: brightness,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        color: isDark ? colors.surfaceContainerHighest : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colors.surfaceContainerHighest
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: colors.onSurface.withAlpha(150)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        elevation: 0,
      ),
    );
  }
}
