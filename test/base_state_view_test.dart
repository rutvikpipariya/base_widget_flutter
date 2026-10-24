import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(BaseViewState state, {VoidCallback? onRetry}) => MaterialApp(
  home: Scaffold(
    body: BaseStateView(
      state: state,
      emptyTitle: 'No orders',
      emptyMessage: 'Orders show up here.',
      errorMessage: 'Offline',
      onRetry: onRetry,
      child: const Text('content'),
    ),
  ),
);

void main() {
  testWidgets('loading shows a progress indicator', (tester) async {
    await tester.pumpWidget(_host(BaseViewState.loading));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('content'), findsNothing);
  });

  testWidgets('empty shows the title and message', (tester) async {
    await tester.pumpWidget(_host(BaseViewState.empty));

    expect(find.text('No orders'), findsOneWidget);
    expect(find.text('Orders show up here.'), findsOneWidget);
  });

  testWidgets('error shows a retry button that calls onRetry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      _host(BaseViewState.error, onRetry: () => retries++),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('error hides the retry button without onRetry', (tester) async {
    await tester.pumpWidget(_host(BaseViewState.error));

    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('content shows the child after the cross-fade', (tester) async {
    await tester.pumpWidget(_host(BaseViewState.loading));
    await tester.pumpWidget(_host(BaseViewState.content));
    await tester.pumpAndSettle();

    expect(find.text('content'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('builders replace the default states', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BaseStateView(
          state: BaseViewState.empty,
          emptyBuilder: (_) => const Text('custom empty'),
          child: const SizedBox(),
        ),
      ),
    );

    expect(find.text('custom empty'), findsOneWidget);
  });
}
