/// [BaseWidget]: a `Scaffold` wrapper with a loading overlay, pull-to-refresh
/// and back-navigation control.
library;

import 'dart:ui' show ImageFilter;

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
    this.loadingMessage,
    this.loadingBlur = 0,
    this.loadingBarrierColor,
    this.onRefresh,
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

  /// Optional text shown under the loading indicator, e.g. `'Saving…'`.
  final String? loadingMessage;

  /// Blur applied to [body] behind the loading overlay, as a Gaussian sigma.
  ///
  /// `0` (the default) disables the blur. Values around `4`–`8` give a soft,
  /// frosted look.
  final double loadingBlur;

  /// Colour of the barrier behind the loading indicator.
  ///
  /// Defaults to [Colors.black54], or [Colors.black26] when [loadingBlur] is
  /// set so the blur stays visible.
  final Color? loadingBarrierColor;

  /// Enables pull-to-refresh on [body].
  ///
  /// The returned future keeps the refresh indicator visible until it
  /// completes. [body] must be scrollable (a `ListView`, `CustomScrollView`…);
  /// use `AlwaysScrollableScrollPhysics` so short lists can still be pulled.
  final RefreshCallback? onRefresh;

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

    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    content = Stack(
      children: [
        content,
        Positioned.fill(
          // Fades the overlay in and out instead of popping it.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? KeyedSubtree(
                    key: const ValueKey('loading'),
                    child: _buildOverlay(context),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );

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

  Widget _buildOverlay(BuildContext context) {
    final barrier = ModalBarrier(
      dismissible: false,
      color:
          loadingBarrierColor ??
          (loadingBlur > 0 ? Colors.black26 : Colors.black54),
    );
    final indicator = loadingIndicator ?? const CircularProgressIndicator();
    final message = loadingMessage;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (loadingBlur > 0)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: loadingBlur, sigmaY: loadingBlur),
            child: barrier,
          )
        else
          barrier,
        Center(
          child: message == null
              ? indicator
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        indicator,
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
