import 'package:flutter/material.dart';

/// Raw colour tokens taken from the BelieveInYou Figma file.
///
/// Values live here only as tokens; widgets read them through `ThemeData`,
/// never by importing this class directly.
abstract final class AppColors {
  /// Top stop of the app background gradient, and the flat fill of a sheet
  /// raised over it.
  static const Color surfaceGradientStart = Color(0xFFF2F7FB);

  /// Bottom stop of the app background gradient.
  static const Color surfaceGradientEnd = Color(0xFFE7EFF9);

  /// Primary text colour on the light surface — wordmark and headings.
  ///
  /// Doubles as the fill of a selected slot tab, which is why [onInverse]
  /// exists.
  static const Color textPrimary = Color(0xFF16233C);

  /// Text drawn on top of [textPrimary] — the selected slot tab's label.
  static const Color onInverse = surfaceGradientStart;

  /// Primary text held back — a section label over a card — at 70% alpha.
  static const Color textPrimarySubtle = Color(0xB316233C);

  /// Primary text on a closed slot's name — at 28% alpha.
  static const Color textPrimaryMuted = Color(0x4716233C);

  /// Primary text on a closed slot's lock glyph — at 10% alpha.
  static const Color textPrimaryFaint = Color(0x1A16233C);

  /// Placeholder inside the note field — [textPrimary] at 50% alpha.
  static const Color textPlaceholder = Color(0x8016233C);

  /// Secondary text colour — body copy under a heading.
  static const Color textSecondary = Color(0xFF8695AE);

  /// Secondary text held back — section labels — at 60% alpha.
  static const Color textSecondaryMuted = Color(0x998695AE);

  /// Secondary text on a group or month label — at 50% alpha.
  static const Color textSecondaryHalf = Color(0x808695AE);

  /// Day number on a heatmap cell with no recording — at 40% alpha.
  static const Color textSecondaryDim = Color(0x668695AE);

  /// Weekday initials over a heatmap — at 35% alpha.
  static const Color textSecondaryFaint = Color(0x598695AE);

  /// Brand teal — sunrise mark, primary button fill, active page indicator,
  /// trend line and its points.
  static const Color brand = Color(0xFF0E9AA7);

  /// Text and icons drawn on top of [brand].
  static const Color onBrand = Color(0xFFFFFFFF);

  /// Brand teal held back — bullet dot on a card — at 60% alpha.
  static const Color brandMuted = Color(0x990E9AA7);

  /// Fill of a card raised off the background gradient.
  static const Color surfaceCard = Color(0xFFFDFEFF);

  /// Fill of an unselected control on the background — slot tab, badge — and of
  /// a heatmap cell whose day holds no recording.
  static const Color surfaceMuted = Color(0xFFDDE7F2);

  /// Fill of an unselected scale tile — [surfaceMuted] at 45% alpha.
  static const Color scaleTileUnselected = Color(0x73DDE7F2);

  /// Hairline border around a card or field, the rule between sheet rows, and
  /// the sheet's drag handle.
  static const Color border = Color(0xFFC6D4E4);

  /// Page indicator dot for a page not yet reached — same value as [border].
  static const Color pageIndicatorInactive = border;

  /// Page indicator dot for a page already passed — [pageIndicatorInactive] at
  /// 50% alpha.
  static const Color pageIndicatorSeen = Color(0x80C6D4E4);

  /// Scale 1, *very bad*.
  ///
  /// [scale1] through [scale5] are one blue hue darkening with the value, never
  /// a red-to-green ramp: a low value is data, not a failure.
  static const Color scale1 = Color(0xFFCFD9F0);

  /// Scale 2, *bad*.
  static const Color scale2 = Color(0xFFA9BCE7);

  /// Scale 3, *neutral*.
  static const Color scale3 = Color(0xFF7F99DA);

  /// Scale 4, *good*.
  static const Color scale4 = Color(0xFF5674CB);

  /// Scale 5, *very good*.
  static const Color scale5 = Color(0xFF3651B0);

  /// Day number over a pale scale fill — [scale1], [scale2] — at 75% alpha.
  static const Color onScaleLight = Color(0xBF22305A);

  /// Day number over a mid scale fill — [scale3] — at 75% alpha.
  static const Color onScaleMid = Color(0xBF1B2547);

  /// Day number over a deep scale fill — [scale4], [scale5] — at 75% alpha.
  static const Color onScaleDark = Color(0xBFFFFFFF);

  /// Sunrise mark, filled outer arc — [brand] at 7% alpha.
  static const Color brandArcOuterFill = Color(0x120E9AA7);

  /// Sunrise mark, outer stroke — [brand] at 22% alpha.
  static const Color brandArcOuterStroke = Color(0x380E9AA7);

  /// Sunrise mark, middle stroke — [brand] at 50% alpha.
  static const Color brandArcMiddleStroke = Color(0x800E9AA7);

  /// Sunrise mark, inner stroke — [brand] at 82% alpha.
  static const Color brandArcInnerStroke = Color(0xD10E9AA7);

  /// Fill of an unselected emotion chip in the *difficult* group.
  static const Color emotionDifficultFill = Color(0xFFDCE4F5);

  /// Label of an unselected emotion chip in the *difficult* group.
  static const Color emotionDifficultText = Color(0xFF2E3E63);

  /// Fill of an unselected emotion chip in the *settled* group.
  static const Color emotionSettledFill = Color(0xFFD0EBEA);

  /// Label of an unselected emotion chip in the *settled* group.
  static const Color emotionSettledText = Color(0xFF12474A);

  /// Destructive action — deleting every recording, and nothing else.
  ///
  /// The only red in the app. A scale value is never red: see [scale1].
  static const Color danger = Color(0xFFC4453F);

  static const Color loadingBackground = Color.fromARGB(141, 13, 13, 38);

  /// Background gradient of the app surface, top to bottom.
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[surfaceGradientStart, surfaceGradientEnd],
  );

  /// Shadow cast upward by the bottom navigation bar, lifting it off the
  /// scrolling content behind it.
  static const List<BoxShadow> bottomNavShadow = <BoxShadow>[
    BoxShadow(color: Color(0x1416233C), offset: Offset(0, -2), blurRadius: 3),
    BoxShadow(color: Color(0x0F16233C), offset: Offset(0, -12), blurRadius: 16),
  ];

  /// Shadow under a toggle's knob, holding it off the track.
  static const List<BoxShadow> toggleKnobShadow = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2),
  ];
}
