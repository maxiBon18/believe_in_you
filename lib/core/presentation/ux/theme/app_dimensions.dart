/// Spacing and size tokens taken from the BelieveInYou Figma file.
///
/// Values are logical pixels, measured on the 390x844 reference frame, and are
/// grouped by what they measure: [AppRadius] for corner radii, [AppStrokes] for
/// line widths, [AppSizes] for fixed extents, [AppSpacing] for space, whether
/// inside a container or between siblings.
///
/// Every value appears once. Where the design reuses a number across unrelated
/// places, the constant is named for the step rather than for one of its uses,
/// and its doc comment lists them all.
library;

/// Corner radii — four steps.
abstract final class AppRadius {
  /// Chart tooltip.
  static const double small = 10;

  /// Card, primary button, scale tile, heatmap cell.
  static const double medium = 16;

  /// Bullet card, statistic card, time tile, slot tab.
  static const double large = 20;

  /// Sheet's top edge.
  static const double extraLarge = 24;
}

/// Line widths.
abstract final class AppStrokes {
  /// Card or field border, and a divider inside a card.
  static const double border = 1;

  /// Trend line on the chart.
  static const double chartLine = 1.5;
}

/// Fixed extents — widths, heights, and diameters that do not derive from
/// their content.
abstract final class AppSizes {
  /// Width of the sunrise mark on the splash screen.
  static const double markWidth = 160;

  /// Height of the sunrise mark on the splash screen.
  static const double markHeight = 104;

  /// Height of the sunrise mark in a left-aligned screen header.
  static const double markSmallHeight = 28.59;

  /// Height of the sunrise mark in a screen header.
  static const double markCompactHeight = 31.19;

  /// Width of the sunrise mark in a header that also carries a heading.
  static const double markMediumWidth = 52;

  /// Height of the sunrise mark in a header that also carries a heading.
  static const double markMediumHeight = 33.8;

  /// Width of the sunrise mark in the home header.
  static const double markLargeWidth = 57.59;

  /// Height of the sunrise mark in the home header.
  static const double markLargeHeight = 37.44;

  /// Width of the mark-plus-wordmark block on the splash screen.
  static const double brandBlockWidth = 180;

  /// Height of the mark-plus-wordmark block on the splash screen.
  static const double brandBlockHeight = 164;

  /// Diameter of a dot — page indicator, bullet, plotted chart point.
  static const double dot = 6;

  /// Thickness of a sheet's drag handle.
  static const double grabberThickness = 4;

  /// Small icon — disclosure chevron, status glyph.
  static const double iconSmall = 14;

  /// Bottom navigation icon.
  static const double iconMedium = 19;

  /// Toggle knob.
  static const double toggleKnob = 16;

  /// Height of a toggle's track.
  static const double toggleHeight = 24;

  /// Width of the active page indicator dot, stretched into a pill.
  static const double pageIndicatorActiveWidth = 22;

  /// Height of the weekday initials row over a month grid.
  static const double heatmapWeekdayRow = 15.5;

  /// Side of a heatmap cell — square.
  static const double heatmapCell = 45.44;

  /// Height of a statistic card.
  static const double statCardHeight = 71.5;

  /// Height of a time picker field.
  static const double timePickerHeight = 66;

  /// Height of the note field when open.
  static const double noteFieldHeight = 85;

  /// Width of a control or mark measuring 44 — the toggle track, the sunrise
  /// mark in a left-aligned header.
  static const double control = 44;

  /// Side of a square measuring 48 — a scale tile, the sunrise mark in a
  /// screen header.
  static const double tile = 48;

  /// Length of a bar measuring 40 — the slot tab bar's height, a sheet drag
  /// handle's width.
  static const double bar = 40;

  /// Height of the primary button.
  static const double buttonHeight = 56;

  /// Extent of a panel measuring 120 — the trend chart's height, the height
  /// the note field grows to before it scrolls.
  static const double panel = 120;
}

/// Space, whether inside a container or between siblings.
///
/// One constant per step in the design. The doc comment on each lists where
/// the step is used, so a change here is a deliberate change to all of them.
abstract final class AppSpacing {
  /// Under a weekday initial; inside a read-only chip or pill badge; between a
  /// heading and its count line, a note's date and its text, a row's title and
  /// its subtitle, a navigation icon and its label.
  static const double s2 = 2;

  /// Above a heading inside a header block; above a statistic's value; around
  /// a toggle's knob; under the mark before a compact wordmark; between
  /// read-only chips, heatmap cells, a tab's icon and label, a row's title and
  /// its hint.
  static const double s4 = 4;

  /// Inside an emotion chip, top and bottom; between a section label and its
  /// field, a recording's face and its scale word, two slot tabs, two scale
  /// tiles, a scale tile's face and word, a card's caption and title, two
  /// emotion chips, an emotion's name and its count.
  static const double s6 = 6;

  /// Under a wordmark, body copy, or small-step heading; above a recording's
  /// chips; under the tab bar; inside a pill badge, left and right; between a
  /// section label and its card, two statistic cards, two page indicator dots,
  /// a scale tile and its word, two bullet cards, a disclosure label and its
  /// badge, a status icon and its label.
  static const double s8 = 8;

  /// Inside a read-only chip, left and right; inside a scale tile, top and
  /// bottom; under a note in the summary.
  static const double s10 = 10;

  /// Inside a chart tooltip, every side.
  static const double s11 = 11;

  /// Under a header that carries controls; above a heading in a content
  /// column; under a heading; under the note field's last line; under the
  /// status row; above and inside the time tiles; inside a navigation item;
  /// inside an emotion chip, left and right; under a wordmark that precedes a
  /// heading; between a slot row's parts, two cards, a bullet dot and its
  /// label, two emotion groups, the parts of a closed slot's page.
  static const double s12 = 12;

  /// Inside a compactly padded card, every side; inside a disclosure row, top
  /// and bottom; above the note field's first line.
  static const double s13 = 13;

  /// Inside a slot row, top and bottom; above a recording row; inside a time
  /// tile, left and right.
  static const double s14 = 14;

  /// Under a recording row; inside a bullet card, top and bottom.
  static const double s15 = 15;

  /// Under a header that carries a heading and body copy; above the first
  /// control under the tabs; above a left-aligned heading; between a sheet's
  /// title and its rows; inside the note field, left and right; above a
  /// settings row; around the destructive action; beside the trend chart;
  /// between two stacked blocks, two labelled form fields.
  static const double s16 = 16;

  /// Inside a card row, top and bottom; inside a bullet card or disclosure
  /// row, left and right; under a settings row.
  static const double s17 = 17;

  /// Above a note in the summary; between the mark and the wordmark on the
  /// splash screen.
  static const double s18 = 18;

  /// Beside a dense screen's content; above a labelled section; inside a slot
  /// row, left and right; between a sheet's handle and its title; above the
  /// status row.
  static const double s20 = 20;

  /// Inside a card, every side of a uniformly padded one.
  static const double s21 = 21;

  /// Beside a grid-led screen's content; under a header that ends with a
  /// heading; above and below a centred content block; under a month's grid;
  /// above a sheet's drag handle; above a pinned primary button.
  static const double s24 = 24;

  /// Indent lining a recording's emotion chips up with its slot name.
  static const double s28 = 28;

  /// Beside a screen's content and footer columns; under the page indicator;
  /// under the notes list.
  static const double s32 = 32;

  /// Beside a closed slot's placeholder page; above a screen header's mark;
  /// under a sheet's last row.
  static const double s40 = 40;

  /// Under the primary button in a screen footer.
  static const double s48 = 48;

  /// Under the last control, clearing the bottom navigation bar.
  static const double s96 = 96;
}
