import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await BasePrefs.init();
  });

  test('round-trips every supported type', () async {
    await BasePrefs.setBool('b', true);
    await BasePrefs.setInt('i', 7);
    await BasePrefs.setDouble('d', 1.5);
    await BasePrefs.setString('s', 'hello');
    await BasePrefs.setStringList('l', <String>['a', 'b']);

    expect(BasePrefs.getBool('b'), isTrue);
    expect(BasePrefs.getInt('i'), 7);
    expect(BasePrefs.getDouble('d'), 1.5);
    expect(BasePrefs.getString('s'), 'hello');
    expect(BasePrefs.getStringList('l'), <String>['a', 'b']);
  });

  test('getters fall back to their default when the key is unset', () {
    expect(BasePrefs.getBool('missing'), isFalse);
    expect(BasePrefs.getInt('missing'), 0);
    expect(BasePrefs.getDouble('missing'), 0);
    expect(BasePrefs.getString('missing'), '');
    expect(BasePrefs.getStringList('missing'), isEmpty);

    expect(BasePrefs.getBool('missing', defaultValue: true), isTrue);
    expect(BasePrefs.getString('missing', defaultValue: 'x'), 'x');
  });

  test('containsKey, remove and clear', () async {
    await BasePrefs.setString('s', 'hello');
    expect(BasePrefs.containsKey('s'), isTrue);

    await BasePrefs.remove('s');
    expect(BasePrefs.containsKey('s'), isFalse);

    await BasePrefs.setInt('i', 1);
    await BasePrefs.clear();
    expect(BasePrefs.containsKey('i'), isFalse);
  });

  test('reports that it is initialised', () {
    expect(BasePrefs.isInitialised, isTrue);
  });
}
