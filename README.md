# base_widget_flutter

A lightweight Flutter package that provides a reusable `BaseWidget` to simplify UI development and enforce a consistent screen structure across your app.

## ✨ Features

* Simple wrapper around `Scaffold`
* Reduces boilerplate code
* Optional AppBar support
* Clean and reusable architecture
* Easy integration into any Flutter project

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  base_widget_flutter: ^1.0.3
```

Then run:

```bash
flutter pub get
```

## 🚀 Usage

```dart
import 'package:base_widget_flutter/base_widget_flutter.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      bodyAppBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}
```

## 🧩 BaseWidget

`BaseWidget` is a wrapper around `Scaffold` with minimal configuration:

### Parameters

| Parameter  | Type                 | Description                         |
| ---------- | -------------------- | ----------------------------------- |
| body       | Widget               | Required main content of the screen |
| bodyAppBar | PreferredSizeWidget? | Optional AppBar                     |
| canPop     | bool                 | Reserved for future navigation use  |

## 📁 Project Structure

```
lib/
 ├── base/
 │   └── base_widget.dart
 └── base_widget_flutter.dart
```

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 📄 License

This project is open source and available under the MIT License.
