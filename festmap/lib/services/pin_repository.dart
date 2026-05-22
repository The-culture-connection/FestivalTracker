import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fest_pin.dart';
import 'location_service.dart';

class PinRepository {
  PinRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'pins';

  Stream<List<FestPin>> watchNearbyPins({
    required double lat,
    required double lng,
    double radiusKm = 15,
  }) {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final pins = snapshot.docs
          .map(FestPin.fromFirestore)
          .where(
            (pin) => haversineKm(lat, lng, pin.lat, pin.lng) <= radiusKm,
          )
          .toList();
      pins.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return pins;
    });
  }

  Future<String> savePin(PinDraft draft) async {
    final doc = await _firestore.collection(_collection).add(draft.toFirestore());
    return doc.id;
  }
}
