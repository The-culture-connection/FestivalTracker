import 'dart:async';
import 'dart:js_interop';

import 'package:geolocator/geolocator.dart';
import 'package:web/web.dart' as web;

/// Browser geolocation for Flutter web, bypassing geolocator_web timeout bugs.
abstract final class WebBrowserLocation {
  static Future<LocationPermission> checkBrowserPermission() async {
    try {
      final status = await web.window.navigator.permissions
          .query({'name': 'geolocation'}.jsify() as JSObject)
          .toDart;

    switch (status.state) {
      case 'granted':
        return LocationPermission.whileInUse;
      case 'prompt':
        return LocationPermission.denied;
      default:
        return LocationPermission.deniedForever;
    }
    } catch (_) {
      return LocationPermission.unableToDetermine;
    }
  }

  static Future<Position> getCurrentPosition() async {
    final completer = Completer<Position>();

    web.window.navigator.geolocation.getCurrentPosition(
      (web.GeolocationPosition position) {
        if (!completer.isCompleted) {
          completer.complete(_toPosition(position));
        }
      }.toJS,
      (web.GeolocationPositionError error) {
        if (!completer.isCompleted) {
          completer.completeError(_convertError(error));
        }
      }.toJS,
      web.PositionOptions(
        enableHighAccuracy: false,
        // Milliseconds — geolocator_web mistakenly used microseconds.
        timeout: 90_000,
        // Reuse a recent fix so Allow → instant centering when possible.
        maximumAge: 600_000,
      ),
    );

    return completer.future;
  }

  static Position _toPosition(web.GeolocationPosition webPosition) {
    final coords = webPosition.coords;
    return Position(
      latitude: coords.latitude,
      longitude: coords.longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(webPosition.timestamp),
      altitude: coords.altitude ?? 0.0,
      altitudeAccuracy: coords.altitudeAccuracy ?? 0.0,
      accuracy: coords.accuracy,
      heading: coords.heading ?? 0.0,
      headingAccuracy: 0.0,
      speed: coords.speed ?? 0.0,
      speedAccuracy: 0.0,
      isMocked: false,
    );
  }

  static Exception _convertError(web.GeolocationPositionError error) {
    switch (error.code) {
      case 1:
        return PermissionDeniedException(error.message);
      case 2:
        return PositionUpdateException(error.message);
      case 3:
        return TimeoutException(error.message);
      default:
        return Exception(error.message);
    }
  }
}
