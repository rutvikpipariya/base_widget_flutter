import 'package:flutter/material.dart';

/// A [Scaffold] wrapper that gives every screen in an app the same structure.
///
/// It absorbs the boilerplate most screens repeat — a blocking loading
/// overlay, safe-area insets, dismissing the keyboard on an outside tap and
/// controlling back navigation — without taking away the [Scaffold] slots you
/// already use.
///
/// ```dart
/// BaseWidget(
///   bodyAppBar: AppBar(title: const Text('Home')),
///   isLoading: _saving,
///   body: const Center(child: Text('Hello World')),
/// )
/// ```
class BaseWidget extends StatelessWidget {
  /// Creates a screen scaffold around [body].
  const BaseWidget({
    super.key,
    required this.body,
    this.bodyAppBar,
    this.canPop = true,
    this.isLoading = false,
    this.loadingIndicator,
    this.dismissKeyboardOnTap = false,
    this.safeArea = false,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
  });

  /// The main content of the screen.
  final Widget body;

  /// Optional app bar rendered above [body].
  final PreferredSizeWidget? bodyAppBar;

  /// Whether the user may pop this route.
  ///
  /// Set to `false` to block the system back gesture and button, for example
  /// while a form has unsaved changes. Defaults to `true`.
  final bool canPop;

  /// Whether to cover [body] with a barrier and a progress indicator.
  ///
  /// While `true` the content stays mounted but cannot be interacted with.
  final bool isLoading;

  /// Widget shown while [isLoading] is `true`.
  ///
  /// Defaults to a centered [CircularProgressIndicator].
  final Widget? loadingIndicator;

  /// Whether tapping outside a focused field unfocuses it and hides the
  /// keyboard.
  final bool dismissKeyboardOnTap;

  /// Whether to wrap [body] in a [SafeArea].
  final bool safeArea;

  /// Background colour of the underlying [Scaffold].
  ///
  /// Defaults to the theme's `scaffoldBackgroundColor` when null.
  final Color? backgroundColor;

  /// Forwarded to [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// Forwarded to [Scaffold.bottomNavigationBar].
  final Widget? bottomNavigationBar;

  /// Forwarded to [Scaffold.drawer].
  final Widget? drawer;

  /// Forwarded to [Scaffold.endDrawer].
  final Widget? endDrawer;

  /// Forwarded to [Scaffold.resizeToAvoidBottomInset].
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (safeArea) {
      content = SafeArea(child: content);
    }

    if (isLoading) {
      content = Stack(
        children: [
          content,
          const Positioned.fill(
            child: ModalBarrier(dismissible: false, color: Colors.black54),
          ),
          Center(child: loadingIndicator ?? const CircularProgressIndicator()),
        ],
      );
    }

    if (dismissKeyboardOnTap) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: content,
      );
    }

    return PopScope(
      canPop: canPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: bodyAppBar,
        body: content,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        endDrawer: endDrawer,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
