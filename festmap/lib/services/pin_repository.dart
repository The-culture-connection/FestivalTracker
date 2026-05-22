import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/fest_pin.dart';
import 'location_service.dart';

class PinRepository {
  PinRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'pins';

  /// All pins (used on web so users can see pins from any region).
  Stream<List<FestPin>> watchAllPins() {
    return _firestore.collection(_collection).snapshots().map(_parseSnapshot);
  }

  Stream<List<FestPin>> watchNearbyPins({
    required double lat,
    required double lng,
    double radiusKm = 15,
  }) {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final pins = _parseSnapshot(snapshot)
          .where((pin) => haversineKm(lat, lng, pin.lat, pin.lng) <= radiusKm)
          .toList();
      pins.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return pins;
    });
  }

  List<FestPin> _parseSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final pins = <FestPin>[];
    for (final doc in snapshot.docs) {
      try {
        pins.add(FestPin.fromFirestore(doc));
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Skipping invalid pin ${doc.id}: $e');
        }
      }
    }
    pins.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return pins;
  }

  Future<String> savePin(PinDraft draft) async {
    final doc = await _firestore.collection(_collection).add(draft.toFirestore());
    return doc.id;
  }
}
