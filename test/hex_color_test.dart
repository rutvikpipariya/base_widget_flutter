import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses 6 digits as opaque RRGGBB, with or without a hash', () {
    expect('1364FF'.toColor(), const Color(0xFF1364FF));
    expect('#1364FF'.toColor(), const Color(0xFF1364FF));
  });

  test('is case insensitive and tolerates surrounding whitespace', () {
    expect('  #1364ff  '.toColor(), const Color(0xFF1364FF));
  });

  test('expands 3 digits to opaque RRGGBB', () {
    expect('F00'.toColor(), const Color(0xFFFF0000));
    expect('#abc'.toColor(), const Color(0xFFAABBCC));
  });

  test('expands 4 digits to AARRGGBB', () {
    expect('8F00'.toColor(), const Color(0x88FF0000));
  });

  test('reads 8 digits as AARRGGBB, not the CSS RRGGBBAA order', () {
    expect('801364FF'.toColor(), const Color(0x801364FF));
  });

  test('tryToColor returns null for malformed input', () {
    for (final input in <String>[
      '',
      '#',
      'nothex',
      '12345',
      '1364FFF',
      '#1364FF00FF',
      '-ffffff',
      '+ffffff',
      '0x1364FF',
    ]) {
      expect(input.tryToColor(), isNull, reason: 'expected null for "$input"');
    }
  });

  test('toColor throws a FormatException naming the bad input', () {
    expect(
      () => 'nothex'.toColor(),
      throwsA(
        isA<FormatException>().having((e) => e.source, 'source', 'nothex'),
      ),
    );
  });
}
