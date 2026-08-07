# Changelog

## 2.0.0

**Breaking changes**

* `BaseWidget` no longer forces a white background. `backgroundColor` is now a
  parameter and defaults to `null`, so the screen follows
  `ThemeData.scaffoldBackgroundColor` and dark mode works. Pass
  `backgroundColor: Colors.white` to keep the old look.
* `canPop` is now actually wired to a `PopScope` instead of being ignored, and
  its default changed from `false` to `true` (which matches the behaviour you
  were really getting). Pass `canPop: false` to block back navigation.

**New**

* `isLoading` covers the body with a barrier and a progress indicator, with
  `loadingIndicator` to replace the default spinner.
* `dismissKeyboardOnTap` unfocuses the current field on an outside tap.
* `safeArea` wraps the body in a `SafeArea`.
* Forwards `floatingActionButton`, `bottomNavigationBar`, `drawer`,
  `endDrawer` and `resizeToAvoidBottomInset` to the underlying `Scaffold`.

**Fixes and housekeeping**

* Removed the invalid `flutter: platforms:` block from `pubspec.yaml`, which
  Flutter 3.44 rejects for a non-plugin package.
* Lowered the Dart SDK constraint from `^3.11.4` to `^3.7.0`.
* Added an example app, a widget test suite and dartdoc comments on the whole
  public API.

## 1.0.4

* Stable release of base_widget_flutter package
* Added reusable base widgets for faster UI development
* Improved code structure and maintainability
* Updated dependencies and SDK constraints
* Minor bug fixes and performance improvements

## 1.0.3

* Rewrote the package description.
* Fixed the malformed `homepage` URL.

## 1.0.2

* Maintenance release.

## 1.0.1

* Maintenance release.

## 0.0.1

* Initial release.
