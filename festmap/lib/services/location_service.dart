import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/geo_coordinates.dart';
import 'web_browser_location.dart';
import 'web_geocoding.dart';



class LocationService {

  static Duration get _locationTimeout =>

      kIsWeb ? const Duration(seconds: 90) : const Duration(seconds: 12);



  Future<bool> ensurePermission() async {

    if (kIsWeb) {

      final permission = await WebBrowserLocation.checkBrowserPermission();

      return permission == LocationPermission.whileInUse ||

          permission == LocationPermission.always ||

          permission == LocationPermission.denied ||

          permission == LocationPermission.unableToDetermine;

    }



    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();

    }

    return permission == LocationPermission.always ||

        permission == LocationPermission.whileInUse;

  }



  /// Fast path on mobile: cached position first, then GPS. Web uses browser API.

  Future<Position> getCurrentPosition() async {

    if (kIsWeb) {

      return _getWebPosition();

    }



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

      unawaited(_refreshPositionMobile());

      return lastKnown;

    }



    return _refreshPositionMobile();

  }



  Future<Position> _getWebPosition() async {

    final permission = await WebBrowserLocation.checkBrowserPermission();

    if (permission == LocationPermission.deniedForever) {

      throw const LocationException(

        'Location is blocked for this site. Click the lock icon in the '

        'address bar → Site settings → Location → Allow, then Retry. '

        'You can also long-press the map to drop a pin.',

      );

    }



    try {

      return await WebBrowserLocation.getCurrentPosition();

    } on PermissionDeniedException {

      throw const LocationException(

        'Location permission was denied. Click Allow when prompted, or '

        'enable Location in site settings, then Retry.',

      );

    } on TimeoutException {

      throw const LocationException(

        'Location timed out. On desktop, Wi‑Fi location can be slow — '

        'long-press the map to drop a pin, or Retry after allowing location.',

      );

    } on PositionUpdateException catch (e) {

      throw LocationException(

        'Could not determine your position (${e.message ?? "unavailable"}). '

        'Long-press the map to drop a pin instead.',

      );

    }

  }



  Future<Position> _refreshPositionMobile() {

    return Geolocator.getCurrentPosition(

      locationSettings: LocationSettings(

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



  /// Resolves a free-text address to coordinates (forward geocoding).
  Future<GeoCoordinates?> forwardGeocode(String address) async {
    final trimmed = address.trim();
    if (trimmed.length < 3) return null;

    if (kIsWeb) {
      final result = await WebGeocoding.forwardAddress(trimmed);
      if (result == null) return null;
      return GeoCoordinates(lat: result.lat, lng: result.lng);
    }

    try {
      final locations = await locationFromAddress(trimmed).timeout(
        const Duration(seconds: 10),
      );
      if (locations.isEmpty) return null;
      final first = locations.first;
      return GeoCoordinates(lat: first.latitude, lng: first.longitude);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> reverseGeocode(double lat, double lng) async {

    if (kIsWeb) {

      return WebGeocoding.reverseAddress(lat, lng);

    }



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


