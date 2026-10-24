/// [BaseTextStyles]: one font configuration, nine weight-named text styles.
library;

import 'package:flutter/painting.dart';

/// Weight-named [TextStyle]s built from a single font configuration.
///
/// You supply the font once; this supplies the nine weights. Configure it
/// before `runApp` and read the styles anywhere:
///
/// ```dart
/// void main() {
///   BaseTextStyles.instance = BaseTextStyles(
///     fontFamily: 'Poppins',
///     color: '151D31'.toColor(),
///   );
///   runApp(const MyApp());
/// }
///
/// Text('Hello', style: BaseTextStyles.instance.semiBold)
/// ```
///
/// Every getter returns a plain [TextStyle], so vary one with `copyWith`
/// instead of reaching for a bespoke helper:
///
/// ```dart
/// BaseTextStyles.instance.bold.copyWith(fontSize: 24, color: Colors.red)
/// ```
///
/// [instance] is a single global configuration, which is all most apps need.
/// If you want two fonts — a display face and a body face, say — build a
/// second [BaseTextStyles] and hold it yourself rather than reassigning
/// [instance].
class BaseTextStyles {
  /// Creates a font configuration.
  ///
  /// A null [fontFamily] falls back to the platform's default font, and a
  /// null [color] lets the surrounding [DefaultTextStyle] or theme decide.
  const BaseTextStyles({
    this.fontFamily,
    this.fontSize = 16,
    this.color,
    this.height,
    this.letterSpacing,
    this.decoration = TextDecoration.none,
  });

  /// The globally configured styles, read by `BaseTextStyles.instance`.
  ///
  /// Assign once during app start-up. Defaults to an unconfigured
  /// [BaseTextStyles], so the getters work before you set anything.
  static BaseTextStyles instance = const BaseTextStyles();

  /// Font family applied to every style, e.g. `'Poppins'`.
  final String? fontFamily;

  /// Size in logical pixels applied to every style.
  final double fontSize;

  /// Colour applied to every style.
  final Color? color;

  /// Line height as a multiple of [fontSize].
  final double? height;

  /// Space between letters in logical pixels.
  final double? letterSpacing;

  /// Decoration applied to every style. Defaults to [TextDecoration.none].
  final TextDecoration decoration;

  /// [FontWeight.w100].
  TextStyle get thin => _weight(FontWeight.w100);

  /// [FontWeight.w200].
  TextStyle get extraLight => _weight(FontWeight.w200);

  /// [FontWeight.w300].
  TextStyle get light => _weight(FontWeight.w300);

  /// [FontWeight.w400], the normal weight.
  TextStyle get regular => _weight(FontWeight.w400);

  /// [FontWeight.w500].
  TextStyle get medium => _weight(FontWeight.w500);

  /// [FontWeight.w600].
  TextStyle get semiBold => _weight(FontWeight.w600);

  /// [FontWeight.w700].
  TextStyle get bold => _weight(FontWeight.w700);

  /// [FontWeight.w800].
  TextStyle get extraBold => _weight(FontWeight.w800);

  /// [FontWeight.w900], the heaviest weight.
  TextStyle get black => _weight(FontWeight.w900);

  TextStyle _weight(FontWeight fontWeight) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}
