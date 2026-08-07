import 'package:flutter/painting.dart';

final RegExp _hexDigits = RegExp(r'^[0-9a-fA-F]+$');

/// Parses hex colour strings into [Color] values.
extension HexColor on String {
  /// Parses this string as a hex colour.
  ///
  /// Accepts an optional leading `#` and 3, 4, 6 or 8 hex digits — `RGB`,
  /// `ARGB`, `RRGGBB` or `AARRGGBB`. Alpha comes **first**, matching [Color]'s
  /// own `0xAARRGGBB` layout rather than the CSS `RRGGBBAA` order, and
  /// defaults to fully opaque when omitted.
  ///
  /// ```dart
  /// '#1364FF'.toColor();   // opaque blue
  /// 'F00'.toColor();       // opaque red
  /// '801364FF'.toColor();  // 50% opaque blue
  /// ```
  ///
  /// Throws a [FormatException] if this is not a valid hex colour. Use
  /// [tryToColor] to get `null` instead.
  Color toColor() {
    final color = tryToColor();
    if (color == null) {
      throw FormatException('Not a valid hex colour', this);
    }
    return color;
  }

  /// Like [toColor], but returns `null` instead of throwing.
  ///
  /// Prefer this for hex strings that come from an API, a config file or user
  /// input, where a malformed value should not crash the app.
  ///
  /// ```dart
  /// final accent = json['accent'] as String? ?? '';
  /// final color = accent.tryToColor() ?? Colors.blue;
  /// ```
  Color? tryToColor() {
    var hex = trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (!_hexDigits.hasMatch(hex)) {
      return null;
    }
    if (hex.length == 3 || hex.length == 4) {
      hex = hex.split('').map((digit) => '$digit$digit').join();
    }
    if (hex.length == 6) {
      hex = 'ff$hex';
    }
    if (hex.length != 8) {
      return null;
    }
    return Color(int.parse(hex, radix: 16));
  }
}
