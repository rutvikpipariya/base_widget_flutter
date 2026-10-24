/// [BaseStateView]: one widget for the loading, empty, error and content
/// states every data-driven screen has.
library;

import 'package:flutter/material.dart';

/// The state a [BaseStateView] is showing.
enum BaseViewState {
  /// Data is being fetched; shows a progress indicator.
  loading,

  /// The fetch succeeded but returned nothing; shows the empty message.
  empty,

  /// The fetch failed; shows the error message and a retry button.
  error,

  /// Data is available; shows the child.
  content,
}

/// Switches between loading, empty, error and content with a cross-fade.
///
/// Every list or detail screen needs the same four states. Instead of
/// rebuilding the spinner, the "nothing here yet" placeholder and the retry
/// button on each screen, drive one widget with a [BaseViewState]:
///
/// ```dart
/// BaseStateView(
///   state: _orders == null
///       ? BaseViewState.loading
///       : _orders!.isEmpty
///           ? BaseViewState.empty
///           : BaseViewState.content,
///   emptyTitle: 'No orders yet',
///   emptyMessage: 'Your orders will show up here.',
///   onRetry: _load,
///   child: OrderList(orders: _orders ?? const []),
/// )
/// ```
///
/// Colours and text come from the ambient [Theme], so dark mode works. Pass
/// [loadingBuilder], [emptyBuilder] or [errorBuilder] to replace a state
/// entirely, e.g. with your own illustration.
class BaseStateView extends StatelessWidget {
  /// Creates a view that shows [child] in the [BaseViewState.content] state.
  const BaseStateView({
    super.key,
    required this.state,
    required this.child,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.errorIcon = Icons.cloud_off_outlined,
    this.errorTitle = 'Something went wrong',
    this.errorMessage,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.duration = const Duration(milliseconds: 250),
  });

  /// Which state to show.
  final BaseViewState state;

  /// Shown in the [BaseViewState.content] state.
  final Widget child;

  /// Icon of the empty state.
  final IconData emptyIcon;

  /// Headline of the empty state.
  final String emptyTitle;

  /// Optional explanation under [emptyTitle].
  final String? emptyMessage;

  /// Icon of the error state.
  final IconData errorIcon;

  /// Headline of the error state.
  final String errorTitle;

  /// Optional explanation under [errorTitle], e.g. the failure reason.
  final String? errorMessage;

  /// Called by the retry button of the error state. The button is hidden
  /// when this is null.
  final VoidCallback? onRetry;

  /// Label of the retry button.
  final String retryLabel;

  /// Replaces the default loading indicator.
  final WidgetBuilder? loadingBuilder;

  /// Replaces the default empty state.
  final WidgetBuilder? emptyBuilder;

  /// Replaces the default error state.
  final WidgetBuilder? errorBuilder;

  /// Length of the cross-fade between states.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: KeyedSubtree(key: ValueKey(state), child: _buildState(context)),
    );
  }

  Widget _buildState(BuildContext context) {
    switch (state) {
      case BaseViewState.loading:
        return loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator());
      case BaseViewState.empty:
        return emptyBuilder?.call(context) ??
            _Message(icon: emptyIcon, title: emptyTitle, message: emptyMessage);
      case BaseViewState.error:
        return errorBuilder?.call(context) ??
            _Message(
              icon: errorIcon,
              title: errorTitle,
              message: errorMessage,
              isError: true,
              action: onRetry == null
                  ? null
                  : FilledButton.tonalIcon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(retryLabel),
                    ),
            );
      case BaseViewState.content:
        return child;
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.message,
    this.isError = false,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final bool isError;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = isError ? scheme.error : scheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
