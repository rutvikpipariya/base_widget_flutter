import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => BaseTextStyles.instance = const BaseTextStyles());

  test('applies the configured font to every weight', () {
    const styles = BaseTextStyles(
      fontFamily: 'Poppins',
      fontSize: 14,
      color: Color(0xFF151D31),
      height: 1.4,
      letterSpacing: 0.5,
    );

    for (final style in <TextStyle>[
      styles.thin,
      styles.extraLight,
      styles.light,
      styles.regular,
      styles.medium,
      styles.semiBold,
      styles.bold,
      styles.extraBold,
      styles.black,
    ]) {
      expect(style.fontFamily, 'Poppins');
      expect(style.fontSize, 14);
      expect(style.color, const Color(0xFF151D31));
      expect(style.height, 1.4);
      expect(style.letterSpacing, 0.5);
      expect(style.decoration, TextDecoration.none);
    }
  });

  test('maps each getter to its FontWeight', () {
    const styles = BaseTextStyles();

    expect(styles.thin.fontWeight, FontWeight.w100);
    expect(styles.extraLight.fontWeight, FontWeight.w200);
    expect(styles.light.fontWeight, FontWeight.w300);
    expect(styles.regular.fontWeight, FontWeight.w400);
    expect(styles.medium.fontWeight, FontWeight.w500);
    expect(styles.semiBold.fontWeight, FontWeight.w600);
    expect(styles.bold.fontWeight, FontWeight.w700);
    expect(styles.extraBold.fontWeight, FontWeight.w800);
    expect(styles.black.fontWeight, FontWeight.w900);
  });

  test('defaults are usable before anything is configured', () {
    expect(BaseTextStyles.instance.regular.fontFamily, isNull);
    expect(BaseTextStyles.instance.regular.fontSize, 16);
    expect(BaseTextStyles.instance.regular.color, isNull);
  });

  test('instance reflects the configuration assigned at start-up', () {
    BaseTextStyles.instance = const BaseTextStyles(fontFamily: 'Poppins');

    expect(BaseTextStyles.instance.semiBold.fontFamily, 'Poppins');
    expect(BaseTextStyles.instance.semiBold.fontWeight, FontWeight.w600);
  });

  test('copyWith on the returned TextStyle overrides a single style', () {
    const styles = BaseTextStyles(fontFamily: 'Poppins');
    final heading = styles.bold.copyWith(fontSize: 24);

    expect(heading.fontSize, 24);
    expect(heading.fontFamily, 'Poppins');
    expect(heading.fontWeight, FontWeight.w700);
    // The shared configuration is untouched.
    expect(styles.bold.fontSize, 16);
  });
}
