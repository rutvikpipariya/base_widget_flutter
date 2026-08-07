import 'package:shared_preferences/shared_preferences.dart';

/// Synchronous access to [SharedPreferences] after a one-time [init].
///
/// `SharedPreferences.getInstance()` is async, so reading a stored value
/// normally means an `await` at every call site. Await it once during
/// start-up and the rest of the app reads synchronously:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await BasePrefs.init();
///   runApp(const MyApp());
/// }
///
/// final seenOnboarding = BasePrefs.getBool('seen_onboarding');
/// ```
///
/// Getters take a `defaultValue` so they never return null — that is the one
/// thing [SharedPreferences] does not give you. Anything not wrapped here is
/// reachable through [instance].
///
/// > **Do not store auth tokens, passwords or personal data here.**
/// > [SharedPreferences] is plain text on disk — `NSUserDefaults` on iOS and
/// > a world-readable XML file on Android — and is trivially recoverable from
/// > a rooted device or an unencrypted backup. Use `flutter_secure_storage`,
/// > which is backed by the iOS Keychain and Android Keystore, for secrets.
class BasePrefs {
  const BasePrefs._();

  static SharedPreferences? _prefs;

  /// Loads the stored preferences. Call once, before `runApp`.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Whether [init] has completed.
  static bool get isInitialised => _prefs != null;

  /// The underlying [SharedPreferences], for anything not wrapped here.
  ///
  /// Throws a [StateError] if [init] has not completed.
  static SharedPreferences get instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'BasePrefs used before init(). Add "await BasePrefs.init();" to '
        'main(), after WidgetsFlutterBinding.ensureInitialized().',
      );
    }
    return prefs;
  }

  /// Reads a [bool], falling back to [defaultValue] when the key is unset.
  static bool getBool(String key, {bool defaultValue = false}) =>
      instance.getBool(key) ?? defaultValue;

  /// Reads an [int], falling back to [defaultValue] when the key is unset.
  static int getInt(String key, {int defaultValue = 0}) =>
      instance.getInt(key) ?? defaultValue;

  /// Reads a [double], falling back to [defaultValue] when the key is unset.
  static double getDouble(String key, {double defaultValue = 0}) =>
      instance.getDouble(key) ?? defaultValue;

  /// Reads a [String], falling back to [defaultValue] when the key is unset.
  static String getString(String key, {String defaultValue = ''}) =>
      instance.getString(key) ?? defaultValue;

  /// Reads a list of strings, or an empty list when the key is unset.
  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const <String>[],
  }) => instance.getStringList(key) ?? defaultValue;

  /// Stores a [bool].
  static Future<bool> setBool(String key, bool value) =>
      instance.setBool(key, value);

  /// Stores an [int].
  static Future<bool> setInt(String key, int value) =>
      instance.setInt(key, value);

  /// Stores a [double].
  static Future<bool> setDouble(String key, double value) =>
      instance.setDouble(key, value);

  /// Stores a [String].
  static Future<bool> setString(String key, String value) =>
      instance.setString(key, value);

  /// Stores a list of strings.
  static Future<bool> setStringList(String key, List<String> value) =>
      instance.setStringList(key, value);

  /// Whether a value is stored under [key].
  static bool containsKey(String key) => instance.containsKey(key);

  /// Removes the value stored under [key].
  static Future<bool> remove(String key) => instance.remove(key);

  /// Removes every value this app has stored.
  static Future<bool> clear() => instance.clear();
}
