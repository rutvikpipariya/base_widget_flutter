# base_widget_flutter

[![pub package](https://img.shields.io/pub/v/base_widget_flutter.svg)](https://pub.dev/packages/base_widget_flutter)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A `Scaffold` wrapper that gives every screen in your app the same structure —
plus the three small pieces every app rebuilds around it: weight-named text
styles, hex colour parsing, and a tintable SVG widget.

## ✨ Features

* **Loading overlay** — `isLoading: true` blocks the screen with a barrier and
  a spinner. No more hand-rolled `Stack` on every page.
* **Keyboard dismissal** — `dismissKeyboardOnTap: true` unfocuses on an
  outside tap, instead of the `GestureDetector` + `FocusScope` dance.
* **Back-navigation control** — `canPop: false` blocks the system back gesture
  while a form is dirty.
* **Safe area** — one flag, no extra nesting.
* **Nothing taken away** — the `Scaffold` slots you already use
  (`floatingActionButton`, `drawer`, `bottomNavigationBar`, …) are forwarded.
* **Theme-friendly** — no hardcoded colours, so dark mode just works.

## 📦 Installation

```yaml
dependencies:
  base_widget_flutter: ^2.0.0
```

```bash
flutter pub get
```

## 🚀 Usage

```dart
import 'package:base_widget_flutter/base_widget_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      bodyAppBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Hello World')),
    );
  }
}
```

Block the screen while an async call runs, and stop the user backing out of it:

```dart
BaseWidget(
  bodyAppBar: AppBar(title: const Text('Profile')),
  isLoading: _isSaving,
  canPop: !_isSaving,
  dismissKeyboardOnTap: true,
  safeArea: true,
  body: ProfileForm(onSubmit: _save),
)
```

A full runnable app lives in [`example/`](example/lib/main.dart).

## 🔤 BaseTextStyles

You configure the font once. The package gives you all nine weights.

```dart
void main() {
  BaseTextStyles.instance = BaseTextStyles(
    fontFamily: 'Poppins',      // whatever you declared in pubspec.yaml
    fontSize: 14,
    color: '151D31'.toColor(),
  );
  runApp(const MyApp());
}
```

Then anywhere in the app:

```dart
Text('Heading',  style: BaseTextStyles.instance.semiBold)
Text('Body',     style: BaseTextStyles.instance.regular)
Text('Caption',  style: BaseTextStyles.instance.light)
```

| Getter       | `FontWeight` | | Getter       | `FontWeight` |
| ------------ | ------------ |-| ------------ | ------------ |
| `thin`       | `w100`       | | `medium`     | `w500`       |
| `extraLight` | `w200`       | | `semiBold`   | `w600`       |
| `light`      | `w300`       | | `bold`       | `w700`       |
| `regular`    | `w400`       | | `extraBold`  | `w800`       |
|              |              | | `black`      | `w900`       |

Every getter returns a plain `TextStyle`, so vary one with `copyWith` — there
is no bespoke `custom()` helper to learn:

```dart
BaseTextStyles.instance.bold.copyWith(fontSize: 24, color: Colors.red)
```

Need two typefaces? Build a second instance and hold it yourself instead of
reassigning `instance`:

```dart
final displayStyles = BaseTextStyles(fontFamily: 'PlayfairDisplay');
Text('Title', style: displayStyles.bold);
```

**Remember to declare the font in your own `pubspec.yaml`** — this package
supplies the styles, not the font files:

```yaml
flutter:
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

## 🎨 Hex colours

An extension on `String`, so hex codes read as hex codes:

```dart
class AppColors {
  static final Color primary = '#1364FF'.toColor();
  static final Color surface = 'F8FAFF'.toColor();
  static final Color overlay = '801364FF'.toColor(); // 50% opaque
  static final Color danger  = 'F00'.toColor();      // shorthand
}
```

Accepts an optional `#` and 3, 4, 6 or 8 digits. **Alpha comes first**
(`AARRGGBB`, matching Flutter's own `Color(0x...)`), *not* the CSS
`RRGGBBAA` order.

For values from an API, config file or user input, use `tryToColor()` — it
returns `null` instead of throwing:

```dart
final accent = (json['accent'] as String?)?.tryToColor() ?? AppColors.primary;
```

## 🖼 SvgImageWidget

`flutter_svg` wants a `ColorFilter`; this takes a `Color`:

```dart
SvgImageWidget(
  asset: 'assets/icons/search.svg',
  height: 24,
  color: AppColors.primary,
  semanticsLabel: 'Search',
)
```

Leave `color` null to keep the SVG's own colours — which is what you want for
multi-colour illustrations. Leave `semanticsLabel` null only for purely
decorative images, so screen readers skip them.

| Parameter        | Type                | Default             |
| ---------------- | ------------------- | ------------------- |
| `asset`          | `String`            | —                   |
| `height`         | `double?`           | `null`              |
| `width`          | `double?`           | `null`              |
| `color`          | `Color?`            | `null`              |
| `fit`            | `BoxFit`            | `BoxFit.contain`    |
| `alignment`      | `AlignmentGeometry` | `Alignment.center`  |
| `semanticsLabel` | `String?`           | `null`              |

## 🧩 BaseWidget parameters

| Parameter                  | Type                   | Default | Description                                                  |
| -------------------------- | ---------------------- | ------- | ------------------------------------------------------------ |
| `body`                     | `Widget`               | —       | Required main content of the screen.                         |
| `bodyAppBar`               | `PreferredSizeWidget?` | `null`  | Optional app bar.                                            |
| `canPop`                   | `bool`                 | `true`  | Set `false` to block the system back gesture and button.     |
| `isLoading`                | `bool`                 | `false` | Covers the body with a barrier and a progress indicator.     |
| `loadingIndicator`         | `Widget?`              | `null`  | Replaces the default `CircularProgressIndicator`.            |
| `dismissKeyboardOnTap`     | `bool`                 | `false` | Unfocuses the current field on an outside tap.               |
| `safeArea`                 | `bool`                 | `false` | Wraps the body in a `SafeArea`.                              |
| `backgroundColor`          | `Color?`               | `null`  | Falls back to `ThemeData.scaffoldBackgroundColor`.           |
| `floatingActionButton`     | `Widget?`              | `null`  | Forwarded to `Scaffold`.                                     |
| `bottomNavigationBar`      | `Widget?`              | `null`  | Forwarded to `Scaffold`.                                     |
| `drawer`                   | `Widget?`              | `null`  | Forwarded to `Scaffold`.                                     |
| `endDrawer`                | `Widget?`              | `null`  | Forwarded to `Scaffold`.                                     |
| `resizeToAvoidBottomInset` | `bool?`                | `null`  | Forwarded to `Scaffold`.                                     |

## 🌐 BaseApiClient

A configured `Dio` with bearer auth, a loading signal and logging:

```dart
final api = BaseApiClient(
  baseUrl: 'https://api.example.com',
  tokenProvider: () => BasePrefs.getString('access_token'),
  onLoadingChanged: (busy) => busy ? showLoader() : hideLoader(),
  logger: kDebugMode ? debugPrint : null,
);

final res = await api.get('/v1/profile');
final profile = Profile.fromJson(res.data as Map<String, dynamic>);
```

`get` `post` `put` `patch` `delete` `postFormData`, each returning Dio's own
`Response` so your existing model layer parses it unchanged. Per-request
flags: `authenticated: false` to skip the token, `showLoader: false` for
silent background calls.

`onLoadingChanged` is **reference-counted** — it fires `true` when the first
request starts and `false` only when the last one finishes, so two overlapping
calls don't hide the loader early. Anything not wrapped here (cancel tokens,
`download`, extra interceptors) is on `api.dio`.

Statuses below 500 resolve rather than throw, so 4xx bodies reach your error
handling instead of arriving as a `DioException`. Override with
`validateStatus`.

> Pass `logger` only in debug builds. Response bodies routinely contain
> personal data, and on Android `print` output is readable by other apps
> through logcat.

## 📍 BaseLocationService

```dart
final result = await BaseLocationService.getCurrentPosition();
switch (result.failure) {
  case null:
    print(result.position!.latitude);
  case LocationFailure.serviceDisabled:
    await BaseLocationService.openLocationSettings();
  case LocationFailure.denied:
    showSnackBar('Location is needed to find nearby clinics.');
  case LocationFailure.deniedForever:
    await BaseLocationService.openAppSettings();
}
```

It returns *why* a read failed rather than a bare null, because the three
failures need three different responses — a retry, a nudge, or a trip to
settings. `getLastKnownPosition()` returns the platform's cached fix
immediately, which makes a good placeholder.

Declare the permissions yourself: `NSLocationWhenInUseUsageDescription` in
`Info.plist`, `ACCESS_FINE_LOCATION` in `AndroidManifest.xml`. See the
[`geolocator`](https://pub.dev/packages/geolocator) README for full setup.

## 🔔 BaseNotificationService

```dart
await BaseNotificationService.init(
  androidIcon: '@mipmap/ic_launcher',
  channelId: 'reminders',
  channelName: 'Appointment reminders',
  onTap: (response) => router.go(response.payload!),
);

await BaseNotificationService.show(
  title: 'Appointment tomorrow',
  body: '10:30 with Dr. Patel',
  payload: '/appointments/42',
);
```

Pass `requestPermissions: false` to `init` and call
`BaseNotificationService.requestPermissions()` later — a cold permission
prompt on first launch is usually declined. Scheduling and tap handling live
on `BaseNotificationService.plugin`.

`channelId` is sticky on Android: changing it after release creates a second
channel and leaves the old one in system settings. Pick one and keep it.

## 💾 BasePrefs

Synchronous preferences after one `await` at start-up:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BasePrefs.init();
  runApp(const MyApp());
}

final seen = BasePrefs.getBool('seen_onboarding');
await BasePrefs.setBool('seen_onboarding', true);
```

Getters take a `defaultValue` so they never return null. Anything else is on
`BasePrefs.instance`. Using it before `init()` throws a `StateError` naming
the fix, rather than silently returning defaults and dropping writes.

> **Don't store auth tokens, passwords or personal data here.**
> `SharedPreferences` is plain text on disk — `NSUserDefaults` on iOS, a
> world-readable XML file on Android — and is trivially recoverable from a
> rooted device or an unencrypted backup. Use
> [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage),
> which is backed by the iOS Keychain and Android Keystore.

## ⬆️ Migrating from 1.x

Two behaviours changed, both because they were bugs:

* The background was hardcoded to `Colors.white`, which broke dark mode. If
  you relied on it, pass `backgroundColor: Colors.white`.
* `canPop` was declared but never used, so back navigation always worked. It
  is now wired to a `PopScope` and defaults to `true` — the behaviour you had.
  Pass `canPop: false` where you want it blocked.

## 🤝 Contributing

Issues and pull requests are welcome.

## 📄 License

[MIT](LICENSE)
