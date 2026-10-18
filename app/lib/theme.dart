import 'package:flutter/material.dart';

/// Hauptfarbe der App. Schwarz und Weiß sind einfarbige Looks – die Akzentfarbe bringt dort die Farbe.
enum PrimaryChoice {
  darkRed('Dunkelrot', Color(0xFF8C1C2B)),
  olive('Oliv', Color(0xFF5B6B2F)),
  black('Schwarz', Color(0xFF111111)),
  blue('Blau', Color(0xFF1E4FA3)),
  white('Weiß', Color(0xFFF4F3EF));

  const PrimaryChoice(this.label, this.swatch);
  final String label;

  /// Farbe für die Auswahl in den Einstellungen.
  final Color swatch;

  bool get isMonochrome => this == black || this == white;

  /// Zu jeder Hauptfarbe passende Akzentfarben; die erste ist der Standard.
  List<AccentChoice> get accents => switch (this) {
    darkRed => const [AccentChoice.gold, AccentChoice.sand, AccentChoice.sage, AccentChoice.graphite],
    olive => const [AccentChoice.terracotta, AccentChoice.mustard, AccentChoice.cream, AccentChoice.sand],
    black => const [AccentChoice.gold, AccentChoice.signalRed, AccentChoice.iceBlue, AccentChoice.mint],
    blue => const [AccentChoice.coral, AccentChoice.amber, AccentChoice.mint, AccentChoice.silver],
    white => const [AccentChoice.ink, AccentChoice.wine, AccentChoice.navy, AccentChoice.moss],
  };
}

/// Akzentfarbe: Navigationsleiste, Hervorhebungen, Verlauf im Kalorienring.
enum AccentChoice {
  gold('Champagner', Color(0xFFC9A54C)),
  sand('Sand', Color(0xFFC8AE8A)),
  sage('Salbei', Color(0xFF7F9C82)),
  graphite('Graphit', Color(0xFF55555C)),
  terracotta('Terrakotta', Color(0xFFC2643A)),
  mustard('Senf', Color(0xFFC9A227)),
  cream('Creme', Color(0xFFD9CBA3)),
  signalRed('Signalrot', Color(0xFFD32F2F)),
  iceBlue('Eisblau', Color(0xFF6FA8DC)),
  mint('Mint', Color(0xFF4FB892)),
  coral('Koralle', Color(0xFFE2725B)),
  amber('Bernstein', Color(0xFFE0A030)),
  silver('Silber', Color(0xFF9AA3AE)),
  ink('Tinte', Color(0xFF2B2B30)),
  wine('Weinrot', Color(0xFF8C1C2B)),
  navy('Marine', Color(0xFF1E4FA3)),
  moss('Moos', Color(0xFF5B6B2F));

  const AccentChoice(this.label, this.color);
  final String label;
  final Color color;
}

class AppPalette {
  const AppPalette(this.primary, this.accent);
  final PrimaryChoice primary;
  final AccentChoice accent;

  static const standard = AppPalette(PrimaryChoice.darkRed, AccentChoice.gold);

  @override
  bool operator ==(Object other) => other is AppPalette && other.primary == primary && other.accent == accent;

  @override
  int get hashCode => Object.hash(primary, accent);
}

/// Feste Farben für Eiweiß, Kohlenhydrate und Fett – unabhängig von der Farbwahl, damit die Makros überall
/// gleich aussehen. Geprüfte Kategorie-Palette (auch bei Farbsehschwäche unterscheidbar), je Hell/Dunkel.
class MacroColors {
  static Color protein(Brightness b) => b == Brightness.light ? const Color(0xFF2A78D6) : const Color(0xFF3987E5);
  static Color carbs(Brightness b) => b == Brightness.light ? const Color(0xFFEB6834) : const Color(0xFFD95926);
  static Color fat(Brightness b) => b == Brightness.light ? const Color(0xFF1BAF7A) : const Color(0xFF199E70);
}

ColorScheme buildColorScheme(Brightness brightness, AppPalette palette) {
  final light = brightness == Brightness.light;
  var scheme = switch (palette.primary) {
    PrimaryChoice.black || PrimaryChoice.white => ColorScheme.fromSeed(
      seedColor: const Color(0xFF808080),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    ),
    final p => ColorScheme.fromSeed(
      seedColor: p.swatch,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  };

  // Einfarbige Looks: Schwarz = Carbon (im Dunkeln echtes Schwarz), Weiß = Porzellan (im Hellen reines Weiß).
  scheme = switch ((palette.primary, light)) {
    (PrimaryChoice.black, true) => scheme.copyWith(
      primary: const Color(0xFF111111),
      onPrimary: Colors.white,
      surface: const Color(0xFFF2F2F0),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFAFAF8),
      surfaceContainer: const Color(0xFFEDEDEA),
      surfaceContainerHigh: const Color(0xFFE6E6E3),
      surfaceContainerHighest: const Color(0xFFDDDDDA),
    ),
    (PrimaryChoice.black, false) => scheme.copyWith(
      primary: const Color(0xFFF2F2F2),
      onPrimary: Colors.black,
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF0D0D0D),
      surfaceContainer: const Color(0xFF141414),
      surfaceContainerHigh: const Color(0xFF1C1C1C),
      surfaceContainerHighest: const Color(0xFF262626),
    ),
    (PrimaryChoice.white, true) => scheme.copyWith(
      primary: const Color(0xFF2B2B30),
      onPrimary: Colors.white,
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF7F6F3),
      surfaceContainer: const Color(0xFFF1F0EC),
      surfaceContainerHigh: const Color(0xFFEAE9E5),
      surfaceContainerHighest: const Color(0xFFE2E1DC),
    ),
    (PrimaryChoice.white, false) => scheme.copyWith(
      primary: Colors.white,
      onPrimary: const Color(0xFF1A1A1A),
      surface: const Color(0xFF1A1A1C),
      surfaceContainerLowest: const Color(0xFF141416),
      surfaceContainerLow: const Color(0xFF202023),
      surfaceContainer: const Color(0xFF26262A),
      surfaceContainerHigh: const Color(0xFF2E2E32),
      surfaceContainerHighest: const Color(0xFF38383D),
    ),
    _ => scheme,
  };

  // Bunte Hauptfarben: Flächen fast neutral halten, die Farbe gehört den Bedienelementen.
  if (!palette.primary.isMonochrome) {
    // Im Dunkeln bleibt die Hauptfarbe kräftig (Standard wäre ein Pastellton) – Dunkelrot soll rot bleiben.
    if (!light) {
      final hsl = HSLColor.fromColor(palette.primary.swatch);
      final strong = hsl.withLightness(0.47).withSaturation((hsl.saturation * 1.1).clamp(0, 1)).toColor();
      scheme = scheme.copyWith(primary: strong, onPrimary: Colors.white);
    }
    final neutral = ColorScheme.fromSeed(
      seedColor: palette.primary.swatch,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    );
    scheme = scheme.copyWith(
      surface: neutral.surface,
      surfaceContainerLowest: neutral.surfaceContainerLowest,
      surfaceContainerLow: neutral.surfaceContainerLow,
      surfaceContainer: neutral.surfaceContainer,
      surfaceContainerHigh: neutral.surfaceContainerHigh,
      surfaceContainerHighest: neutral.surfaceContainerHighest,
      onSurfaceVariant: neutral.onSurfaceVariant,
      outlineVariant: neutral.outlineVariant,
    );
  }

  // Akzent: kräftig für Linien und Verläufe, als Fläche nur zart getönt.
  final accent = ColorScheme.fromSeed(
    seedColor: palette.accent.color,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  return scheme.copyWith(
    secondary: accent.primary,
    onSecondary: accent.onPrimary,
    secondaryContainer: Color.alphaBlend(accent.primary.withValues(alpha: light ? 0.20 : 0.28), scheme.surface),
    onSecondaryContainer: scheme.onSurface,
  );
}

/// Farben für den Kalorienring: bei einfarbigen Looks von Haupt- zu Akzentfarbe, sonst ein Verlauf innerhalb
/// der Hauptfarbe (zwei verschiedene Farbtöne würden in der Mitte trüb werden).
List<Color> ringColors(ColorScheme scheme, AppPalette palette) => palette.primary.isMonochrome
    ? [scheme.primary, scheme.secondary]
    : [Color.lerp(scheme.primary, scheme.surface, 0.55)!, scheme.primary];

const _font = 'Manrope';

/// Manrope ist eine variable Schrift: das Gewicht muss als Achse „wght“ gesetzt werden.
TextStyle? _weighted(TextStyle? style, FontWeight weight, {double? letterSpacing}) => style?.copyWith(
  fontFamily: _font,
  fontWeight: weight,
  fontVariations: [FontVariation('wght', weight.value.toDouble())],
  letterSpacing: letterSpacing,
);

TextTheme _textTheme(TextTheme base) => base.copyWith(
  displayLarge: _weighted(base.displayLarge, FontWeight.w800, letterSpacing: -1.5),
  displayMedium: _weighted(base.displayMedium, FontWeight.w800, letterSpacing: -1),
  displaySmall: _weighted(base.displaySmall, FontWeight.w800, letterSpacing: -0.5),
  headlineLarge: _weighted(base.headlineLarge, FontWeight.w800, letterSpacing: -0.5),
  headlineMedium: _weighted(base.headlineMedium, FontWeight.w800, letterSpacing: -0.5),
  headlineSmall: _weighted(base.headlineSmall, FontWeight.w700, letterSpacing: -0.25),
  titleLarge: _weighted(base.titleLarge, FontWeight.w700, letterSpacing: -0.25),
  titleMedium: _weighted(base.titleMedium, FontWeight.w700),
  titleSmall: _weighted(base.titleSmall, FontWeight.w700),
  bodyLarge: _weighted(base.bodyLarge, FontWeight.w500),
  bodyMedium: _weighted(base.bodyMedium, FontWeight.w500),
  bodySmall: _weighted(base.bodySmall, FontWeight.w500),
  labelLarge: _weighted(base.labelLarge, FontWeight.w700),
  labelMedium: _weighted(base.labelMedium, FontWeight.w700),
  labelSmall: _weighted(base.labelSmall, FontWeight.w700),
);

/// Gleich breite Ziffern, damit Zahlen beim Hochzählen nicht springen.
const tabularFigures = [FontFeature.tabularFigures()];

ThemeData buildTheme(Brightness brightness, [AppPalette palette = AppPalette.standard]) {
  final scheme = buildColorScheme(brightness, palette);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: _font);
  final text = _textTheme(base.textTheme);
  const radius = 20.0;

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: text.labelLarge?.copyWith(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      extendedTextStyle: text.labelLarge?.copyWith(fontSize: 15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: scheme.secondaryContainer,
        selectedForegroundColor: scheme.onSecondaryContainer,
        textStyle: text.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedColor: scheme.secondaryContainer,
      labelStyle: text.labelLarge,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titleTextStyle: text.bodyLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5), space: 24),
    progressIndicatorTheme: ProgressIndicatorThemeData(linearTrackColor: scheme.surfaceContainerHighest),
  );
}
