import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

/// Reverse geocoding for Flutter web (geocoding package is mobile-only).
abstract final class WebGeocoding {
  static const _nominatimUserAgent = 'FestMap/1.0 (festival-tracker-221ca)';

  /// Address search → coordinates (forward geocoding).
  static Future<({double lat, double lng})?> forwardAddress(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return null;

    final photon = await _photonForward(trimmed);
    if (photon != null) return photon;

    final osm = await _nominatimForward(trimmed);
    if (osm != null) return osm;

    return _googleForward(trimmed);
  }

  static Future<({double lat, double lng})?> _photonForward(String query) async {
    final uri = Uri.https('photon.komoot.io', '/api/', {
      'q': query,
      'limit': '1',
      'lang': 'en',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;

      final geometry =
          (features.first as Map<String, dynamic>)['geometry']
              as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.length < 2) return null;

      return (lat: (coords[1] as num).toDouble(), lng: (coords[0] as num).toDouble());
    } catch (_) {
      return null;
    }
  }

  static Future<({double lat, double lng})?> _nominatimForward(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
    });

    try {
      final response = await http.get(
        uri,
        headers: const {'User-Agent': _nominatimUserAgent},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final list = jsonDecode(response.body) as List<dynamic>;
      if (list.isEmpty) return null;

      final first = list.first as Map<String, dynamic>;
      return (
        lat: double.parse(first['lat'] as String),
        lng: double.parse(first['lon'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<({double lat, double lng})?> _googleForward(String query) async {
    final apiKey = DefaultFirebaseOptions.web.apiKey;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': query,
      'key': apiKey,
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final location =
          (results.first as Map<String, dynamic>)['geometry']?['location']
              as Map<String, dynamic>?;
      if (location == null) return null;

      return (
        lat: (location['lat'] as num).toDouble(),
        lng: (location['lng'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Browser-friendly providers first; Google optional (needs Geocoding API).
  static Future<String> reverseAddress(double lat, double lng) async {
    final photon = await _photonReverse(lat, lng);
    if (photon != null) return photon;

    final osm = await _nominatimReverse(lat, lng);
    if (osm != null) return osm;

    final google = await _googleReverse(lat, lng);
    if (google != null) return google;

    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  static Future<String?> _photonReverse(double lat, double lng) async {
    final uri = Uri.https('photon.komoot.io', '/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'lang': 'en',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;

      final props =
          (features.first as Map<String, dynamic>)['properties']
              as Map<String, dynamic>?;
      if (props == null) return null;

      final name = props['name'] as String?;
      final street = props['street'] as String?;
      final housenumber = props['housenumber'] as String?;
      final city = props['city'] as String? ?? props['locality'] as String?;
      final state = props['state'] as String?;
      final country = props['country'] as String?;

      String? line1;
      if (housenumber != null && street != null) {
        line1 = '$housenumber $street';
      } else if (street != null) {
        line1 = street;
      } else if (name != null) {
        line1 = name;
      }

      final line2 = [
        if (city != null) city,
        if (state != null) state,
        if (country != null) country,
      ].join(', ');

      if (line1 != null && line2.isNotEmpty) return '$line1, $line2';
      if (line1 != null) return line1;
      if (line2.isNotEmpty) return line2;
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<String?> _nominatimReverse(double lat, double lng) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'json',
      'addressdetails': '1',
      'zoom': '18',
    });

    try {
      final response = await http.get(
        uri,
        headers: const {'User-Agent': _nominatimUserAgent},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final displayName = data['display_name'] as String?;
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<String?> _googleReverse(double lat, double lng) async {
    final apiKey = DefaultFirebaseOptions.web.apiKey;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'key': apiKey,
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;
      if (status != 'OK') {
        if (kDebugMode && status == 'REQUEST_DENIED') {
          // ignore: avoid_print
          print(
            'Google Geocoding skipped ($status). Using OSM instead. To use '
            'Google addresses, enable Geocoding API on your web API key in GCP.',
          );
        }
        return null;
      }

      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      return first['formatted_address'] as String?;
    } catch (_) {
      return null;
    }
  }
}
