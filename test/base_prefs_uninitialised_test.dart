import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lives in its own file on purpose: each test file runs in a fresh isolate,
/// which is the only way to observe [BasePrefs] before [BasePrefs.init] has
/// ever run. Do not call `init()` here.
void main() {
  test('reports that it is not initialised', () {
    expect(BasePrefs.isInitialised, isFalse);
  });

  test('reading before init throws a StateError naming the fix', () {
    // The original service used `_prefs?.getBool(...)`, so a forgotten init()
    // silently returned defaults and dropped every write. Failing loudly is
    // the point of this test.
    expect(
      () => BasePrefs.getBool('anything'),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('BasePrefs.init()'),
        ),
      ),
    );
  });

  test('writing before init throws too', () {
    expect(() => BasePrefs.setString('a', 'b'), throwsStateError);
  });
}
