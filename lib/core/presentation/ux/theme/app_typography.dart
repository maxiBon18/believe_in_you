/// Text tokens taken from the BelieveInYou Figma file.
///
/// Grouped by the family that carries them: [AppDisplayText] for the serif
/// voice, [AppBodyText] for running copy and labels, [AppMonoText] for digits.
/// [AppFonts] holds the families themselves.
///
/// A style appears once. Where two places share every attribute, the constant
/// is named for the step rather than for one of its uses.
library;

import 'package:flutter/material.dart';
import 'package:believe_in_you/core/presentation/ux/theme/app_colors.dart';

/// The three font families the tokens below are set in.
abstract final class AppFonts {
  /// Serif display family — wordmark and headings.
  ///
  /// Requires a `fonts:` entry in `pubspec.yaml` and the `.ttf` files under
  /// `assets/fonts/`; without them Flutter silently falls back to Roboto.
  static const String display = 'Lora';

  /// Sans body family — paragraphs, labels, and button text.
  ///
  /// Same `pubspec.yaml` requirement as [display]. Registered as static
  /// Regular and Medium instances, so weight is the only axis a style sets.
  static const String body = 'DM Sans';

  /// Monospaced family — wall-clock times and counts, so digits keep a fixed
  /// width. Same `pubspec.yaml` requirement as [display].
  static const String mono = 'DM Mono';
}

/// Styles set in [AppFonts.display].
abstract final class AppDisplayText {
  /// Wordmark on the splash screen — Lora SemiBold 28/42, -0.56 track.
  static const TextStyle wordmark = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 42 / 28,
    letterSpacing: -0.56,
    color: AppColors.textPrimary,
  );

  /// Wordmark in the home header — Lora SemiBold 15/15, -0.15 track.
  static const TextStyle wordmarkMedium = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  /// Wordmark in a screen header — Lora SemiBold 13/19.5, -0.13 track.
  static const TextStyle wordmarkCompact = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 19.5 / 13,
    letterSpacing: -0.13,
    color: AppColors.textPrimary,
  );

  /// Screen heading — Lora SemiBold 24/33.
  static const TextStyle heading1 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 33 / 24,
    color: AppColors.textPrimary,
  );

  /// Screen heading at the smaller step — Lora SemiBold 20/28.
  static const TextStyle heading2 = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );

  /// Title of a sheet — the day a recording belongs to — Lora Medium 16/24.
  static const TextStyle sheetTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  /// Name of a closed slot — [sheetTitle]'s metrics, held back to
  /// [AppColors.textPrimaryMuted].
  static const TextStyle lockedSlotName = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.textPrimaryMuted,
  );
}

/// Styles set in [AppFonts.body].
abstract final class AppBodyText {
  /// Body copy — DM Sans Regular 16/26.
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 26 / 16,
    color: AppColors.textSecondary,
  );

  /// Body copy at the smaller step — DM Sans Regular 14/22.75.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22.75 / 14,
    color: AppColors.textSecondary,
  );

  /// Text inside a chart tooltip — DM Sans Regular 11/16.5.
  static const TextStyle tooltipLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16.5 / 11,
    color: AppColors.textPrimary,
  );

  /// Hint under a settings row's title — DM Sans Regular 12/19.5.
  static const TextStyle rowHint = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 19.5 / 12,
    color: AppColors.textSecondary,
  );

  /// Supporting line beside content — a slot's name, a saved-state notice —
  /// DM Sans Regular 14/20.
  ///
  /// Pairs with [AppMonoText.timeRange] where the line mixes prose and digits.
  static const TextStyle metaLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  /// Label on a card row, either side of a bullet, and a note's text in the
  /// summary — [metaLabel]'s metrics in [AppColors.textPrimary].
  static const TextStyle cardLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  /// Placeholder inside the note field — [metaLabel]'s metrics in
  /// [AppColors.textPlaceholder].
  static const TextStyle notePlaceholder = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textPlaceholder,
  );

  /// Title inside a card, on a disclosure row, and on a settings row —
  /// DM Sans Medium 14/20.
  static const TextStyle cardTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  /// Chevron opening a settings row — [cardTitle]'s metrics in
  /// [AppColors.textSecondaryDim].
  static const TextStyle chevronGlyph = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.textSecondaryDim,
  );

  /// Label on the destructive action — [cardTitle]'s metrics in
  /// [AppColors.danger].
  static const TextStyle destructiveLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.danger,
  );

  /// Caption over a card's title, and the label on a read-only emotion chip —
  /// DM Sans Regular 12/16.
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  /// Emotion name on a count chip — [caption]'s metrics in
  /// [AppColors.textPrimary].
  static const TextStyle countChipLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textPrimary,
  );

  /// Medium-weight label at 12/16 — a slot tab's label, the second line of a
  /// settings row.
  ///
  /// The widget recolours a selected tab with [AppColors.onInverse].
  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  /// Label on an emotion chip — [labelMedium]'s metrics, recoloured by the
  /// widget per group and selection state.
  static const TextStyle chipLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.emotionDifficultText,
  );

  /// Label over a form field or list — DM Sans Regular 12/16, 1.2 track.
  ///
  /// Set in upper case by the widget, not by the token: `TextStyle` carries no
  /// case transform, so the copy layer decides.
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 1.2,
    color: AppColors.textSecondaryMuted,
  );

  /// Section label over a card — DM Sans Medium 12/16, 1.2 track.
  ///
  /// Heavier and darker than [sectionLabel]; same upper-case caveat.
  static const TextStyle sectionLabelStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 1.2,
    color: AppColors.textPrimarySubtle,
  );

  /// Label over a group — emotion chips, a month of heatmap cells — DM Sans
  /// Regular 10/15, 1.0 track.
  ///
  /// Same upper-case caveat as [sectionLabel].
  static const TextStyle groupLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 15 / 10,
    letterSpacing: 1,
    color: AppColors.textSecondaryHalf,
  );

  /// Label inside a filled field tile — DM Sans Regular 10/15.
  ///
  /// Untracked, unlike [groupLabel], and set in sentence case.
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 15 / 10,
    color: AppColors.textSecondary,
  );

  /// Medium-weight label at 10/15 — a pill badge's text, a bottom navigation
  /// item's label.
  ///
  /// The widget recolours the selected navigation item with [AppColors.brand].
  static const TextStyle labelSmall = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 15 / 10,
    color: AppColors.textSecondary,
  );

  /// Word under a scale tile — DM Sans Regular 10/12.5.
  static const TextStyle scaleLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 12.5 / 10,
    color: AppColors.textSecondary,
  );

  /// Word under a scale tile on the entry screen — DM Sans Medium 9/11.25.
  ///
  /// The widget recolours it with [AppColors.onBrand] on the selected tile.
  static const TextStyle scaleLabelCompact = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 11.25 / 9,
    color: AppColors.textSecondary,
  );

  /// Weekday initial over a heatmap — DM Sans Regular 9/13.5.
  static const TextStyle weekdayLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    height: 13.5 / 9,
    color: AppColors.textSecondaryFaint,
  );

  /// Label over a statistic — DM Sans Regular 9/13.5, 0.225 track. Same
  /// upper-case caveat as [sectionLabel].
  static const TextStyle statLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    height: 13.5 / 9,
    letterSpacing: 0.225,
    color: AppColors.textSecondary,
  );

  /// Primary button label — DM Sans Medium 16/24.
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.onBrand,
  );

  /// Icon glyph on a slot row — DM Sans Regular 16/24.
  static const TextStyle slotIcon = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  /// Face inside a scale tile — DM Sans Regular 24/32.
  static const TextStyle scaleFace = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );

  /// Face inside a scale tile on the entry screen — DM Sans Medium 20/20.
  static const TextStyle scaleFaceCompact = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColors.textPrimary,
  );

  /// Lock glyph on a closed slot — DM Sans Regular 44/66.
  static const TextStyle lockedSlotIcon = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 66 / 44,
    color: AppColors.textPrimaryFaint,
  );
}

/// Styles set in [AppFonts.mono] — anything whose digits must not shift.
abstract final class AppMonoText {
  /// A statistic's value — DM Mono Medium 20/28.
  ///
  /// Monospaced so the four cards keep a common digit width, and an average
  /// with a decimal place does not shift against a whole number beside it.
  static const TextStyle statValue = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );

  /// Wall-clock time the user picked — DM Mono Regular 14/20, in
  /// [AppColors.brand] because it is editable.
  ///
  /// Monospaced so a schedule's digits stay column-aligned between rows.
  static const TextStyle timeValue = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.brand,
  );

  /// A time shown inside a filled tile — [timeValue]'s metrics in
  /// [AppColors.textPrimary], since the tile itself carries the affordance.
  static const TextStyle timeValuePlain = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  /// A slot's window, derived rather than picked — [timeValue]'s metrics in
  /// [AppColors.textSecondary], so it does not read as tappable.
  static const TextStyle timeRange = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  /// How many times an emotion was chosen — DM Mono Regular 12/16.
  static const TextStyle countValue = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  /// Date over a note in the summary — DM Mono Regular 10/15.
  static const TextStyle noteDate = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 15 / 10,
    color: AppColors.textSecondary,
  );

  /// Day number inside a heatmap cell — DM Mono Medium 10/10.
  ///
  /// The widget picks the colour from the cell's fill:
  /// [AppColors.onScaleLight], [AppColors.onScaleMid], [AppColors.onScaleDark],
  /// or [AppColors.textSecondaryDim] where the day holds no recording.
  static const TextStyle heatmapDay = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColors.textSecondaryDim,
  );

  /// Axis label on the trend chart — DM Mono Regular 9, default line height.
  static const TextStyle chartAxisLabel = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
