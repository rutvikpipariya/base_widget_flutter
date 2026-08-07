/// A reusable [BaseWidget] that wraps `Scaffold` so every screen in an app
/// shares one consistent structure, plus the small pieces every app rebuilds
/// around it: [BaseTextStyles], [SvgImageWidget] and the [HexColor] extension.
library;

export 'base/base_text_styles.dart';
export 'base/base_widget.dart';
export 'base/hex_color.dart';
export 'base/svg_image_widget.dart';
export 'service/base_api_client.dart';
export 'service/base_location_service.dart';
export 'service/base_notification_service.dart';
export 'service/base_prefs.dart';
