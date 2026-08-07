import 'dart:convert';

import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const String _svg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">'
    '<rect width="10" height="10" fill="#000000"/></svg>';

/// Serves [_svg] for any key, so the widget can load without real assets.
class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(_svg)));
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    DefaultAssetBundle(
      bundle: _FakeAssetBundle(),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders an SvgPicture for the given asset', (tester) async {
    await _pump(tester, const SvgImageWidget(asset: 'assets/icon.svg'));

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('leaves the SVG untinted when color is null', (tester) async {
    await _pump(tester, const SvgImageWidget(asset: 'assets/icon.svg'));

    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
      isNull,
    );
  });

  testWidgets('tints with srcIn when a color is given', (tester) async {
    await _pump(
      tester,
      const SvgImageWidget(asset: 'assets/icon.svg', color: Color(0xFF1364FF)),
    );

    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
      const ColorFilter.mode(Color(0xFF1364FF), BlendMode.srcIn),
    );
  });

  testWidgets('forwards sizing, fit and semantics', (tester) async {
    await _pump(
      tester,
      const SvgImageWidget(
        asset: 'assets/icon.svg',
        height: 24,
        width: 32,
        fit: BoxFit.fill,
        semanticsLabel: 'Search',
      ),
    );

    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.height, 24);
    expect(picture.width, 32);
    expect(picture.fit, BoxFit.fill);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
  });
}
