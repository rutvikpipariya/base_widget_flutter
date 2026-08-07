# base_widget_flutter

[![pub package](https://img.shields.io/pub/v/base_widget_flutter.svg)](https://pub.dev/packages/base_widget_flutter)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A `Scaffold` wrapper that gives every screen in your app the same structure —
and absorbs the boilerplate you would otherwise copy into each one.

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

## 🧩 Parameters

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
