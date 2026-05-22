import 'dart:async';
import 'dart:math' as math;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _locationTimeout = Duration(seconds: 12);

  Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Fast path for startup: cached position first, then GPS with timeout.
  Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('Location services are disabled.');
    }

    final granted = await ensurePermission();
    if (!granted) {
      throw const LocationException('Location permission was denied.');
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      unawaited(_refreshPosition());
      return lastKnown;
    }

    return _refreshPosition();
  }

  Future<Position> _refreshPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: _locationTimeout,
      ),
    ).timeout(
      _locationTimeout,
      onTimeout: () => throw const LocationException(
        'Timed out getting GPS fix. On the emulator, set a mock location '
        '(Extended Controls → Location), then tap Try again.',
      ),
    );
  }

  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 8),
      );
      if (placemarks.isEmpty) {
        return _coordinateLabel(lat, lng);
      }

      final place = placemarks.first;
      final parts = <String>[
        if (place.name != null && place.name!.isNotEmpty) place.name!,
        if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea!,
        if (place.country != null && place.country!.isNotEmpty) place.country!,
      ];
      return parts.isEmpty ? _coordinateLabel(lat, lng) : parts.join(', ');
    } on TimeoutException {
      return _coordinateLabel(lat, lng);
    }
  }

  String _coordinateLabel(double lat, double lng) =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double deg) => deg * (math.pi / 180);
