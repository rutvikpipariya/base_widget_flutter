import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: child);

/// The route itself installs a [ModalBarrier], so match ours by its colour.
final Finder _loadingBarrier = find.byWidgetPredicate(
  (widget) => widget is ModalBarrier && widget.color == Colors.black54,
  description: 'loading barrier',
);

final Finder _popScope = find.byType(PopScope<dynamic>);

void main() {
  testWidgets('renders the body and the optional app bar', (tester) async {
    await tester.pumpWidget(
      _host(
        BaseWidget(
          bodyAppBar: AppBar(title: const Text('Home')),
          body: const Text('content'),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('shows no loading overlay by default', (tester) async {
    await tester.pumpWidget(_host(const BaseWidget(body: Text('content'))));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(_loadingBarrier, findsNothing);
  });

  testWidgets('isLoading covers the body with a barrier and an indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const BaseWidget(isLoading: true, body: Text('content'))),
    );

    expect(find.text('content'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_loadingBarrier, findsOneWidget);
  });

  testWidgets('loadingIndicator replaces the default spinner', (tester) async {
    await tester.pumpWidget(
      _host(
        const BaseWidget(
          isLoading: true,
          loadingIndicator: Text('saving'),
          body: Text('content'),
        ),
      ),
    );

    expect(find.text('saving'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('canPop defaults to allowing a pop', (tester) async {
    await tester.pumpWidget(_host(const BaseWidget(body: Text('content'))));

    expect(tester.widget<PopScope<dynamic>>(_popScope).canPop, isTrue);
  });

  testWidgets('canPop false blocks the route from popping', (tester) async {
    await tester.pumpWidget(
      _host(const BaseWidget(canPop: false, body: Text('content'))),
    );

    expect(tester.widget<PopScope<dynamic>>(_popScope).canPop, isFalse);
  });

  testWidgets('backgroundColor is null so the theme decides', (tester) async {
    await tester.pumpWidget(_host(const BaseWidget(body: Text('content'))));

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      isNull,
    );
  });

  testWidgets('dismissKeyboardOnTap unfocuses on an outside tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const BaseWidget(
          dismissKeyboardOnTap: true,
          body: Column(
            children: [
              TextField(),
              SizedBox(height: 200, child: Text('outside')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('outside'));
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('forwards Scaffold slots', (tester) async {
    await tester.pumpWidget(
      _host(
        BaseWidget(
          body: const Text('content'),
          drawer: const Drawer(child: Text('drawer')),
          bottomNavigationBar: const SizedBox(height: 40, child: Text('nav')),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.drawer, isNotNull);
    expect(find.text('nav'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('loadingMessage is shown under the indicator', (tester) async {
    await tester.pumpWidget(
      _host(
        const BaseWidget(
          isLoading: true,
          loadingMessage: 'Saving…',
          body: Text('content'),
        ),
      ),
    );

    expect(find.text('Saving…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('loadingBlur blurs the body behind a lighter barrier', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const BaseWidget(
          isLoading: true,
          loadingBlur: 6,
          body: Text('content'),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ModalBarrier && widget.color == Colors.black26,
      ),
      findsOneWidget,
    );
  });

  testWidgets('the loading overlay fades out when loading ends', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const BaseWidget(isLoading: true, body: Text('content'))),
    );
    await tester.pumpWidget(_host(const BaseWidget(body: Text('content'))));
    await tester.pumpAndSettle();

    expect(_loadingBarrier, findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('onRefresh enables pull-to-refresh', (tester) async {
    var refreshed = 0;
    await tester.pumpWidget(
      _host(
        BaseWidget(
          onRefresh: () async => refreshed++,
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 100, child: Text('row'))],
          ),
        ),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.fling(find.text('row'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(refreshed, 1);
  });
}
