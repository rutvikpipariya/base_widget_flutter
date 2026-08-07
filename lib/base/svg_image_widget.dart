import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An [SvgPicture] asset that tints with a plain [Color].
///
/// `flutter_svg` takes a [ColorFilter], which means writing
/// `ColorFilter.mode(color, BlendMode.srcIn)` at every call site. This takes
/// the colour directly:
///
/// ```dart
/// SvgImageWidget(
///   asset: 'assets/icons/search.svg',
///   height: 24,
///   color: AppColors.primary,
///   semanticsLabel: 'Search',
/// )
/// ```
///
/// Leave [color] null to render the SVG's own colours.
class SvgImageWidget extends StatelessWidget {
  /// Creates an SVG image from an asset bundled with the app.
  const SvgImageWidget({
    super.key,
    required this.asset,
    this.height,
    this.width,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  });

  /// Asset key of the SVG, e.g. `'assets/icons/search.svg'`.
  final String asset;

  /// Height in logical pixels. Null lets the SVG size itself.
  final double? height;

  /// Width in logical pixels. Null lets the SVG size itself.
  final double? width;

  /// Tint applied to the whole drawing with [BlendMode.srcIn].
  ///
  /// Null renders the SVG's own colours, which is what you want for
  /// multi-colour illustrations.
  final Color? color;

  /// How the drawing is inscribed into its box.
  final BoxFit fit;

  /// How the drawing is aligned within its box.
  final AlignmentGeometry alignment;

  /// Description announced by screen readers.
  ///
  /// Set this whenever the image carries meaning. Leave it null for purely
  /// decorative images so assistive technology skips them.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    height: height,
    width: width,
    fit: fit,
    alignment: alignment,
    semanticsLabel: semanticsLabel,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}
