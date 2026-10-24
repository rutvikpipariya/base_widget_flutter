<p align="center">
  <img src="https://raw.githubusercontent.com/rutvikpipariya/base_widget_flutter/main/screenshots/banner.png" alt="base_widget_flutter: one base widget for every Flutter screen" width="100%">
</p>

<p align="center">
  <a href="https://pub.dev/packages/base_widget_flutter"><img src="https://img.shields.io/pub/v/base_widget_flutter.svg?label=pub.dev&color=0175C2" alt="pub version"></a>
  <a href="https://pub.dev/packages/base_widget_flutter/score"><img src="https://img.shields.io/pub/likes/base_widget_flutter?color=ff4f8b" alt="pub likes"></a>
  <a href="https://pub.dev/packages/base_widget_flutter/score"><img src="https://img.shields.io/pub/points/base_widget_flutter?color=2ea44f" alt="pub points"></a>
  <a href="https://pub.dev/packages/base_widget_flutter"><img src="https://img.shields.io/pub/dm/base_widget_flutter?color=8a2be2" alt="downloads"></a>
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-02569B?logo=flutter" alt="platforms">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT license"></a>
</p>

<h3 align="center">Stop rebuilding the same screen boilerplate.<br>Loading overlays, empty and error states, pull-to-refresh, text styles and API helpers, in one package.</h3>

<p align="center">
  <a href="#-installation">Installation</a> ·
  <a href="#-usage">Usage</a> ·
  <a href="#-basestateview">BaseStateView</a> ·
  <a href="#-faq">FAQ</a>
</p>

## 🎬 See it in action

<table>
  <tr>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/base_widget_flutter/main/screenshots/demo/states.gif" width="230" alt="BaseStateView"><br><sub><b>BaseStateView</b><br>loading → empty → error → content</sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/base_widget_flutter/main/screenshots/demo/overlay.gif" width="230" alt="Loading overlay"><br><sub><b>Blurred loading overlay</b><br><code>isLoading</code> + <code>loadingBlur</code></sub></td>
    <td align="center"><img src="https://raw.githubusercontent.com/rutvikpipariya/base_widget_flutter/main/screenshots/states.png" width="230" alt="Orders list"><br><sub><b>Pull-to-refresh</b><br><code>onRefresh</code></sub></td>
  </tr>
</table>

## 🆕 What's new in 2.1

* **`BaseStateView`**: loading, empty, error and content states with a cross-fade and a retry button. [See below](#-basestateview).
* **Prettier loading overlay**: `loadingMessage`, `loadingBlur` and `loadingBarrierColor`, and it now fades in and out.
* **Pull-to-refresh**: `BaseWidget(onRefresh: _reload, ...)`.

## 🤔 Why?

Every screen in a real app repeats the same plumbing. Before:

```dart
PopScope(
  canPop: !_saving,
  child: Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(child: ProfileForm(onSubmit: _save)),
          if (_saving) ...[
            const ModalBarrier(dismissible: false, color: Colors.black54),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    ),
  ),
)
```

After:

```dart
BaseWidget(
  bodyAppBar: AppBar(title: const Text('Profile')),
  isLoading: _saving,
  loadingMessage: 'Saving…',
  canPop: !_saving,
  dismissKeyboardOnTap: true,
  safeArea: true,
  body: ProfileForm(onSubmit: _save),
)
```

## ✨ Features

* **Loading overlay** — `isLoading: true` blocks the screen with a barrier and
  a spinner, with an optional message and frosted blur. No more hand-rolled
  `Stack` on every page.
* **Loading / empty / error states** — `BaseStateView` switches between them
  with a cross-fade and a retry button.
* **Pull-to-refresh** — `onRefresh` on any scrollable body.
* **Keyboard dismissal** — `dismissKeyboardOnTap: true` unfocuses on an
  outside tap, instead of the `GestureDetector` + `FocusScope` dance.
* **Back-navigation control** — `canPop: false` blocks the system back gesture
  while a form is dirty.
* **Safe area** — one flag, no extra nesting.
* **Nothing taken away** — the `Scaffold` slots you already use
  (`floatingActionButton`, `drawer`, `bottomNavigationBar`, …) are forwarded.
* **Theme-friendly** — no hardcoded colours, so dark mode just works.

## 📦 Installation

```bash
flutter pub add base_widget_flutter
```

or add it to `pubspec.yaml` yourself:

```yaml
dependencies:
  base_widget_flutter: ^2.1.0
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

Make the overlay friendlier with a message and a frosted blur:

```dart
BaseWidget(
  isLoading: _isSaving,
  loadingMessage: 'Saving profile…',
  loadingBlur: 6,
  body: ProfileForm(onSubmit: _save),
)
```

Add pull-to-refresh to a scrollable body:

```dart
BaseWidget(
  onRefresh: _reload,
  body: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [...],
  ),
)
```

## 🧭 BaseStateView

Every data screen has four states. Drive them with one value instead of
rebuilding the spinner, the placeholder and the retry button each time:

```dart
BaseStateView(
  state: switch (_orders) {
    null => BaseViewState.loading,
    [] => BaseViewState.empty,
    _ => BaseViewState.content,
  },
  emptyTitle: 'No orders yet',
  emptyMessage: 'When you place an order, it will show up here.',
  errorMessage: _error,
  onRetry: _load,
  child: OrderList(orders: _orders ?? const []),
)
```

States cross-fade, colours follow your `Theme` (dark mode included), and the
retry button only appears when `onRetry` is set. Replace any state completely
with `loadingBuilder`, `emptyBuilder` or `errorBuilder`, for example to show
your own illustration.

| Parameter | Default |
| --- | --- |
| `state` | required: `loading`, `empty`, `error` or `content` |
| `child` | required, shown for `content` |
| `emptyIcon` / `emptyTitle` / `emptyMessage` | inbox icon, `'Nothing here yet'`, none |
| `errorIcon` / `errorTitle` / `errorMessage` | cloud-off icon, `'Something went wrong'`, none |
| `onRetry` / `retryLabel` | none, `'Try again'` |
| `loadingBuilder` / `emptyBuilder` / `errorBuilder` | built-in states |
| `duration` | 250 ms cross-fade |

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
| `loadingMessage`           | `String?`              | `null`  | Text shown under the indicator.                              |
| `loadingBlur`              | `double`               | `0`     | Blurs the body behind the overlay (Gaussian sigma).          |
| `loadingBarrierColor`      | `Color?`               | `null`  | Overlay colour; defaults to `black54` (`black26` with blur). |
| `onRefresh`                | `RefreshCallback?`     | `null`  | Enables pull-to-refresh on a scrollable body.                |
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

## ❓ FAQ

<details>
<summary><b>Which platforms are supported?</b></summary>

Android, iOS, web, Windows, macOS and Linux. The services follow their
underlying plugins: notifications and location need the platform setup
described in the `flutter_local_notifications` and `geolocator` READMEs.
</details>

<details>
<summary><b>Do I have to use every part of the package?</b></summary>

No. Each piece stands alone: use `BaseWidget` and ignore the services, or use
`BaseApiClient` without `BaseWidget`.
</details>

<details>
<summary><b>Does it work with my state management (Provider, Riverpod, Bloc, GetX…)?</b></summary>

Yes. Everything is driven by plain values like `isLoading` and `state`, so set
them from whatever state solution you already use.
</details>

<details>
<summary><b>Does it support dark mode?</b></summary>

Yes. Nothing is hardcoded to light colours; everything reads your `Theme`.
</details>

## ⭐ Support the project

If base_widget_flutter saves you time, please **give it a 👍 on
[pub.dev](https://pub.dev/packages/base_widget_flutter)** and a **⭐ on
[GitHub](https://github.com/rutvikpipariya/base_widget_flutter)**. It helps
other developers find it.

## 🤝 Contributing

Issues and pull requests are welcome. See [CONTRIBUTING](CONTRIBUTING.md).

## 📄 License

[MIT](LICENSE)
