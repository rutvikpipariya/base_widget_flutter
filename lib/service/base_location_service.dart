/// [BaseLocationService]: current position with a reason when it fails.
library;

import 'package:geolocator/geolocator.dart';

/// The reason a location read could not be satisfied.
enum LocationFailure {
  /// Location services are switched off device-wide.
  ///
  /// Send the user to [BaseLocationService.openLocationSettings].
  serviceDisabled,

  /// The user declined this time. Asking again later is fine.
  denied,

  /// The user declined permanently, or a policy blocks it. The system will
  /// not show the prompt again — send the user to
  /// [BaseLocationService.openAppSettings].
  deniedForever,
}

/// The outcome of [BaseLocationService.getCurrentPosition].
///
/// Either [position] is non-null, or [failure] explains why not. Switch on
/// [failure] to show the right prompt — a plain null tells the user nothing.
class LocationResult {
  /// A successful read.
  const LocationResult.success(Position this.position) : failure = null;

  /// A failed read, with the reason in [failure].
  const LocationResult.failed(LocationFailure this.failure) : position = null;

  /// The device position, or null when the read failed.
  final Position? position;

  /// Why the read failed, or null when it succeeded.
  final LocationFailure? failure;

  /// Whether a [position] was obtained.
  bool get isSuccess => position != null;
}

/// Reads the device position, handling the permission dance first.
///
/// ```dart
/// final result = await BaseLocationService.getCurrentPosition();
/// switch (result.failure) {
///   case null:
///     print(result.position!.latitude);
///   case LocationFailure.serviceDisabled:
///     await BaseLocationService.openLocationSettings();
///   case LocationFailure.denied:
///     showSnackBar('Location is needed to find nearby clinics.');
///   case LocationFailure.deniedForever:
///     await BaseLocationService.openAppSettings();
/// }
/// ```
///
/// Declare the platform permissions yourself — `NSLocationWhenInUseUsageDescription`
/// in `Info.plist` and `ACCESS_FINE_LOCATION` in `AndroidManifest.xml`. See the
/// `geolocator` README for the full per-platform setup.
class BaseLocationService {
  const BaseLocationService._();

  /// Ensures location services are on and permission is granted, prompting
  /// the user if needed.
  ///
  /// Returns null when everything is in order, or the blocking
  /// [LocationFailure] otherwise.
  static Future<LocationFailure?> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationFailure.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return switch (permission) {
      LocationPermission.denied => LocationFailure.denied,
      LocationPermission.deniedForever => LocationFailure.deniedForever,
      _ => null,
    };
  }

  /// Reads the current position, requesting permission first if needed.
  ///
  /// [accuracy] trades precision for battery and time to first fix.
  static Future<LocationResult> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final failure = await ensurePermission();
    if (failure != null) {
      return LocationResult.failed(failure);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: accuracy),
    );
    return LocationResult.success(position);
  }

  /// The last position the platform cached, if any.
  ///
  /// Returns immediately, so it is a good placeholder while
  /// [getCurrentPosition] resolves. Null when nothing is cached or
  /// permission is missing.
  static Future<Position?> getLastKnownPosition() async {
    if (await ensurePermission() != null) {
      return null;
    }
    return Geolocator.getLastKnownPosition();
  }

  /// Opens the device's location settings, for [LocationFailure.serviceDisabled].
  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  /// Opens this app's settings page, for [LocationFailure.deniedForever].
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
