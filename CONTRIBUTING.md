# Contributing

Thanks for helping improve base_widget_flutter! Bug reports, feature requests and pull requests are all welcome.

## Setup

```sh
git clone https://github.com/rutvikpipariya/base_widget_flutter.git
cd base_widget_flutter
flutter pub get
cd example && flutter run
```

## Layout

| Path | Contents |
| --- | --- |
| `lib/base/` | Widgets and helpers: `BaseWidget`, `BaseStateView`, `BaseTextStyles`, `HexColor`, `SvgImageWidget` |
| `lib/service/` | `BaseApiClient`, `BasePrefs`, `BaseLocationService`, `BaseNotificationService` |
| `example/` | Three-tab showcase app |

## Before opening a pull request

```sh
dart format lib example/lib
flutter analyze
```

Keep widgets theme-driven (no hardcoded colours) and document every public API.
